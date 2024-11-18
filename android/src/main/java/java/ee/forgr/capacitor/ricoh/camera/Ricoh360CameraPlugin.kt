package java.ee.forgr.capacitor.ricoh.camera

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
    data class InitializeOptions(val language: CameraLanguage)

    private val implementation = Ricoh360Camera()

    @PluginMethod
    fun initialize(call: PluginCall) {
        val options: JSONObject = call.getObject("options")
        val decodedOptions = try {
            Json.decodeFromJsonElement<InitializeOptions>(options.toKotlinxJsonElement())
        } catch (e: Throwable) {
            Log.e(LOG_TAG, "Cannot parse init options", e)
            call.reject(e.toString())
        }
        println(decodedOptions)
        call.resolve()
    }
}
