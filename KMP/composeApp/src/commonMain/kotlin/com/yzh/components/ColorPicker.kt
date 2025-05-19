package com.yzh.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupProperties

internal data class ColorItem(
    val field: String,
    val value: Float,
    val onValueChange: (Float) -> Unit,
    val colors: List<Color>
)

@Composable
fun ColorPicker(
    color: Color,
    onValueChange: (Color) -> Unit,
    enableAlpha: Boolean = true,
    size: Int = 40
) {
    var showPicker by remember { mutableStateOf(false) }
    Box {
        Box(
            modifier = Modifier.size(size.dp)
                .background(color)
                .clickable(
                    enabled = !showPicker,
                    onClick = { showPicker = true }
                )
        )
        if (showPicker) {
            Popup(
                alignment = Alignment.TopCenter,
                offset = IntOffset(x = 0, y = size),
                onDismissRequest = { showPicker = false },
                properties = PopupProperties()
            ) {
                ColorPickerContent(
                    color,
                    onValueChange,
                    enableAlpha,
                    modifier = Modifier
                        .shadow(elevation = 1.dp, shape = RoundedCornerShape(8.dp))
                        .background(MaterialTheme.colorScheme.background)
                        .padding(8.dp)
                        .width(200.dp)
                )
            }
        }
    }
}

@Composable
fun ColorPickerContent(
    color: Color,
    onValueChange: (Color) -> Unit,
    enableAlpha: Boolean = true,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        mutableListOf(
            ColorItem(
                field = "R",
                value = color.red,
                onValueChange = { onValueChange(color.copy(red = it)) },
                colors = listOf(color.copy(red = 0f), color.copy(red = 1f))
            ),

            ColorItem(
                field = "G",
                value = color.green,
                onValueChange = { onValueChange(color.copy(green = it)) },
                colors = listOf(color.copy(green = 0f), color.copy(green = 1f))
            ),
            ColorItem(
                field = "B",
                value = color.blue,
                onValueChange = { onValueChange(color.copy(blue = it)) },
                colors = listOf(color.copy(blue = 0f), color.copy(blue = 1f))
            ),
        ).also { list ->
            if (enableAlpha) {
                list.add(
                    ColorItem(
                        field = "A",
                        value = color.alpha,
                        onValueChange = { onValueChange(color.copy(alpha = it)) },
                        colors = listOf(color.copy(alpha = 0f), color.copy(alpha = 1f))
                    ),
                )
            }
        }.forEach {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    it.field,
                    modifier = Modifier.width(20.dp)
                )
                CustomSlider(
                    it.value,
                    onValueChange = it.onValueChange,
                    colors = it.colors
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CustomSlider(
    value: Float,
    onValueChange: (Float) -> Unit,
    colors: List<Color>,
    thumbColor: Color = Color.Red
) {
    Slider(
        value = value,
        onValueChange = onValueChange,
        modifier = Modifier.height(20.dp),
        colors = SliderDefaults.colors(
            thumbColor = thumbColor,
            activeTrackColor = Color.Transparent,
            inactiveTrackColor = Color.Transparent
        ),
        track = {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(18.dp)
                    .background(
                        brush = Brush.horizontalGradient(
                            colors = colors
                        )
                    )
            )
        }
    )
}