package java.ee.forgr.capacitor.ricoh.camera;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.util.Base64;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Arrays;
import java.util.stream.Collectors;
import org.json.JSONException;
import org.json.JSONObject;

@CapacitorPlugin(name = "Ricoh360Camera")
public class Ricoh360CameraPlugin extends Plugin {

    private final String PLUGIN_VERSION = "";

    private String cameraUrl = "http://192.168.1.1";
    private ImageView previewView;
    private Thread streamThread;
    private boolean isStreaming = false;
    private final byte[] startMarker = new byte[] { (byte) 0xFF, (byte) 0xD8 };
    private final byte[] endMarker = new byte[] { (byte) 0xFF, (byte) 0xD9 };
    private final int containerViewId = 20;
    private FrameLayout containerView;

    @PluginMethod
    public void initialize(PluginCall call) {
        String url = call.getString("url", cameraUrl);
        cameraUrl = url;

        new Thread(() -> {
            try {
                URL infoUrl = new URL(cameraUrl + "/osc/info");
                HttpURLConnection connection = (HttpURLConnection) infoUrl.openConnection();
                connection.setRequestMethod("GET");
                connection.setConnectTimeout(5000);
                connection.connect();

                int responseCode = connection.getResponseCode();
                if (responseCode == HttpURLConnection.HTTP_OK) {
                    InputStream inputStream = connection.getInputStream();
                    String result = new BufferedReader(new InputStreamReader(inputStream)).lines().collect(Collectors.joining("\n"));
                    call.resolve(new JSObject().put("session", "Initialized").put("info", result));
                } else {
                    call.reject("Camera is not reachable or info could not be retrieved");
                }
            } catch (Exception e) {
                call.reject("Camera is not reachable or info could not be retrieved", e);
            }
        })
            .start();
    }

