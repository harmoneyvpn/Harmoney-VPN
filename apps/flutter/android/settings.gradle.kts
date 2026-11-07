pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        maven("https://mirrors.cloud.tencent.com/nexus/repository/maven-public")
        google()
        maven("https://maven.aliyun.com/repository/google")
        maven("https://maven.aliyun.com/repository/public")
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
include(":foxy-native")



// Keep Flutter plugins on the app's AGP version and use a reachable Maven mirror first.
gradle.beforeProject {
    buildscript.repositories.maven {
        name = "TencentMavenMirror"
        url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public")
    }
    buildscript.configurations.getByName("classpath").resolutionStrategy.eachDependency {
        if (requested.group == "com.android.tools.build" && requested.name == "gradle") {
            useVersion("8.11.1")
            because("Align Android plugin buildscript dependencies with the app AGP")
        }
    }
}
