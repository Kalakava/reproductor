package io.onda.reproductor

import android.content.Intent
import android.net.Uri
import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : AudioServiceFragmentActivity() {
    private val CHANNEL = "io.onda.reproductor/file_manager"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openFolder") {
                val path = call.argument<String>("path")
                if (path != null) {
                    val opened = openFolderInManager(path)
                    result.success(opened)
                } else {
                    result.error("BAD_ARGS", "Path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun openFolderInManager(path: String): Boolean {
        return try {
            val file = File(path)
            if (!file.exists()) return false

            val primaryPrefix = "/storage/emulated/0"
            val isDirectory = file.isDirectory

            if (!isDirectory) {
                // Si es un archivo, intentamos primero abrir el URI del documento del propio archivo 
                // con tipo vnd.android.document/directory. Esto hace que DocumentsUI abra la carpeta
                // padre y enfoque/resalte este archivo específico.
                try {
                    val rawPath = file.absolutePath
                    val documentId = if (rawPath.startsWith(primaryPrefix)) {
                        "primary:" + rawPath.substring(primaryPrefix.length).trimStart('/')
                    } else {
                        "primary:"
                    }
                    val uri = Uri.parse("content://com.android.externalstorage.documents/document/" + Uri.encode(documentId))
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        setDataAndType(uri, "vnd.android.document/directory")
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    return true
                } catch (e: Exception) {
                    // Fallback al comportamiento de carpeta padre si falla
                }
            }

            // Abrir la carpeta padre (o el propio directorio si es carpeta)
            val folderFile = if (isDirectory) file else file.parentFile
            if (folderFile != null && folderFile.exists()) {
                val rawFolderPath = folderFile.absolutePath
                val folderDocId = if (rawFolderPath.startsWith(primaryPrefix)) {
                    "primary:" + rawFolderPath.substring(primaryPrefix.length).trimStart('/')
                } else {
                    "primary:"
                }
                val uri = Uri.parse("content://com.android.externalstorage.documents/document/" + Uri.encode(folderDocId))
                val intent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, "vnd.android.document/directory")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            try {
                val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                    type = "*/*"
                    addCategory(Intent.CATEGORY_OPENABLE)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                true
            } catch (ex: Exception) {
                false
            }
        }
    }
}

