package wang.wangzh.wreader.base

import android.os.Build
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import wang.wangzh.wreader.R

/**
 * 修改状态栏颜色和Flutter项目一致
 */
abstract class BaseAty : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        //修改状态栏颜色和Flutter项目一致
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            window.statusBarColor = resources.getColor(R.color.statusBarColor);
        }
        super.onCreate(savedInstanceState)
    }

}