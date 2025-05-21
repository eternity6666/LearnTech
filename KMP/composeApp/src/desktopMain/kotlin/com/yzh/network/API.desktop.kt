package com.yzh.network

import io.ktor.client.plugins.cookies.CookiesStorage
import io.ktor.client.plugins.cookies.fillDefaults
import io.ktor.client.plugins.cookies.matches
import io.ktor.http.Cookie
import io.ktor.http.Url
import io.ktor.http.parseServerSetCookieHeader
import io.ktor.http.renderSetCookieHeader
import io.ktor.util.date.getTimeMillis
import java.io.File
import java.util.concurrent.atomic.AtomicLong
import kotlin.math.min
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

actual class FileCookiesStorage: CookiesStorage {
    private data class CookieWithTimestamp(val cookie: Cookie, val createdAt: Long)

    private val container: MutableList<CookieWithTimestamp> = mutableListOf()
    private val oldestCookie: AtomicLong = AtomicLong(0L)
    private val mutex = Mutex()
    val clock: () -> Long = { getTimeMillis() }

    init {
        readFromFile()
    }

    private val defaultFile: File
        get() {
            return File("KMP_FileCookiesStorage")
        }

    private fun readFromFile() {
        val file = defaultFile
        if (file.exists()) {
            file.readLines().forEach { line ->
                line.split(",").takeIf {
                    it.size == 2
                }?.let {
                    val cookie = it[0] as? String
                    val time = it[1].toLongOrNull()
                    if (cookie != null && time != null) {
                        cookie to time
                    } else {
                        null
                    }
                }?.let {
                    container.add(
                        CookieWithTimestamp(
                            parseServerSetCookieHeader(it.first),
                            it.second
                        )
                    )
                }
            }
        }
    }

    private fun writeToFile() {
        if (container.isEmpty()) {
            return
        }
        val file = defaultFile
        if (!file.exists()) {
            kotlin.runCatching {
                file.createNewFile()
            }.onFailure {
                println("writeToFile ${it.stackTraceToString()}")
            }
        }
        if (file.exists()) {
            file.writeText("")
            container.forEach { item ->
                val cookie = renderSetCookieHeader(item.cookie)
                file.appendText("$cookie,${item.createdAt}\n")
            }
        }
    }

    override suspend fun addCookie(requestUrl: Url, cookie: Cookie) {
        with(cookie) {
            if (name.isBlank()) return
        }

        mutex.withLock {
            container.removeAll { (existingCookie, _) ->
                existingCookie.name == cookie.name && existingCookie.matches(requestUrl)
            }

            val createdAt = clock()
            container.add(
                CookieWithTimestamp(
                    cookie.fillDefaults(requestUrl),
                    createdAt
                )
            )
            cookie.maxAgeOrExpires(createdAt)?.let {
                if (oldestCookie.get() > it) {
                    oldestCookie.set(it)
                }
            }
            writeToFile()
        }
    }

    override fun close() {
    }

    override suspend fun get(requestUrl: Url): List<Cookie> = mutex.withLock {
        val now = clock()
        if (now >= oldestCookie.get()) cleanup(now)

        val cookies = container.filter { it.cookie.matches(requestUrl) }.map { it.cookie }
        return@withLock cookies
    }

    private fun cleanup(timestamp: Long) {
        container.removeAll { (cookie, createdAt) ->
            val expires = cookie.maxAgeOrExpires(createdAt) ?: return@removeAll false
            expires < timestamp
        }

        val newOldest = container.fold(Long.MAX_VALUE) { acc, (cookie, createdAt) ->
            cookie.maxAgeOrExpires(createdAt)?.let { min(acc, it) } ?: acc
        }

        oldestCookie.set(newOldest)
        writeToFile()
    }

    private fun Cookie.maxAgeOrExpires(createdAt: Long): Long? =
        maxAge?.let { createdAt + it * 1000L } ?: expires?.timestamp
}