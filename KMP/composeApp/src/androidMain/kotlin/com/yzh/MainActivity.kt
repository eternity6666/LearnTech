package com.yzh

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.core.os.postDelayed
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.async
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import kotlin.time.measureTimedValue

class MainActivity : ComponentActivity() {
    val mainScope = MainScope()
    val mainScope2 = MainScope()
    private var job: Deferred<Unit>? = null
    val now by lazy {
        System.currentTimeMillis()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContent {
            App()
        }
        val handler = Handler(Looper.getMainLooper())
        now
        handler.postDelayed(1000L) {
            testWithTimeOut()
        }
        handler.postDelayed(3000L) {
            loadUrl()
        }
    }

    private fun print(msg: String) {
        println("用时=${System.currentTimeMillis() - now} $msg")
    }

    private fun testWithTimeOut() {
        var calcResult = ""
        mainScope.launch {
            job = async {
                print("计算开始")
                withContext(Dispatchers.IO) {
                    delay(2490L)
                    calcResult = "计算结果"
                }.also {
                    print("计算完成")
                }
                job = null
            }
            job?.await()
        }

        mainScope2.launch {
            async {
                withContext(Dispatchers.IO) {
                    print("其他耗时任务开始")
                    delay(6000L)
                    print("其他耗时任务结束")
                }
            }
        }
    }

    private fun loadUrl() {
        mainScope.launch {
            measureTimedValue {
                print("等待开始")
                waitResult()
            }.also {
                print("等待耗时:${it.duration.inWholeMilliseconds}")
            }
        }
    }

    private suspend fun waitResult() {
        val job = this.job ?: return
        val result = withTimeoutOrNull(500L) {
            job.await()
        }
        this.job = null
        if (result == null) {
            print("等待超时")
        } else {
            print("等待未超时")
        }
    }
}
