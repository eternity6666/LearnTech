package com.yzh.network

import io.ktor.client.plugins.cookies.CookiesStorage
import io.ktor.http.Cookie
import io.ktor.http.Url

actual class FileCookiesStorage : CookiesStorage {
    override suspend fun addCookie(requestUrl: Url, cookie: Cookie) {
        TODO("Not yet implemented")
    }

    override fun close() {
        TODO("Not yet implemented")
    }

    override suspend fun get(requestUrl: Url): List<Cookie> {
        TODO("Not yet implemented")
    }
}