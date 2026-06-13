package io.onda.reproductor

import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : AudioServiceFragmentActivity() {
    private val CHANNEL = "io.onda.reproductor/file_manager"
    
    private val REQUEST_DELETE_PERMISSION = 1002
    private val REQUEST_WRITE_PERMISSION = 1003
    
    private var pendingResult: MethodChannel.Result? = null
    private var pendingRenameValues: ContentValues? = null
    private var pendingRenameUri: Uri? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openFolder" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        val opened = openFolderInManager(path)
                        result.success(opened)
                    } else {
                        result.error("BAD_ARGS", "Path is null", null)
                    }
                }
                "deleteSong" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        deleteSongFromDevice(path, result)
                    } else {
                        result.error("BAD_ARGS", "Path is null", null)
                    }
                }
                "renameSong" -> {
                    val path = call.argument<String>("path")
                    val newTitle = call.argument<String>("newTitle")
                    val newFileName = call.argument<String>("newFileName")
                    if (path != null && newTitle != null && newFileName != null) {
                        renameSongInDevice(path, newTitle, newFileName, result)
                    } else {
                        result.error("BAD_ARGS", "Missing arguments", null)
                    }
                }
                "compressCoverImage" -> {
                    val sourcePath = call.argument<String>("sourcePath")
                    val songId = call.argument<String>("songId")
                    if (sourcePath != null && songId != null) {
                        val localPath = compressImageToWebP(sourcePath, songId)
                        result.success(localPath)
                    } else {
                        result.error("BAD_ARGS", "Missing arguments", null)
                    }
                }
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        val opened = openUrlInBrowser(url)
                        result.success(opened)
                    } else {
                        result.error("BAD_ARGS", "Url is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun openUrlInBrowser(url: String): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun getContentUriFromFilePath(path: String): Uri? {
        val cursor = contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            arrayOf(MediaStore.Audio.Media._ID),
            MediaStore.Audio.Media.DATA + "=? ",
            arrayOf(path),
            null
        )
        if (cursor != null && cursor.moveToFirst()) {
            val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID))
            cursor.close()
            return ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)
        }
        cursor?.close()
        return null
    }

    private fun openFolderInManager(path: String): Boolean {
        return try {
            val file = File(path)
            val canonicalPath = file.canonicalPath
            val primaryPrefix = "/storage/emulated/0"
            val isDirectory = file.isDirectory

            if (!isDirectory) {
                // Si es un archivo, intentamos primero abrir el URI del documento del propio archivo 
                // con tipo vnd.android.document/directory. Esto hace que DocumentsUI abra la carpeta
                // padre y enfoque/resalte este archivo específico.
                try {
                    val documentId = if (canonicalPath.startsWith(primaryPrefix)) {
                        "primary:" + canonicalPath.substring(primaryPrefix.length).trimStart('/')
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
            if (folderFile != null) {
                val rawFolderPath = folderFile.canonicalPath
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

    private fun deleteSongFromDevice(path: String, result: MethodChannel.Result) {
        try {
            val file = File(path)
            val uri = getContentUriFromFilePath(path)
            if (uri == null) {
                // Si no está en el MediaStore, intentamos borrarlo directamente (almacenamiento privado)
                val deleted = file.delete()
                result.success(deleted)
                return
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // Android 11+
                val uris = listOf(uri)
                val pendingIntent = MediaStore.createDeleteRequest(contentResolver, uris)
                pendingResult = result
                startIntentSenderForResult(
                    pendingIntent.intentSender,
                    REQUEST_DELETE_PERMISSION,
                    null, 0, 0, 0
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10
                try {
                    contentResolver.delete(uri, null, null)
                    result.success(true)
                } catch (securityException: SecurityException) {
                    val recoverableSecurityException = securityException as? RecoverableSecurityException
                        ?: throw securityException
                    val intentSender = recoverableSecurityException.userAction.actionIntent.intentSender
                    pendingResult = result
                    startIntentSenderForResult(
                        intentSender,
                        REQUEST_DELETE_PERMISSION,
                        null, 0, 0, 0
                    )
                }
            } else {
                // Android 9 y anteriores: borrado directo por File
                val deleted = file.delete()
                if (deleted) {
                    contentResolver.delete(uri, null, null)
                }
                result.success(deleted)
            }
        } catch (e: Exception) {
            result.error("DELETE_FAILED", e.message, null)
        }
    }

    private fun renameSongInDevice(path: String, newTitle: String, newFileName: String, result: MethodChannel.Result) {
        try {
            val file = File(path)
            val uri = getContentUriFromFilePath(path)
            if (uri == null) {
                // Si no está en el MediaStore, intentamos renombrarlo físicamente
                val parent = file.parentFile
                val newFile = File(parent, newFileName)
                val renamed = file.renameTo(newFile)
                result.success(renamed)
                return
            }

            val values = ContentValues().apply {
                put(MediaStore.Audio.Media.DISPLAY_NAME, newFileName)
                put(MediaStore.Audio.Media.TITLE, newTitle)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // Android 11+
                val uris = listOf(uri)
                val pendingIntent = MediaStore.createWriteRequest(contentResolver, uris)
                pendingResult = result
                pendingRenameUri = uri
                pendingRenameValues = values
                startIntentSenderForResult(
                    pendingIntent.intentSender,
                    REQUEST_WRITE_PERMISSION,
                    null, 0, 0, 0
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10
                try {
                    contentResolver.update(uri, values, null, null)
                    result.success(true)
                } catch (securityException: SecurityException) {
                    val recoverableSecurityException = securityException as? RecoverableSecurityException
                        ?: throw securityException
                    val intentSender = recoverableSecurityException.userAction.actionIntent.intentSender
                    pendingResult = result
                    pendingRenameUri = uri
                    pendingRenameValues = values
                    startIntentSenderForResult(
                        intentSender,
                        REQUEST_WRITE_PERMISSION,
                        null, 0, 0, 0
                    )
                }
            } else {
                // Android 9 y anteriores: renombrar directamente
                val parent = file.parentFile
                val newFile = File(parent, newFileName)
                val renamed = file.renameTo(newFile)
                if (renamed) {
                    contentResolver.update(uri, values, null, null)
                }
                result.success(renamed)
            }
        } catch (e: Exception) {
            result.error("RENAME_FAILED", e.message, null)
        }
    }

    private fun compressImageToWebP(sourcePath: String, songId: String): String? {
        return try {
            val file = File(sourcePath)
            if (!file.exists()) return null

            val bitmap = BitmapFactory.decodeFile(file.absolutePath)
            if (bitmap == null) return null

            // Redimensionar a 200x200 píxeles
            val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 200, 200, true)
            val outFileName = "cover_$songId.webp"
            val destFile = File(filesDir, outFileName)
            
            val outStream = FileOutputStream(destFile)
            resizedBitmap.compress(Bitmap.CompressFormat.WEBP, 70, outStream)
            outStream.flush()
            outStream.close()

            destFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_DELETE_PERMISSION) {
            if (resultCode == Activity.RESULT_OK) {
                pendingResult?.success(true)
            } else {
                pendingResult?.success(false)
            }
            pendingResult = null
        } else if (requestCode == REQUEST_WRITE_PERMISSION) {
            if (resultCode == Activity.RESULT_OK) {
                val uri = pendingRenameUri
                val values = pendingRenameValues
                if (uri != null && values != null) {
                    try {
                        contentResolver.update(uri, values, null, null)
                        pendingResult?.success(true)
                    } catch (e: Exception) {
                        pendingResult?.error("RENAME_FAILED_AFTER_PERMISSION", e.message, null)
                    }
                } else {
                    pendingResult?.success(false)
                }
            } else {
                pendingResult?.success(false)
            }
            pendingResult = null
            pendingRenameUri = null
            pendingRenameValues = null
        }
    }
}

