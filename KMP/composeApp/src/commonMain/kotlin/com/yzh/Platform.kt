package com.yzh

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform