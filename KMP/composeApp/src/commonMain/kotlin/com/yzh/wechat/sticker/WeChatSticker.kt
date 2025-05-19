package com.yzh.wechat.sticker

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import coil3.compose.AsyncImage
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeout
import kotlinx.serialization.Serializable
import qrgenerator.QRCodeImage

class WeChatStickerViewModel : ViewModel() {
    private val httpClient = HttpClient {
        install(ContentNegotiation) {
            json()
        }
    }
    private val _qrTicket: MutableStateFlow<String> = MutableStateFlow("")
    val qrTicket = _qrTicket.asStateFlow()
    private val _loginInfo: MutableStateFlow<LoginInfo?> = MutableStateFlow(null)
    val loginInfo = _loginInfo.asStateFlow()

    fun login() {
        viewModelScope.launch {
            val data = httpClient.get(
                "https://sticker.weixin.qq.com/cgi-bin/mmemoticonwebnode-bin/api/sticker/home/getQrCode?scene=1"
            )
            val resp = data.body<WeChatStickerResp<QrTicket>>()
            val qrTicket = resp.data.qrTicket
            println("qrTicket=$qrTicket")
            if (qrTicket.isNotEmpty()) {
                _qrTicket.emit(qrTicket)
                queryLoginSuccess(qrTicket)
            }
        }
    }

    private suspend fun queryLoginSuccess(qrTicket: String) {
        runCatching {
            withTimeout(60 * 1000) {
                while (true) {
                    println("queryLoginSuccess qrTicket=$qrTicket")
                    val resp = httpClient.get(
                        "https://sticker.weixin.qq.com/cgi-bin/mmemoticonwebnode-bin/api/sticker/home/checkQrTicketForLogin?qrTicket=$qrTicket"
                    )
                    val data = resp.body<WeChatStickerResp<CheckQrTicketForLogin>>().data
                    println(data)
                    val loginInfo = data.takeIf { it.qrStatus == 3 }?.loginInfo
                    if (loginInfo != null) {
                        _loginInfo.emit(loginInfo)
                        break
                    } else {
                        delay(1000L)
                    }
                }
            }
        }.onFailure {
            println("超时 ${it.stackTraceToString()}")
        }.onSuccess {
            println(it)
        }
    }
}

/*
{
    "data":{
        "baseResp":{
            "repeatedFailRet":[],
            "ret":0,
            "redirectUrl":""
        },
        "qrStatus":3,
        "loginInfo":{
            "iconUrl":"http://wx.qlogo.cn/finderhead/Q3auHgzwzM5MUKfdOno7aDPJXfruyZic4TlLw7FCt88QcPnELr02wgQ/0"
        }
    },
    "errCode":0
}
 */
@Serializable
data class CheckQrTicketForLogin(
    val baseResp: BaseResp,
    val qrStatus: Int,
    val loginInfo: LoginInfo? = null
)

@Serializable
data class LoginInfo(
    val iconUrl: String
)

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
    val ret: Int,
    val redirectUrl: String = ""
)

@Serializable
data class WeChatStickerResp<T>(
    val data: T,
    val errCode: Int,
    val errMsg: String = ""
)

@Composable
fun WeChatSticker() {
    val viewModel = remember { WeChatStickerViewModel() }
    Column {
        Button(
            onClick = {
                viewModel.login()
            }
        ) {
            Text("Login")
        }
        val qrTicket by viewModel.qrTicket.collectAsState()
        if (qrTicket.isNotEmpty()) {
            QRCodeImage(
                "https://sticker.weixin.qq.com/cgi-bin/mmemoticonwebnode-bin/mobile/login/user?qrTicket=$qrTicket",
                contentDescription = "二维码"
            )
        }
        val loginInfo by viewModel.loginInfo.collectAsState()
        loginInfo?.iconUrl?.takeIf { it.isNotEmpty() }.let {
            AsyncImage(model = it, contentDescription = null)
        }
    }
}
