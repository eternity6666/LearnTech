package com.yzh.network

import com.yzh.network.API.APIType.GET
import com.yzh.network.API.APIType.POST
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.cookies.CookiesStorage
import io.ktor.client.plugins.cookies.HttpCookies
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

object API {
    val httpClient = HttpClient {
        install(ContentNegotiation) {
            json(Json {
                isLenient = true
                ignoreUnknownKeys = true
            })
        }
        install(HttpCookies) {
            storage = FileCookiesStorage()
        }
        install(Logging)
    }

    suspend inline fun <reified T> query(
        url: String,
        type: APIType = GET
    ): T {
        return when (type) {
            GET -> get(url)
            POST -> post(url)
        }
    }

    suspend inline fun <reified T> get(url: String): T {
        return httpClient.get(urlString = url).body<T>()
    }

    suspend inline fun <reified T> post(url: String): T {
        return httpClient.post(urlString = url).body<T>()
    }

    enum class APIType {
        GET,
        POST
    }
}

expect class FileCookiesStorage() : CookiesStorage