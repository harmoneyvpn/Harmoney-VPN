plugins {
    id("com.android.library")
}

val hevVersion = "2.17.1"
val hevDir = file("src/main/jni")
val fetchHev = tasks.register<Exec>("fetchHevSocks5Tunnel") {
    val marker = File(hevDir, "Android.mk")
    outputs.file(marker)
    onlyIf { !marker.exists() }
    doFirst { hevDir.mkdirs() }
    commandLine(
        "git", "clone", "--branch", hevVersion, "--depth", "1", "--recursive",
        "--shallow-submodules", "https://github.com/heiher/hev-socks5-tunnel.git",
        hevDir.absolutePath,
    )
}

tasks.matching { it.name.startsWith("externalNativeBuild") || it.name.contains("NdkBuild") }
    .configureEach { dependsOn(fetchHev) }
tasks.named("preBuild").configure { dependsOn(fetchHev) }

android {
    namespace = "io.harmoney.client.foxy.nativeengine"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    defaultConfig {
        minSdk = 26
        externalNativeBuild {
            ndkBuild {
                abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64", "x86")
                arguments += listOf(
                    "APP_PLATFORM=android-26",
                    "APP_CFLAGS=-DPKGNAME=io/harmoney/client/firefox/vpn/tun -DCLSNAME=HevSocks5Tunnel",
                )
            }
        }
    }

    externalNativeBuild {
        ndkBuild { path = file("src/main/jni/Android.mk") }
    }
}
