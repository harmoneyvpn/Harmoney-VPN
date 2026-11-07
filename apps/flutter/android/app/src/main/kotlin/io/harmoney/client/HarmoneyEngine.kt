package io.harmoney.client

import android.content.Context
import dalvik.system.DexClassLoader
import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest

/** Exact GoMobile bindings and JNI from the official ARM64 release, not the stub. */
internal object HarmoneyEngine {
    private const val BINDINGS_SHA256 = "331b97d20662d5980aa12bd616b8bfa5f3236e1014519fd1b9a8566604364299"
    private const val NATIVE_SHA256 = "129c81b3b37d2c49d9f189116aa54cffce2199b0921d103d71de61bf01e96c90"
    private var api: Class<*>? = null
    private var progressListener: Any? = null

    @Synchronized fun load(context: Context): Class<*> {
        api?.let { return it }
        val native = File(context.applicationInfo.nativeLibraryDir, "libgojni.so")
        check(native.isFile) {
            "Harmoney native engine is unavailable for this device architecture"
        }
        val nativeDigest = MessageDigest.getInstance("SHA-256")
        native.inputStream().use { stream ->
            val buffer = ByteArray(65536)
            var count = stream.read(buffer)
            while (count >= 0) {
                nativeDigest.update(buffer, 0, count)
                count = stream.read(buffer)
            }
        }
        check(nativeDigest.digest().joinToString("") { "%02x".format(it) } == NATIVE_SHA256) {
            "Harmoney native engine failed integrity verification"
        }
        val bytes = context.assets.open("harmoney/dxcore-bindings.jar").use { it.readBytes() }
        val digest = MessageDigest.getInstance("SHA-256").digest(bytes)
            .joinToString("") { "%02x".format(it) }
        check(digest == BINDINGS_SHA256) { "Harmoney engine bindings failed integrity verification" }
        val directory = File(context.codeCacheDir, "harmoney").apply { mkdirs() }
        val target = File(directory, "bindings-$BINDINGS_SHA256.jar")
        if (target.exists()) target.delete()
        // Android 14 requires dynamically loaded DEX files to be read-only.
        FileOutputStream(target).use { stream ->
            check(target.setReadOnly())
            stream.write(bytes)
        }
        val loader = DexClassLoader(target.absolutePath, directory.absolutePath,
            context.applicationInfo.nativeLibraryDir, context.classLoader)
        val seq = Class.forName("go.Seq", true, loader)
        seq.getMethod("setContext", Context::class.java).invoke(null, context.applicationContext)
        return Class.forName("android.Android", true, loader).also { engine ->
            api = engine
            val listenerType = Class.forName("android.ProgressListener", true, loader)
            progressListener = java.lang.reflect.Proxy.newProxyInstance(loader, arrayOf(listenerType)) {
                proxy, method, args -> when (method.name) {
                    "onProgress" -> {
                        // The callback can contain proxy URIs. Always sanitize
                        // before sending any part to logcat/support bundles.
                        val message = AndroidEventLogger.redactSecrets(args?.firstOrNull()?.toString().orEmpty())
                        AndroidEventLogger.info("HarmoneyEngine", "ENGINE", message.take(1000), protocol = "harmoney")
                        null
                    }
                    "toString" -> "HarmoneyProgressListener"
                    "hashCode" -> System.identityHashCode(proxy)
                    "equals" -> proxy === args?.firstOrNull()
                    else -> null
                }
            }
            engine.getMethod("setProgressListener", listenerType).invoke(null, progressListener)
        }
    }

    fun invoke(context: Context, method: String, vararg args: Any): Any? {
        val types = args.map {
            when (it) {
                is Boolean -> Boolean::class.javaPrimitiveType!!
                is Long -> Long::class.javaPrimitiveType!!
                else -> it.javaClass
            }
        }.toTypedArray()
        return load(context).getMethod(method, *types).invoke(null, *args)
    }
}