    @PluginMethod
    public void livePreview(PluginCall call) {
        boolean displayInFront = call.getBoolean("displayInFront", true);
        boolean cropPreview = call.getBoolean("cropPreview", false);

        getActivity().runOnUiThread(() -> {
            containerView = getBridge().getActivity().findViewById(containerViewId);
            if (containerView == null) {
                containerView = new FrameLayout(getActivity().getApplicationContext());
                containerView.setId(containerViewId);
                FrameLayout.LayoutParams containerParams = new FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                );
                containerView.setLayoutParams(containerParams);

                if (previewView == null) {
                    previewView = new ImageView(getContext());
                    FrameLayout.LayoutParams params;
                    if (cropPreview) {
                        params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
                        params.gravity = android.view.Gravity.FILL;
                        previewView.setAdjustViewBounds(true);
                    } else {
                        params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                        params.gravity = android.view.Gravity.CENTER;
                    }
                    previewView.setLayoutParams(params);
                    previewView.setScaleType(cropPreview ? ImageView.ScaleType.CENTER_CROP : ImageView.ScaleType.FIT_CENTER);
                    containerView.addView(previewView);
                }

                // Make webview transparent
                getBridge().getWebView().setBackgroundColor(Color.TRANSPARENT);
                ((ViewGroup) getBridge().getWebView().getParent()).addView(containerView);

                if (!displayInFront) {
                    getBridge().getWebView().getParent().bringChildToFront(getBridge().getWebView());
                }

                startMJPEGStream();
                call.resolve(new JSObject().put("preview", "Started"));
            } else {
                call.reject("preview already started");
            }
        });
    }

    @PluginMethod
    public void stopLivePreview(PluginCall call) {
        getActivity().runOnUiThread(() -> {
            isStreaming = false;
            if (streamThread != null) {
                streamThread.interrupt();
                streamThread = null;
            }
            if (containerView != null) {
                ((ViewGroup) getBridge().getWebView().getParent()).removeView(containerView);
                getBridge().getWebView().setBackgroundColor(Color.WHITE);
                containerView = null;
                previewView = null;
            }
            call.resolve(new JSObject().put("preview", "Stopped"));
        });
    }

    private void startMJPEGStream() {
        isStreaming = true;
        streamThread = new Thread(() -> {
            try {
                URL url = new URL(cameraUrl + "/osc/commands/execute");
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod("POST");
                connection.setRequestProperty("Content-Type", "application/json; utf-8");
                connection.setRequestProperty("Accept", "application/json");
                connection.setDoOutput(true);

                String jsonInputString = "{\"name\": \"camera.getLivePreview\"}";
                try (OutputStream os = connection.getOutputStream()) {
                    byte[] input = jsonInputString.getBytes("utf-8");
                    os.write(input, 0, input.length);
                }

                InputStream inputStream = connection.getInputStream();
                ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                byte[] data = new byte[8192];
                int bytesRead;

                while (isStreaming && (bytesRead = inputStream.read(data)) != -1) {
                    buffer.write(data, 0, bytesRead);
                    byte[] bufferData = buffer.toByteArray();

                    // Find start marker
                    int startIndex = -1;
                    for (int i = 0; i < bufferData.length - 1; i++) {
                        if (bufferData[i] == (byte) 0xFF && bufferData[i + 1] == (byte) 0xD8) {
                            startIndex = i;
                            break;
                        }
                    }

                    // Find end marker
                    int endIndex = -1;
                    if (startIndex != -1) {
                        for (int i = startIndex; i < bufferData.length - 1; i++) {
                            if (bufferData[i] == (byte) 0xFF && bufferData[i + 1] == (byte) 0xD9) {
                                endIndex = i + 1;
                                break;
                            }
                        }
                    }

                    // Process frame if we have both markers
                    if (startIndex != -1 && endIndex != -1) {
                        byte[] imageData = Arrays.copyOfRange(bufferData, startIndex, endIndex + 1);
                        processFrame(imageData);

                        // Keep remaining data after end marker
                        if (endIndex + 1 < bufferData.length) {
                            buffer.reset();
                            buffer.write(bufferData, endIndex + 1, bufferData.length - (endIndex + 1));
                        } else {
                            buffer.reset();
                        }
                    } else {
                        String bufferContent = new String(bufferData);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
        streamThread.start();
    }

    private void processFrame(byte[] imageData) {
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;

            final Bitmap bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.length, options);
            if (bitmap != null) {
                getActivity().runOnUiThread(() -> {
                    if (previewView != null) {
                        previewView.setImageBitmap(bitmap);
                    }
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @PluginMethod
    public void getCameraAsset(PluginCall call) {
        try {
            JSObject data = call.getData();
            String assetUrl = data.getString("url");
            boolean saveToFile = call.getBoolean("saveToFile", false);

            if (assetUrl == null) {
                call.reject("URL is required");
                return;
            }

            new Thread(() -> {
                try {
                    URL url = new URL(assetUrl);
                    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                    connection.setRequestMethod("GET");
                    connection.setConnectTimeout(10000);
                    connection.setReadTimeout(10000);

                    int responseCode = connection.getResponseCode();

                    InputStream inputStream;
                    if (responseCode >= 400) {
                        inputStream = connection.getErrorStream();
                    } else {
                        inputStream = connection.getInputStream();
                    }

                    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, bytesRead);
                    }

                    byte[] bytes = outputStream.toByteArray();
                    JSObject result = new JSObject();
                    result.put("statusCode", responseCode);

                    if (saveToFile) {
                        // Create a unique filename based on timestamp
                        String timestamp = String.valueOf(System.currentTimeMillis());
                        String filename = "ricoh_" + timestamp + ".jpg";
                        java.io.File outputDir = getContext().getCacheDir();
                        java.io.File outputFile = new java.io.File(outputDir, filename);

                        try (java.io.FileOutputStream fos = new java.io.FileOutputStream(outputFile)) {
                            fos.write(bytes);
                            result.put("filePath", outputFile.getAbsolutePath());
                        }
                    } else {
                        // downSize here to make it work with our magic watcher lib
                        String base64 = android.util.Base64.encodeToString(downSizeImage(bytes), Base64.NO_WRAP);
                        result.put("data", base64);
                    }

                    call.resolve(result);
                } catch (Exception e) {
                    call.reject("Failed to fetch asset: " + e.getMessage(), e);
                }
            })
                .start();
        } catch (Exception e) {
            call.reject("Failed to process request: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void listFiles(PluginCall call) {
        JSObject parameters = new JSObject();
        parameters.put("fileType", call.getString("fileType", "all"));
        parameters.put("startPosition", call.getInt("startPosition", 0));
        parameters.put("entryCount", call.getInt("entryCount", 100));
        parameters.put("maxThumbSize", call.getInt("maxThumbSize", 0));
        parameters.put("_detail", call.getBoolean("_detail", true));

        JSObject payload = new JSObject();
        payload.put("name", "camera.listFiles");
        payload.put("parameters", parameters);

        sendCommandRaw(call, "/osc/commands/execute", payload);
    }

    @PluginMethod
    public void capturePicture(PluginCall call) {
        JSObject payload = new JSObject();
        payload.put("name", "camera.takePicture");
        sendCommandRaw(call, "/osc/commands/execute", payload);
    }

    @PluginMethod
    public void readSettings(PluginCall call) {
        try {
            JSObject data = call.getData();
            JSObject payload = new JSObject();
            payload.put("name", "camera.getOptions");
            JSObject parameters = new JSObject();
            parameters.put("optionNames", data.getJSONArray("options"));
            payload.put("parameters", parameters);

            sendCommandRaw(call, "/osc/commands/execute", payload);
        } catch (Exception e) {
            android.util.Log.e("Ricoh360Camera", "Exception: " + e.getMessage(), e);
            call.reject("Failed to read settings: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void setSettings(PluginCall call) {
        try {
            JSObject data = call.getData();
            JSObject payload = new JSObject();
            payload.put("name", "camera.setOptions");
            JSObject parameters = new JSObject();
            parameters.put("options", data.getJSObject("options"));
            payload.put("parameters", parameters);

            sendCommandRaw(call, "/osc/commands/execute", payload);
        } catch (Exception e) {
            android.util.Log.e("Ricoh360Camera", "Exception: " + e.getMessage(), e);
            call.reject("Failed to set settings: " + e.getMessage(), e);
        }
    }

    private void sendCommandRaw(PluginCall call, String endpoint, JSONObject payload) {
        try {
            String commandUrl = cameraUrl + endpoint;
            String jsonInputString = payload.toString();

            android.util.Log.d("Ricoh360Camera", "Request body: " + jsonInputString);

            HttpURLConnection connection = createConnection(commandUrl, jsonInputString);
            int responseCode = connection.getResponseCode();
            android.util.Log.d("Ricoh360Camera", "Response code: " + responseCode);

            if (responseCode == HttpURLConnection.HTTP_OK) {
                InputStream inputStream = connection.getInputStream();
                String result = new BufferedReader(new InputStreamReader(inputStream)).lines().collect(Collectors.joining("\n"));
                android.util.Log.d("Ricoh360Camera", "Response body: " + result);
                call.resolve(new JSObject(result));
            } else {
                InputStream errorStream = connection.getErrorStream();
                String error = new BufferedReader(new InputStreamReader(errorStream)).lines().collect(Collectors.joining("\n"));
                android.util.Log.e("Ricoh360Camera", "Error response: " + error);
                call.reject("Command failed: " + error);
            }
        } catch (Exception e) {
            android.util.Log.e("Ricoh360Camera", "Exception: " + e.getMessage(), e);
            call.reject("Command failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void sendCommand(PluginCall call) {
        String endpoint = call.getString("endpoint");
        JSObject payload = call.getObject("payload");
        if (endpoint == null || payload == null) {
            call.reject("Endpoint and payload are required");
            return;
        }

        sendCommandRaw(call, endpoint, payload);
    }

    private HttpURLConnection createConnection(String urlString, String jsonInputString) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "application/json; charset=utf-8");
        connection.setRequestProperty("Accept", "application/json");
        connection.setConnectTimeout(10000);
        connection.setReadTimeout(10000);
        connection.setDoInput(true);
        connection.setDoOutput(true);
        connection.setUseCaches(false);

        OutputStream os = connection.getOutputStream();
        byte[] input = jsonInputString.getBytes("utf-8");
        os.write(input);
        os.flush();
        os.close();

        return connection;
    }

    private byte[] downSizeImage(byte[] image) {
        final int MAX_WIDTH = 2048; // Must be equal to or less than 4096
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;

        BitmapFactory.decodeByteArray(image, 0, image.length, options);
        android.util.Log.d("Ricoh360Camera", "JPEG width: " + options.outWidth);

        if (options.outWidth > MAX_WIDTH) {
            float scaleFactor = MAX_WIDTH / (float) options.outWidth;
            android.graphics.Matrix scale = new android.graphics.Matrix();
            scale.postScale(scaleFactor, scaleFactor);

            Bitmap bitmap = BitmapFactory.decodeByteArray(image, 0, image.length);
            Bitmap resizedBitmap = Bitmap.createBitmap(bitmap, 0, 0, options.outWidth, options.outHeight, scale, false);

            android.util.Log.d("Ricoh360Camera", "Resized width: " + resizedBitmap.getWidth());
            bitmap.recycle();

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            try {
                resizedBitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
                resizedBitmap.recycle();
                return outputStream.toByteArray();
            } finally {
                try {
                    outputStream.close();
                } catch (Exception e) {
                    android.util.Log.e("Ricoh360Camera", "Error closing output stream", e);
                }
            }
        }
        return image;
    }

    @PluginMethod
    public void getPluginVersion(final PluginCall call) {
        try {
            final JSObject ret = new JSObject();
            ret.put("version", this.PLUGIN_VERSION);
            call.resolve(ret);
        } catch (final Exception e) {
            call.reject("Could not get plugin version", e);
        }
    }
}
