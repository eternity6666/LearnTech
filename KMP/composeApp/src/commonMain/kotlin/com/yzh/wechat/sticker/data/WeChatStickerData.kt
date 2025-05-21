package com.yzh.wechat.sticker.data

import kotlinx.serialization.Serializable

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
    val baseResp: WeChatStickerBaseResp,
    val qrStatus: Int,
    val loginInfo: WeChatStickerLoginInfo? = null
)

@Serializable
data class WeChatStickerLoginInfo(
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
    val baseResp: WeChatStickerBaseResp,
    val qrTicket: String
)

@Serializable
data class WeChatStickerBaseResp(
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