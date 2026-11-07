import com.android.build.api.dsl.ApplicationExtension
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningPropertiesFile = rootProject.file("key.properties")
val releaseSigningProperties = Properties().apply {
    if (releaseSigningPropertiesFile.isFile) {
        releaseSigningPropertiesFile.inputStream().use(::load)
    }
}
val releaseStorePath = releaseSigningProperties.getProperty("storeFile")
val releaseSigningConfigured = !releaseStorePath.isNullOrBlank() &&
    !releaseSigningProperties.getProperty("storePassword").isNullOrBlank() &&
    !releaseSigningProperties.getProperty("keyAlias").isNullOrBlank() &&
    !releaseSigningProperties.getProperty("keyPassword").isNullOrBlank()

extensions.configure<ApplicationExtension> {
    namespace = "io.harmoney.client"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "io.harmoney.client.github"
        // FoxyVPN's real VpnService/data plane targets Android 8+ APIs.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildFeatures { buildConfig = true }

    sourceSets.getByName("main") {
        jniLibs.srcDir("src/main/jniLibs")
    }

    packaging {
        jniLibs.useLegacyPackaging = true
        // Preserve the official engine bytes for runtime SHA256 verification.
        jniLibs.keepDebugSymbols += "**/libgojni.so"
        resources.excludes += setOf(
            "META-INF/INDEX.LIST",
            "META-INF/*.SF",
            "META-INF/*.DSA",
            "META-INF/*.RSA",
        )
        resources.pickFirsts += "META-INF/io.netty.versions.properties"
    }

    buildTypes {
        getByName("release") {
            if (releaseSigningConfigured) {
                signingConfig = signingConfigs.create("release").apply {
                    storeFile = rootProject.file(releaseStorePath!!)
                    storePassword = releaseSigningProperties.getProperty("storePassword")
                    keyAlias = releaseSigningProperties.getProperty("keyAlias")
                    keyPassword = releaseSigningProperties.getProperty("keyPassword")
                }
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}

repositories {
    maven(url = "https://jitpack.io")
}

flutter {
    source = "../.."
}

dependencies {
    implementation(project(":foxy-native"))
    implementation("androidx.core:core-ktx:1.17.0")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    implementation("io.netty:netty-handler:4.1.115.Final")
    implementation("io.netty:netty-codec-http2:4.1.115.Final")
    implementation("io.netty:netty-transport:4.1.115.Final")
    implementation("io.netty:netty-handler-proxy:4.1.115.Final")
    implementation("org.conscrypt:conscrypt-android:2.5.2")
    implementation("com.google.protobuf:protobuf-javalite:4.33.0")
    testImplementation("junit:junit:4.13.2")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
