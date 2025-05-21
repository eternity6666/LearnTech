package com.yzh.wechat.sticker

import com.yzh.network.API
import com.yzh.wechat.sticker.data.CheckQrTicketForLogin
import com.yzh.wechat.sticker.data.QrTicket
import com.yzh.wechat.sticker.data.StickerList
import com.yzh.wechat.sticker.data.WeChatStickerResp

class WeChatStickerAPI {

    suspend fun getQrCode(): QrTicket {
        return Request.GetQrCode.queryWebNode()
    }

    suspend fun checkQrTicketForLogin(qrTicket: String): CheckQrTicketForLogin {
        return Request.CheckQrTicketForLogin(qrTicket)
            .queryWebNode<CheckQrTicketForLogin>()
    }

    suspend fun getStickerList(): StickerList {
        return Request.StickerList.query()
    }

    private sealed class Request(
        val type: API.APIType = API.APIType.GET
    ) {
        abstract val cgi: String

        data object GetQrCode : Request() {
            override val cgi: String
                get() = "/cgi-bin/mmemoticonwebnode-bin/api/sticker/home/getQrCode?scene=1"

        }

        data class CheckQrTicketForLogin(
            val qrTicket: String
        ) : Request() {
            override val cgi: String
                get() = "/cgi-bin/mmemoticonwebnode-bin/api/sticker/home/checkQrTicketForLogin?qrTicket=$qrTicket"
        }

        data object StickerList : Request() {
            override val cgi: String
                get() = "/cgi-bin/mmemoticon-bin/home?lang=zh_CN&f=json"
        }
    }

    companion object {
        private const val BASE_URL = "https://sticker.weixin.qq.com"

        private suspend inline fun <reified T> Request.queryWebNode(): T {
            return API.query<WeChatStickerResp<T>>(
                url = "$BASE_URL$cgi",
                type = type
            ).data
        }

        private suspend inline fun <reified T> Request.query(): T {
            return API.query<T>(
                url = "$BASE_URL$cgi",
                type = type
            )
        }

        fun getQrCode(qrTicket: String): String {
            return "$BASE_URL/mobile/login/user?qrTicket=$qrTicket"
        }
    }
}
