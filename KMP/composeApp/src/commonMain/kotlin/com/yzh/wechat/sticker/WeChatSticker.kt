package com.yzh.wechat.sticker

import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable

class WeChatStickerViewModel : ViewModel() {
    private val httpClient = HttpClient {
        install(ContentNegotiation) {
            json()
        }
    }

    fun login() {
        viewModelScope.launch {
            val data =
                httpClient.get("https://sticker.weixin.qq.com/cgi-bin/mmemoticonwebnode-bin/api/sticker/home/getQrCode?scene=1")
            val resp = data.body<WeChatStickerResp<QrTicket>>()
            println(resp.data.qrTicket)
        }
    }
}

/*

        "baseResp": {
            "repeatedFailRet": [],
            "ret": 0
        },
        "qrTicket": "ek1HMlFMK3hCVHBZWTYvajlUQ2lDQT09"
 */
@Serializable
data class QrTicket(
    val baseResp: BaseResp,
    val qrTicket: String
)

@Serializable
data class BaseResp(
    val repeatedFailRet: List<String>,
    val ret: Int
)

@Serializable
data class WeChatStickerResp<T>(
    val data: T,
    val errCode: Int,
    val errMsg: String
)

@Composable
fun WeChatSticker() {
    val viewModel = remember { WeChatStickerViewModel() }

    Button(onClick = {
        viewModel.login()
    }) {
        Text("Login")
    }
}