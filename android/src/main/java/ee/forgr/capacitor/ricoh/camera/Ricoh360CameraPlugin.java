package java.ee.forgr.capacitor.ricoh.camera;

import java.io.OutputStream;
import java.io.InputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.ByteArrayOutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import android.widget.ImageView;
import android.widget.FrameLayout;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.view.ViewGroup;
import android.view.View;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.stream.Collectors;
import java.util.Arrays;

@CapacitorPlugin(name = "Ricoh360Camera")
public class Ricoh360CameraPlugin extends Plugin {

    private String cameraUrl = "http://192.168.1.1";
    private ImageView previewView;
    private Thread streamThread;
    private boolean isStreaming = false;
    private final byte[] startMarker = new byte[]{(byte) 0xFF, (byte) 0xD8};
    private final byte[] endMarker = new byte[]{(byte) 0xFF, (byte) 0xD9};
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
                    String result = new BufferedReader(new InputStreamReader(inputStream))
                        .lines().collect(Collectors.joining("\n"));
                    call.resolve(new JSObject().put("session", "Initialized").put("info", result));
                } else {
                    call.reject("Camera is not reachable or info could not be retrieved");
                }
            } catch (Exception e) {
                call.reject("Camera is not reachable or info could not be retrieved", e);
            }
        }).start();
    }

    @PluginMethod
    public void livePreview(PluginCall call) {
        boolean displayInFront = call.getBoolean("displayInFront", true);

        getActivity().runOnUiThread(() -> {
            containerView = getBridge().getActivity().findViewById(containerViewId);
            if (containerView == null) {
                containerView = new FrameLayout(getActivity().getApplicationContext());
                containerView.setId(containerViewId);

                if (previewView == null) {
                    previewView = new ImageView(getContext());
                    FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    );
                    previewView.setLayoutParams(params);
                    previewView.setScaleType(ImageView.ScaleType.FIT_CENTER);
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
    public void capturePicture(PluginCall call) {
        String jsonInputString = "{\"name\": \"camera.takePicture\"}";
        String captureUrl = cameraUrl + "/osc/commands/execute";

        try {
            HttpURLConnection connection = createConnection(captureUrl, jsonInputString);
            int responseCode = connection.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                call.resolve(new JSObject().put("picture", "Picture taken"));
            } else {
                call.reject("Failed to take picture");
            }
        } catch (Exception e) {
            call.reject("Failed to take picture", e);
        }
    }

    private HttpURLConnection createConnection(String urlString, String jsonInputString) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "application/json; utf-8");
        connection.setRequestProperty("Accept", "application/json");
        connection.setDoOutput(true);

        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = jsonInputString.getBytes("utf-8");
            os.write(input, 0, input.length);
        }

        return connection;
    }
} 
