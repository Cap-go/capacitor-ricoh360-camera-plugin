package java.ee.forgr.capacitor.ricoh.camera

import android.os.Build
import android.util.Log
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.ricoh360.thetaclient.ThetaRepository
import com.ricoh360.thetaclient.ThetaRepository.LanguageEnum
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonNames
import kotlinx.serialization.json.decodeFromJsonElement
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import androidx.appcompat.app.AppCompatActivity


@CapacitorPlugin(name = "Ricoh360Camera")
class Ricoh360CameraPlugin : Plugin() {
    companion object {
        const val LOG_TAG = "Ricoh360Camera"
    }

    enum class CameraLanguage(val lang: ThetaRepository.LanguageEnum) {
        @SerialName("en-US")
        EN_US(LanguageEnum.EN_US),
        @SerialName("en-GB")
        EN_GB(LanguageEnum.EN_GB),
        @SerialName("ja")
        JA(LanguageEnum.JA),
        @SerialName("fr")
        FR(LanguageEnum.FR),
        @SerialName("de")
        DE(LanguageEnum.DE),
        @SerialName("zh-TW")
        ZH_TW(LanguageEnum.ZH_TW),
        @SerialName("zh-CN")
        ZH_CN(LanguageEnum.ZH_CN),
        @SerialName("it")
        IT(LanguageEnum.IT),
        @SerialName("ko")
        KO(LanguageEnum.KO),
    }

    @Serializable
    data class InitializeOptions(
        val cameraUrl: String,
        val language: CameraLanguage?,
        val setDateTime: Boolean = false,
        val sleepDelay: Int? = null,
        val shutterSound: Int? = null
    )

//    @Serializable
//    data class PhotoOptions {
//
//    }

    enum class ExposureProgram(val program: ThetaRepository.ExposureProgramEnum) {
        @SerialName("manual")
        MANUAL(ThetaRepository.ExposureProgramEnum.MANUAL),
        @SerialName("normalProgram")
        NORMAL_PROGRAM(ThetaRepository.ExposureProgramEnum.NORMAL_PROGRAM),
        @SerialName("aperturePriority")
        APERTURE_PRIORITY(ThetaRepository.ExposureProgramEnum.APERTURE_PRIORITY),
        @SerialName("shutterPriority")
        SHUTTER_PRIORITY(ThetaRepository.ExposureProgramEnum.SHUTTER_PRIORITY),
        @SerialName("isoPriority")
        ISO_PRIORITY(ThetaRepository.ExposureProgramEnum.ISO_PRIORITY);
    }



    private val implementation = Ricoh360Camera()

    @PluginMethod
    fun initialize(call: PluginCall) {
        val options: JSONObject = call.data
        val decodedOptions: InitializeOptions = try {
            Json.decodeFromJsonElement<InitializeOptions>(options.toKotlinxJsonElement())
        } catch (e: Throwable) {
            Log.e(LOG_TAG, "Cannot parse init options", e)
            call.reject(e.stackTraceToString())
            return
        }
        val thetaConfig = ThetaRepository.Config()
        thetaConfig.language = decodedOptions.language?.lang

        if (decodedOptions.setDateTime) {
            val dateFormat = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                SimpleDateFormat("yyyy:MM:dd HH:mm:ssXXX", Locale.US)
            } else {
                call.reject("VERSION.SDK_INT < N")
                return
            }
            dateFormat.timeZone = TimeZone.getDefault()
            thetaConfig.dateTime = dateFormat.format(Date())
        }

        decodedOptions.sleepDelay?.let {
            if (it < 0) {
                call.reject("sleepDelay cannot be less than 0")
                return
            }
            thetaConfig.sleepDelay = ThetaRepository.SleepDelaySec(it)
        }

        decodedOptions.shutterSound?.let {
            if (it !in 0..100) {
                call.reject("shutterSound not in 0..100")
                return
            }
            thetaConfig.shutterVolume = it
        }

        implementation.initialize(call, decodedOptions.cameraUrl, thetaConfig)
    }

    @PluginMethod
    fun capturePicture(call: PluginCall) {
        val builder = implementation.repo?.getPhotoCaptureBuilder()
        builder?.setWhiteBalance(ThetaRepository.WhiteBalanceEnum.FLUORESCENT)
//            .setExposureProgram(ThetaRepository.ExposureProgramEnum.NORMAL_PROGRAM)
//            .setWhiteBalance(ThetaRepository.WhiteBalanceEnum.AUTO)
// ?.setExposureCompensation(ThetaRepository.ExposureCompensationEnum.ZERO)
//            .setIsoAutoHighLimit(ThetaRepository.IsoAutoHighLimitEnum.ISO_800)
//            .setFilter(ThetaRepository.FilterEnum.HDR)
//            .setExposureDelay(ThetaRepository.ExposureDelayEnum.DELAY_OFF) // self-timer
//            .setFileFormat(ThetaRepository.IMAGE_11K)
//            .build()
        val options: JSONObject = call.data.getJSONObject("options")
        val decodedOptions: InitializeOptions = try {
            Json.decodeFromJsonElement<InitializeOptions>(options.toKotlinxJsonElement())
        } catch (e: Throwable) {
            Log.e(LOG_TAG, "Cannot parse init options", e)
            call.reject(e.stackTraceToString())
            return
        }
    }

    @PluginMethod
    fun livePreview(call: PluginCall) {
        activity?.let { activity ->
            implementation.livePreview(call, activity as AppCompatActivity)
        } ?: run {
            call.reject("Activity not available")
        }
    }

    @PluginMethod
    fun stopLivePreview(call: PluginCall) {
        implementation.stopLivePreview()
        call.resolve()
    }
}
