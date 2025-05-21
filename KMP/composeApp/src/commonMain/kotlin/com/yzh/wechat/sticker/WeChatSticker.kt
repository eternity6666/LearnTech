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
import com.yzh.components.QRCode
import com.yzh.wechat.sticker.data.WeChatStickerLoginInfo
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeout

class WeChatStickerViewModel : ViewModel() {
    private val api = WeChatStickerAPI()
    private val _qrTicket: MutableStateFlow<String> = MutableStateFlow("")
    val loginQrCodeUrl = _qrTicket.map { qrTicket ->
        qrTicket.takeIf {
            it.isNotEmpty()
        }?.let {
            api.getQrCode(qrTicket = it)
        }.orEmpty()
    }
    private val _loginInfo: MutableStateFlow<WeChatStickerLoginInfo?> = MutableStateFlow(null)
    val loginInfo = _loginInfo.asStateFlow()
    private var loginJob: Job? = null

    fun login() {
        loginJob?.cancel()
        loginJob = viewModelScope.launch {
            val resp = api.getQrCode()
            val qrTicket = resp.qrTicket
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
                    val resp = api.checkQrTicketForLogin(qrTicket)
                    println(resp)
                    val loginInfo = resp.takeIf { it.qrStatus == 3 }?.loginInfo
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
        val qrCodeUrl by viewModel.loginQrCodeUrl.collectAsState("")
        if (qrCodeUrl.isNotEmpty()) {
            QRCode(qrCodeUrl)
        }
        val loginInfo by viewModel.loginInfo.collectAsState()
        loginInfo?.iconUrl?.takeIf { it.isNotEmpty() }.let {
            AsyncImage(model = it, contentDescription = null)
        }
    }
}
