package com.yzh.wechat.sticker.data

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

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

@Serializable
data class QrTicket(
    val baseResp: WeChatStickerBaseResp, val qrTicket: String
)

@Serializable
data class WeChatStickerBaseResp(
    val repeatedFailRet: List<String>, val ret: Int, val redirectUrl: String = ""
)

@Serializable
data class WeChatStickerResp<T>(
    val data: T, val errCode: Int, val errMsg: String = ""
)

@Serializable
data class StickerListBaseResp(
    val ret: Int, @SerialName("err_msg") val errMsg: String
)

@Serializable
data class WeChatStickerData(
    @SerialName("StikerID") val stickerID: String,
    @SerialName("Name") val name: String,
    @SerialName("DownloadNum") val downloadNum: Int,
    @SerialName("SendNum") val sendNum: String,
    @SerialName("Rewards") val rewards: String,
    @SerialName("ModifyTime") val modifyTime: String,
    @SerialName("Status") val status: Int,
    @SerialName("QueueNum") val queueNum: Int,
    @SerialName("OpenTime") val openTime: String,
    @SerialName("Icon") val icon: String,
    @SerialName("OnlineStatus") val onlineStatus: Int,
    @SerialName("TotalDownloadNum") val totalDownloadNum: String,
    @SerialName("TotalSendNum") val totalSendNum: String,
    @SerialName("DataTime") val dataTime: String
)

@Serializable
data class StickerList(
    @SerialName("base_resp") val baseResp: StickerListBaseResp,
    @SerialName("List") val list: List<WeChatStickerData>,
    @SerialName("EmojiList") val emojiList: List<String> = emptyList(),
    @SerialName("LensList") val lensList: List<String> = emptyList(),
    @SerialName("EmojiLimit") val emojiLimit: String,
    @SerialName("RewardValid") val rewardValid: Int,
    @SerialName("SubmitValid") val submitValid: Int,
    @SerialName("IsInWhitelist") val isInWhitelist: Int,
    @SerialName("AllowPayStatus") val allowPayStatus: Int,
    @SerialName("PayStatus") val payStatus: Int,
    @SerialName("ChangePayContract") val changePayContract: Int,
    @SerialName("ShowIncome") val showIncome: Boolean,
    @SerialName("emoticon_set_list") val emoticonSetList: List<String> = emptyList(),
    @SerialName("await_emoticon_set_list") val awaitEmoticonSetList: List<String> = emptyList()
)
