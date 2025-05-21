package com.yzh.wechat.sticker

import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.scrollable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import coil3.compose.AsyncImage
import com.yzh.components.QRCode
import com.yzh.wechat.sticker.data.StickerList
import com.yzh.wechat.sticker.data.WeChatStickerData
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
            WeChatStickerAPI.getQrCode(qrTicket = it)
        }.orEmpty()
    }
    private val _loginInfo: MutableStateFlow<WeChatStickerLoginInfo?> = MutableStateFlow(null)
    val loginInfo = _loginInfo.asStateFlow()
    private val _stickerList: MutableStateFlow<StickerList?> = MutableStateFlow(null)
    val stickerList = _stickerList.asStateFlow()
    private var loginJob: Job? = null

    init {
        viewModelScope.launch {
            queryList()
        }
    }

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
            queryList()
        }
    }

    private suspend fun queryList() {
        runCatching {
            val stickerList = api.getStickerList()
            println("queryList $stickerList")
            if (stickerList.baseResp.ret == 0) {
                _stickerList.emit(stickerList)
            }
        }.onFailure {
            println("queryList ${it.stackTraceToString()}")
        }
    }
}

@Composable
fun WeChatSticker() {
    val viewModel = remember { WeChatStickerViewModel() }
    val qrCodeUrl by viewModel.loginQrCodeUrl.collectAsState("")
    val loginInfo by viewModel.loginInfo.collectAsState()
    val stickerList by viewModel.stickerList.collectAsState()
    LazyColumn(
        verticalArrangement = Arrangement.spacedBy(10.dp, Alignment.Top)
    ) {
        item {
            Button(onClick = {
                viewModel.login()
            }) {
                Text("Login")
            }
        }
        if (qrCodeUrl.isNotEmpty()) {
            item {
                QRCode(qrCodeUrl)
            }
        }
        loginInfo?.iconUrl?.takeIf { it.isNotEmpty() }?.let {
            item {
                AsyncImage(model = it, contentDescription = null)
            }
        }
        stickerList?.let { list ->
            item {
                val rowScrollableState = rememberScrollState(0)
                Row(
                    modifier = Modifier.scrollable(
                        rowScrollableState,
                        orientation = Orientation.Horizontal
                    ),
                    horizontalArrangement = Arrangement.spacedBy(10.dp, Alignment.Start)
                ) {
                    Text("EmojiLimit: ${list.emojiLimit}")
                    Text("RewardValid: ${list.rewardValid}")
                    Text("SubmitValid: ${list.submitValid}")
                    Text("IsInWhitelist: ${list.isInWhitelist}")
                    Text("AllowPayStatus: ${list.allowPayStatus}")
                    Text("PayStatus: ${list.payStatus}")
                    Text("ChangePayContract: ${list.changePayContract}")
                    Text("ShowIncome: ${list.showIncome}")
                }
            }
            items(list.list) { item ->
                StickerItemView(item)
            }
        }
    }
}

@Composable
private fun StickerItemView(item: WeChatStickerData) {
    Column(
        modifier = Modifier.padding(10.dp)
            .shadow(1.dp)
            .clip(RoundedCornerShape(10.dp)),
        verticalArrangement = Arrangement.spacedBy(10.dp, Alignment.Top)
    ) {
        Row(
            modifier = Modifier.padding(10.dp)
        ) {
            AsyncImage(
                model = "https://sticker.weixin.qq.com/cgi-bin/mmemoticon-bin/getmedia?fileid=${item.icon}".also {
                    println(it)
                },
                contentDescription = "",
                modifier = Modifier.size(40.dp)
                    .clip(RoundedCornerShape(8.dp)),
                onState = { state ->
                    println("StickerItemView AsyncImage $state")
                }
            )
            Column {
                Row {
                    Text("Name")
                    Text(item.name)
                }
                Row {
                    Text("StikerID")
                    Text(item.stickerID)
                }
            }
            Column {
                Text("DownloadNum")
                Text("${item.downloadNum}")
            }
            Column {
                Text("SendNum")
                Text("${item.sendNum}")
            }
            Column {
                Text("Rewards")
                Text("${item.rewards}")
            }
            Column {
                Text("Status")
                Text("${item.status}")
            }
            Column {
                Text("QueueNum")
                Text("${item.queueNum}")
            }
            Column {
                Text("OnlineStatus")
                Text("${item.onlineStatus}")
            }
            Column {
                Text("TotalDownloadNum")
                Text("${item.totalDownloadNum}")
            }
            Column {
                Text("TotalSendNum")
                Text("${item.totalSendNum}")
            }
        }
        Row(
            modifier = Modifier.padding(10.dp)
        ) {
            Column {
                Text("ModifyTime")
                Text("${item.modifyTime}")
            }
            Column {
                Text("OpenTime")
                Text("${item.openTime}")
            }
            Column {
                Text("DataTime")
                Text("${item.dataTime}")
            }
        }
    }
}