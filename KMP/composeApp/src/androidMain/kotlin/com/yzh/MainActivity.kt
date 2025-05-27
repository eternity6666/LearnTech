package com.yzh

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import kotlinx.coroutines.withTimeoutOrNull
import kotlin.system.measureTimeMillis

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        setContent {
            App()
        }
        testWithTimeOut()
    }

    private fun testWithTimeOut() {
        lifecycleScope.launch {
            val now = System.currentTimeMillis()
            fun useTime(): Long {
                return System.currentTimeMillis() - now
            }
            fun print(msg: String) {
                println("baron ${useTime()} $msg")
            }
            val job = async {
                print("before withContext")
                withContext(Dispatchers.IO) {
                    print("before delay")
                    delay(1000L)
                    "计算完成".also {
                        print("after delay")
                    }
                }.also {
                    print("after withContext")
                }
            }
            delay(500L)
            val time = measureTimeMillis {
                val result = withTimeoutOrNull(500L) {
                    print("before await")
                    job.await().also {
                        print("after await")
                    }
                }
                print("result=$result")
            }
            print("time=$time")
        }
    }
}
