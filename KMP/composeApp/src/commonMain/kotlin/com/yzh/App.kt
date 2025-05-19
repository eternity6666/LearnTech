package com.yzh

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import com.yzh.wechat.sticker.WeChatSticker
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
@Preview
fun App() {
    MaterialTheme {
        WeChatSticker()
    }
}

@Composable
fun StickerMaker() {
    val viewModel = remember { StickerViewModel() }
    val text = viewModel.text.collectAsState("")
    Column {
        TextField(
            value = text.value,
            onValueChange = {
                viewModel.update(StickerViewModel.Action.InputText(it))
            },
            modifier = Modifier.fillMaxWidth()
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
//                ColorPicker(
//                    color,
//                    onValueChange = { color = it }
//                )
//                ColorPicker(
//                    color,
//                    onValueChange = { color = it }
//                )
        }
    }
}