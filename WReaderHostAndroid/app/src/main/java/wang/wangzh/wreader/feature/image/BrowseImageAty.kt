package wang.wangzh.wreader.feature.image

import android.animation.ValueAnimator
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import com.bumptech.glide.Glide
import kotlinx.android.synthetic.main.aty_browse_image.*
import wang.wangzh.wreader.R
import wang.wangzh.wreader.base.BaseAty
import wang.wangzh.wreader.consts.FlutterModuleDbConst
import wang.wangzh.wreader.db.FlutterModuleDbHelper

/**
 * @author  wangzh
 * @date  2020/3/22 12:02
 * 图片浏览页面
 */
class BrowseImageAty : BaseAty() {
    companion object {

        private const val IMAGE_URI = "imageUri"

        private const val TAG = "BrowseImageAty"

        private const val RIGHT_SWIPE_DELTA = 100
        private const val DOWN_SWIPE_DELTA = 100
        @JvmStatic
        fun browseImage(aty: Activity, uri: String) {
            val intent = Intent(aty, BrowseImageAty::class.java)
            intent.putExtra(IMAGE_URI, uri)
            aty.startActivity(intent)
        }
    }

    var animator: ValueAnimator? = null
    private var confMap: HashMap<String, Any?>? = null
    private val updateListener = ValueAnimator.AnimatorUpdateListener {
        val value = it.animatedValue as Float
        tvSwipeHint.alpha = value
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.aty_browse_image)
        loadEnvConf()
    }

    private fun loadEnvConf() {
        confMap = FlutterModuleDbHelper.getEnvironmentConf(this)
        handleExitHint()
        loadImage()
    }

    private fun handleExitHint() {
        confMap?.let { map ->
            if (FlutterModuleDbConst.SHOW_HINT == map[FlutterModuleDbConst.SHOW_EXIT_HIT]) {
                tvSwipeHint.visibility = View.VISIBLE
                animator = ValueAnimator.ofFloat(1f, 0f)
                animator?.duration = 1800L
                animator?.addUpdateListener(updateListener)
                animator?.startDelay = 1800L
                animator?.repeatCount = 0
                animator?.start()
                tvSwipeHint.setOnClickListener {
                    releaseAnimator()
                    tvSwipeHint.visibility = View.GONE
                    FlutterModuleDbHelper.neverShowExitHint(this)
                }
            }
        }
    }

    private fun releaseAnimator() {
        animator?.let {
            animator?.removeUpdateListener(updateListener)
            animator?.cancel()
            animator = null
        }
    }

    private fun loadImage() {
        intent?.getStringExtra(IMAGE_URI)?.let { uri ->
            Glide.with(this).load(uri).into(pv)
            pv.attacher.setOnViewDragListener { dx, dy ->
                if (dx > RIGHT_SWIPE_DELTA && dy > DOWN_SWIPE_DELTA) {
                    finish()
                }
            }
        } ?: kotlin.run {
            Toast.makeText(this, R.string.emptyImgResource, Toast.LENGTH_LONG).show()
            finish()
        }
    }

    override fun onDestroy() {
        releaseAnimator()
        super.onDestroy()
    }
}