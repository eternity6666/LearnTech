package com.yzh

import androidx.compose.ui.graphics.Color
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch

class StickerViewModel : ViewModel() {
    private val data: MutableStateFlow<Data> = MutableStateFlow(Data())
    val text: Flow<String> = data.map { it.text }

    val itemList: Flow<List<String>>
        get() = text.map {
            it.split(";")
        }

    fun update(action: Action) {
        viewModelScope.launch {
            when (action) {
                is Action.InputText -> data.emit(data.value.copy(text = action.value))
            }
        }
    }

    data class Data(
        val text: String = "",
        val textColor: Color = Color.Green,
        val title: String = "",
        val subTitle: String = "",
    )

    sealed class Action {
        class InputText(val value: String) : Action()
    }
}