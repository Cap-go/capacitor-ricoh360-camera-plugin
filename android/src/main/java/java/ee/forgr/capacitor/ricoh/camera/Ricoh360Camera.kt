package java.ee.forgr.capacitor.ricoh.camera

import android.util.Log
import com.getcapacitor.PluginCall
import com.ricoh360.thetaclient.ThetaRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.ee.forgr.capacitor.ricoh.camera.Ricoh360CameraPlugin.Companion.LOG_TAG
import io.ktor.utils.io.core.ByteReadPacket
import io.ktor.utils.io.streams.inputStream
import android.graphics.BitmapFactory
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity
import android.graphics.Bitmap
import android.os.Handler
import android.os.Looper
import android.view.ViewGroup

class Ricoh360Camera {
    var initialized: Boolean = false
        private set

    var repo: ThetaRepository? = null;

    private var previewImageView: ImageView? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    fun initialize(call: PluginCall, url: String, config: ThetaRepository.Config) {
        CoroutineScope(Dispatchers.Default).launch {
            this@Ricoh360Camera.initialized = true

            try {
                this@Ricoh360Camera.repo = ThetaRepository.newInstance(url, config)

            } catch (t: Throwable) {
                Log.e(LOG_TAG, "Cannot create a ThetaRepository", t)
                call.reject(t.stackTraceToString())
            }
            call.resolve()
        }
    }

    fun livePreview(call: PluginCall, activity: AppCompatActivity) {
        if (!this.initialized || this.repo == null) {
            call.reject("Not initialized ?")
            return
        }

        // Create and setup ImageView if not exists
        if (previewImageView == null) {
            previewImageView = ImageView(activity)
            // Add ImageView to your activity's layout
            // You'll need to specify layout parameters based on your needs
            CoroutineScope(Dispatchers.Main).launch {
                activity.addContentView(previewImageView, ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                ))
            }
        }

        CoroutineScope(Dispatchers.Default).launch {
            try {
                this@Ricoh360Camera.repo!!.getLivePreview()
                    .collect { byteReadPacket ->
                        byteReadPacket.inputStream().use { inputStream ->
                            val bytes = inputStream.readBytes()
                            // Convert bytes to Bitmap
                            val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                            // Update UI on main thread
                            mainHandler.post {
                                previewImageView?.setImageBitmap(bitmap)
                            }
                        }
                        byteReadPacket.release()
                    }
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Error in live preview", e)
                call.reject("Error in live preview: ${e.message}")
            }
        }
        call.resolve()
    }

    fun stopLivePreview() {
        previewImageView?.let { imageView ->
            mainHandler.post {
                val parent = imageView.parent as? ViewGroup
                parent?.removeView(imageView)
            }
        }
        previewImageView = null
    }
}
