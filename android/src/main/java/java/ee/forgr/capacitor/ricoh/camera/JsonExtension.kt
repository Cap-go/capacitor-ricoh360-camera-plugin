package java.ee.forgr.capacitor.ricoh.camera

import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import org.json.JSONArray
import org.json.JSONObject

fun JSONObject.toKotlinxJsonObject(): JsonObject {
    val map = mutableMapOf<String, JsonElement>()
    for (key in keys()) {
        val value = get(key)
        map[key] = value.toKotlinxJsonElement()
    }
    return JsonObject(map)
}

/**
 * Extension function to convert an org.json.JSONArray to a kotlinx.serialization.json.JsonArray.
 */
fun JSONArray.toKotlinxJsonArray(): JsonArray {
    val list = mutableListOf<JsonElement>()
    for (i in 0 until length()) {
        val value = get(i)
        list.add(value.toKotlinxJsonElement())
    }
    return JsonArray(list)
}

/**
 * Extension function to convert various org.json types to a kotlinx.serialization.json.JsonElement.
 */
fun Any?.toKotlinxJsonElement(): JsonElement = when (this) {
    is JSONObject -> this.toKotlinxJsonObject()
    is JSONArray -> this.toKotlinxJsonArray()
    is String -> JsonPrimitive(this)
    is Number -> JsonPrimitive(this)
    is Boolean -> JsonPrimitive(this)
    JSONObject.NULL, null -> JsonNull
    else -> throw IllegalArgumentException("Unsupported type: ${this.javaClass}")
}
