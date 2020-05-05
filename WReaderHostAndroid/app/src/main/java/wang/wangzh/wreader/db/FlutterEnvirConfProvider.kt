package wang.wangzh.wreader.db

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import androidx.core.database.getIntOrNull
import androidx.core.database.getStringOrNull
import wang.wangzh.wreader.consts.FlutterModuleDbConst
import java.io.File
import java.lang.Exception

/**
 * @author  wangzh
 * @date  2020/3/15 20:18
 * 获取用户在FlutterModule配置环境设置，查询FlutterModule中使用的数据库文件
 */
object FlutterModuleDbHelper {

    private const val TAG = "FlutterEnvConfHelper"

    private const val DB_NAME="wreader_db.db"

    /**
     * 日夜模式切换持久存储
     */
    @JvmStatic
    fun modifyMode(context: Context, mode: Int) {
        val dbFile: File?
        try {
            dbFile =
                File(context.getDatabasePath(DB_NAME).absolutePath)
        } catch (e: Exception) {
            e.printStackTrace()
            return
        }
        if (dbFile.exists()) {
            var db: SQLiteDatabase? = null
            try {
                db =
                    SQLiteDatabase.openDatabase(
                        dbFile.absolutePath,
                        null,
                        SQLiteDatabase.OPEN_READWRITE
                    )
                val contentValue = ContentValues()
                contentValue.put(
                    FlutterModuleDbConst.COLUMN_BRIGHTNESS_MODE,
                    mode
                )
                db.update(FlutterModuleDbConst.TABLE_ENVIRONMENT_CONF, contentValue, "", null)
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                db?.close()
            }
        }
    }

    /**
     * 将所有仓库查询出来，用于处理仓库clone失败，但是有多余文件夹的情况
     */
    fun queryRepoList(context: Context): ArrayList<String> {
        val dbFile: File?
        val list = ArrayList<String>()
        try {
            dbFile =
                File(context.getDatabasePath(DB_NAME).absolutePath)
        } catch (e: Exception) {
            e.printStackTrace()
            return list
        }
        if (dbFile.exists()) {
            var db: SQLiteDatabase? = null
            try {
                db =
                    SQLiteDatabase.openDatabase(
                        dbFile.absolutePath,
                        null,
                        SQLiteDatabase.OPEN_READONLY
                    )
                val cursor = db.query(
                    FlutterModuleDbConst.TABLE_REPO_CONF,
                    arrayOf(FlutterModuleDbConst.COLUMN_TARGET_DIR),
                    "",
                    null,
                    null,
                    null,
                    null
                )
                cursor?.let {
                    while (cursor.moveToNext()) {
                        //只查询一个数据，索引从0开始
                        list.add(cursor.getString(0))
                    }
                    cursor.close()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                db?.close()
            }
        }
        return list
    }

    /**
     * 不再显示退出提示，不关心插入结果
     */
    @JvmStatic
    fun neverShowExitHint(context: Context) {
        val dbFile: File?
        try {
            dbFile =
                File(context.getDatabasePath(DB_NAME).absolutePath)
        } catch (e: Exception) {
            e.printStackTrace()
            return
        }
        if (dbFile.exists()) {
            var db: SQLiteDatabase? = null
            try {
                db =
                    SQLiteDatabase.openDatabase(
                        dbFile.absolutePath,
                        null,
                        SQLiteDatabase.OPEN_READWRITE
                    )
                val contentValue = ContentValues()
                contentValue.put(
                    FlutterModuleDbConst.COLUMN_SHOW_EXIT_HIT,
                    FlutterModuleDbConst.NEVER_SHOW_HINT
                )
                db.update(FlutterModuleDbConst.TABLE_ENVIRONMENT_CONF, contentValue, "", null)
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                db?.close()
            }
        }
    }

    /**
     * 将Flutter项目的环境配置读取出来，主要是亮暗模式与语言配置
     */
    @JvmStatic
    fun getEnvironmentConf(context: Context): HashMap<String, Any?> {
        val conf = HashMap<String, Any?>()
        val dbFile: File?
        try {
            dbFile =
                File(context.getDatabasePath(DB_NAME).absolutePath)
        } catch (e: Exception) {
            e.printStackTrace()
            return conf
        }
        Log.w(
            TAG,
            "dbFile.absolutePath = ${dbFile.absolutePath}"
        )
        if (dbFile.exists()) {
            var db: SQLiteDatabase? = null
            try {
                db =
                    SQLiteDatabase.openDatabase(
                        dbFile.absolutePath,
                        null,
                        SQLiteDatabase.OPEN_READONLY
                    )
                val cursor = db.rawQuery(
                    "SELECT ${FlutterModuleDbConst.COLUMN_BRIGHTNESS_MODE}, " +
                            " ${FlutterModuleDbConst.COLUMN_SHOW_EXIT_HIT}, " +
                            " ${FlutterModuleDbConst.COLUMN_LANGUAGE_CODE} FROM ${FlutterModuleDbConst.TABLE_ENVIRONMENT_CONF} ",
                    null
                )
                if (cursor.moveToFirst()) {
                    conf[FlutterModuleDbConst.BRIGHTNESS_MODE] =
                        cursor.getIntOrNull(cursor.getColumnIndexOrThrow(FlutterModuleDbConst.COLUMN_BRIGHTNESS_MODE))
                    conf[FlutterModuleDbConst.SHOW_EXIT_HIT] =
                        cursor.getIntOrNull(cursor.getColumnIndexOrThrow(FlutterModuleDbConst.COLUMN_SHOW_EXIT_HIT))
                    conf[FlutterModuleDbConst.LANGUAGE_CODE] =
                        cursor.getStringOrNull(cursor.getColumnIndexOrThrow(FlutterModuleDbConst.COLUMN_LANGUAGE_CODE))
                }
                cursor?.close()
            } catch (e: Exception) {
                e.printStackTrace()
                return conf
            } finally {
                db?.close()
            }
        }
        return conf
    }

}