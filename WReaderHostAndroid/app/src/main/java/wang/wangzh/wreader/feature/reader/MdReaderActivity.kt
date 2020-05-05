package wang.wangzh.wreader.feature.reader

import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Base64
import android.util.Log
import android.view.View
import android.view.animation.AccelerateInterpolator
import android.webkit.*
import android.widget.Toast
import kotlinx.android.synthetic.main.aty_md_reader.*
import wang.wangzh.wreader.R
import wang.wangzh.wreader.base.BaseAty
import wang.wangzh.wreader.consts.FileTypeConst
import wang.wangzh.wreader.consts.FlutterModuleDbConst
import wang.wangzh.wreader.db.FlutterModuleDbHelper
import wang.wangzh.wreader.feature.image.BrowseImageAty
import wang.wangzh.wreader.utils.MainHandler
import wang.wangzh.wreader.widget.ReadingWebView
import java.io.File
import java.util.regex.Pattern
import kotlin.math.absoluteValue

/**
 * @author : wangzhanhong
 * @Date : 2020/3/16 17:47
 * @Description :
 *  传入文件路径，读取字符串之后，使用js库转换，
 * 再使用WebView加载文件内容
 */
class MdReaderActivity : BaseAty() {

    companion object {

        private const val TAG = "MdReaderActivity"
        private const val FILE_PATH = "filePath"
        private const val FILE_TYPE = "fileType"
        private val IMAGE_REGEX =
            Pattern.compile("!\\[.*?]\\((.*?)\\)", Pattern.MULTILINE)
        private const val DARK_THEME = "file:///android_asset/themes/bootstrap-solar.min.css"
        private const val LIGHT_THEME = "file:///android_asset/themes/bootstrap-journal.min.css"
        private const val JS_BRIDGE = "bridge"
        private const val LIGHT_HTML_FILE = "file:///android_asset/load_text_file_light.html"
        private const val DART_HTML_FILE = "file:///android_asset/load_text_file_dart.html"
        /**
         * 获取所有img标签，并且给它们添加点击函数以显示图片
         */
        private const val EXTRACT_IMG_JS_FUN = "javascript: (function () {\n" +
                "    var imgTags = document.getElementsByTagName(\"img\");\n" +
                "    var length = imgTags.length;\n" +
                "    if (length == 0) {\n" +
                "        return;\n" +
                "    }\n" +
                "    imgResources = new Array();\n" +
                "    for (var i = 0; i < length; i++) {\n" +
                "        imgResources[i] = imgTags[i].src;\n" +
                "        let index=i;\n" +
                "        imgTags[i].onclick = function () {\n" +
                "            window.${JS_BRIDGE}.openImage(JSON.stringify(imgResources), index, imgResources[index]);\n" +
                "        };\n" +
                "    }\n" +
                "})()"

        /**
         * 开始阅读
         * @param filePath 传入MarkDown文件的绝对路径
         * @param requestCode 关闭页面的port
         */
        @JvmStatic
        fun startReading(
            aty: Activity,
            filePath: String,
            fileType: String,
            brightnessMode: Int,
            requestCode: Int
        ) {
            val intent = Intent(aty, MdReaderActivity::class.java)
            intent.putExtra(FILE_PATH, filePath)
            intent.putExtra(FILE_TYPE, fileType)
            intent.putExtra(FlutterModuleDbConst.BRIGHTNESS_MODE, brightnessMode)
            aty.startActivityForResult(intent, requestCode)
        }
    }

    /**
     * 是否初始化html配置完成
     */
    private var isInit = false
    /**
     *
     */
    private var lastAnimateTimestamp = System.currentTimeMillis()
    private var fileType: String? = ""
    private var filePath: String? = ""
    private var titleBarHeight: Int = 0
    private var canHide = true
    var hintAnimator: ValueAnimator? = null
    var floatAnimator: ValueAnimator? = null
    private val confMap: HashMap<String, Any?> = HashMap<String, Any?>()
    private val hideUpdateListener = ValueAnimator.AnimatorUpdateListener {
        val value = it.animatedValue as Float
        tvSwipeHint.alpha = value
    }
    private val floatUpdateListener = ValueAnimator.AnimatorUpdateListener {
        val value = it.animatedValue as Float
        flFloat.alpha = value
        if (value == 0f) {
            flFloat.visibility = View.GONE
            handleExitHint()
            ivBrightnessMode.visibility = View.VISIBLE
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.aty_md_reader)
        titleBarHeight = resources.getDimensionPixelSize(R.dimen.titleBarHeight)
        intent?.let {
            fileType = it.getStringExtra(FILE_TYPE)
            filePath = it.getStringExtra(FILE_PATH)
            filePath?.let { path ->
                if (path.isNotBlank()) {
                    tvFileTitle.text =
                        path.substring(path.lastIndexOf(File.separator) + 1, path.lastIndexOf('.'))
                    tvFileInfo.text =
                        path.substring(path.lastIndexOf('.'), path.length)
                }
            }
        }
        loadEnvConf()
        initListener()
    }

    private fun initListener() {
        ivBack.setOnClickListener { finish() }
        ivBrightnessMode.setOnClickListener {
            canHide = false
            val mode =
                if (FlutterModuleDbConst.LIGHT_MODE == confMap[FlutterModuleDbConst.BRIGHTNESS_MODE]) {
                    FlutterModuleDbConst.DARK_MODE
                } else {
                    FlutterModuleDbConst.LIGHT_MODE
                }
            val themeRef = if (mode == FlutterModuleDbConst.LIGHT_MODE) {
                LIGHT_THEME
            } else DARK_THEME
            wvMdReader.loadUrl(
                "javascript: modifyTheme(\"$themeRef\",\"$mode\")"
            )
            confMap[FlutterModuleDbConst.BRIGHTNESS_MODE] = mode
            ivBrightnessMode.setImageResource(
                if (mode == FlutterModuleDbConst.LIGHT_MODE)
                    R.drawable.icon_mode_light
                else
                    R.drawable.icon_mode_dark
            )
            FlutterModuleDbHelper.modifyMode(this, mode)
            //避免WebView重绘，隐藏TitleBar
            ivBrightnessMode.postDelayed(Runnable {
                canHide = true
            }, 500)
        }
    }

    /**
     * Html加载时会闪一下，加个动画过渡下
     */
    private fun hideFloat() {
        floatAnimator?.let {
            return
        }
        //根据文件长度来计算打开时间，优化交互
        val duration = filePath?.let {
            val length = File(filePath).length()
            Log.i(TAG, "length = $length")
            when {
                length < 1024 * 20 -> 300L
                length > 1024 * 100 -> 500L
                length > 1024 * 1024 -> 800L
                length > 1024 * 1024 * 10 -> 1000L
                else -> 1200L
            }
        } ?: run {
            500L
        }
        Log.w(TAG, "duration = $duration")
        floatAnimator = ValueAnimator.ofFloat(1f, 0f)
        floatAnimator?.duration = duration
        floatAnimator?.interpolator = AccelerateInterpolator()
        floatAnimator?.repeatCount = 0
        floatAnimator?.addUpdateListener(floatUpdateListener)
        floatAnimator?.start()
    }

    private fun loadEnvConf() {
        confMap.clear()
        confMap[FlutterModuleDbConst.BRIGHTNESS_MODE] =
            intent?.getIntExtra(FlutterModuleDbConst.BRIGHTNESS_MODE, FlutterModuleDbConst.LIGHT_MODE)
        ivBrightnessMode.setImageResource(
            if (confMap[FlutterModuleDbConst.BRIGHTNESS_MODE] == FlutterModuleDbConst.LIGHT_MODE)
                R.drawable.icon_mode_light
            else
                R.drawable.icon_mode_dark
        )
        if (confMap[FlutterModuleDbConst.BRIGHTNESS_MODE] == FlutterModuleDbConst.LIGHT_MODE) {
            flFloat.setBackgroundResource(android.R.color.white)
        } else {
            flFloat.setBackgroundResource(R.color.colorReaderBg)
        }
        wvMdReader.loadUrl(EXTRACT_IMG_JS_FUN)
        initWebView()
    }

    private fun handleExitHint() {
        confMap.let { map ->
            if (FlutterModuleDbConst.SHOW_HINT == map[FlutterModuleDbConst.SHOW_EXIT_HIT]) {
                tvSwipeHint.visibility = View.VISIBLE
                hintAnimator = ValueAnimator.ofFloat(1f, 0f)
                hintAnimator?.duration = 1800L
                hintAnimator?.addUpdateListener(hideUpdateListener)
                hintAnimator?.startDelay = 1800L
                hintAnimator?.repeatCount = 0
                hintAnimator?.start()
                tvSwipeHint.setOnClickListener {
                    releaseAnimator()
                    tvSwipeHint.visibility = View.GONE
                    FlutterModuleDbHelper.neverShowExitHint(this)
                }
            }
        }
    }

    private fun releaseAnimator() {
        hintAnimator?.let {
            hintAnimator?.removeUpdateListener(hideUpdateListener)
            hintAnimator?.cancel()
            hintAnimator = null
        }
        floatAnimator?.let {
            floatAnimator?.removeUpdateListener(floatUpdateListener)
            floatAnimator?.cancel()
            floatAnimator = null
        }
    }

    /**
     * 替换本地相对路径的图片
     */
    private fun replaceLocalImageRelativePath(content: String): String {
        var tmp = content
        filePath?.let { filePath ->
            //当前md文件的上一级目录
            val filePreRoot = filePath.substring(0, filePath.lastIndexOf('/'))
            val matcher = IMAGE_REGEX.matcher(content)
            while (matcher.find()) {
                val groupCount = matcher.groupCount()
                if (groupCount == 1) {
                    //图片相对地址，需要根据filePath进行替换
                    val imgRelativePath = matcher.group(1)
                    if (!(imgRelativePath.startsWith("http://") || imgRelativePath.startsWith("https://"))) {
                        if (imgRelativePath.startsWith("../")) {
                            //需要索引相对目录的层数
                            val relativePlies = imgRelativePath.split("../").size
                            var tmpRoot = filePath
                            for (i in 0 until relativePlies) {
                                tmpRoot = tmpRoot.substring(0, tmpRoot.lastIndexOf("/"))
                            }
                            tmp = tmp.replace(
                                imgRelativePath,
                                "${tmpRoot}${File.separator}${imgRelativePath.replace(
                                    "../",
                                    ""
                                )}"
                            )
                        } else {
                            tmp = tmp.replace(
                                imgRelativePath,
                                "${filePreRoot}${File.separator}$imgRelativePath"
                            )
                        }
                    }
                }
            }
        }

        return tmp
    }

    /**
     * 加载markdown文件
     * @param pureCode 纯粹的code文件，需要在首尾行加入
     * ```codeType
     * codeContent
     * ```
     */
    private fun loadMdFile(pureCode: Boolean = false) {
        filePath?.let { path ->
            val mdFile = File(path)
            if (mdFile.exists()) {
                var content: String = mdFile.readText()
                if (!pureCode) {
                    content = replaceLocalImageRelativePath(content)
                } else {
                    content =
                        "```${path.substring(path.lastIndexOf('.') + 1, path.length)}\n$content"
                    content = "${content}\n```"
                }
                //换行符统一转换成\n
                content = content.replace("\r\n", "\n")
                content = content.replace("\r", "\n")
                //Android使用js传递String，换行符会丢失，Base64编码一下，在js端再进行解码
                wvMdReader.loadUrl(
                    "javascript: showMdContent(\"${String(
                        Base64.encode(
                            content.toByteArray(),
                            Base64.DEFAULT
                        )
                    )}\")"
                )
                handleExitHint()
            } else {
                Toast.makeText(this, "request md file!", Toast.LENGTH_LONG).show()
            }
        } ?: run {
            Toast.makeText(this, "request md file!", Toast.LENGTH_LONG).show()
            finish()
        }
    }

    /**
     * 根据类型加载文件
     */
    private fun loadFile() {
        fileType?.let { type ->
            when (type) {
                FileTypeConst.MD_FILE -> {
                    loadMdFile()
                }
                FileTypeConst.CODE -> {
                    loadMdFile(true)
                }
                else -> {

                }
            }
        }
    }

    private fun hideTitleBar() {
        if (!canTrigger()) {
            return
        }
        lastAnimateTimestamp = System.currentTimeMillis()
        clReaderTitle.setTag(R.id.onAnimate, true)
        if (clReaderTitle.visibility == View.GONE) {
            return
        }
        val animator = ValueAnimator.ofInt(titleBarHeight, 0)
        animator.duration = 350
        animator.repeatCount = 0
        animator.addUpdateListener {
            val value = it.animatedValue as Int
            clReaderTitle.layoutParams.height = value
            clReaderTitle.requestLayout()
            if (value == 0) {
                clReaderTitle.visibility = View.GONE
                clReaderTitle.setTag(R.id.onAnimate, false)
            }
        }
        animator.start()
    }

    private fun showTitleBar() {
        if (!canTrigger()) {
            return
        }
        lastAnimateTimestamp = System.currentTimeMillis()
        clReaderTitle.setTag(R.id.onAnimate, true)
        if (clReaderTitle.visibility == View.GONE) {
            clReaderTitle.visibility = View.VISIBLE
        }
        val animator = ValueAnimator.ofInt(0, titleBarHeight)
        animator.duration = 350
        animator.repeatCount = 0
        animator.addUpdateListener {
            val value = it.animatedValue as Int
            clReaderTitle.layoutParams.height = value
            clReaderTitle.requestLayout()
            if (value == titleBarHeight) {
                clReaderTitle.setTag(R.id.onAnimate, false)
            }
        }
        animator.start()
    }

    private fun canTrigger(): Boolean {
        val onAnimate = clReaderTitle.getTag(R.id.onAnimate)
        return (onAnimate == null || (onAnimate as? Boolean) == false) && System.currentTimeMillis() - lastAnimateTimestamp > 250 && canHide
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initWebView() {

        wvMdReader.settings?.let { setting ->
            setting.javaScriptEnabled = true
            setting.setSupportZoom(true)
            setting.allowContentAccess = true
            setting.allowFileAccessFromFileURLs = true
            setting.allowUniversalAccessFromFileURLs = true
            setting.allowContentAccess = true
            setting.cacheMode = WebSettings.LOAD_DEFAULT
        }
        wvMdReader.scrollChangeCallback = object : ReadingWebView.ScrollChangeCallback {

            private val minThreshold = 2

            override fun onScrollChanged(x: Int, y: Int, xDelta: Int, yDelta: Int) {
                if (!canTrigger() && yDelta.absoluteValue > minThreshold) {
                    return
                }
                //向下滑，
                if (yDelta > 0) {
                    if (clReaderTitle.visibility == View.VISIBLE) {
                        hideTitleBar()
                    }
                } else if (yDelta < 0 && (yDelta.absoluteValue > minThreshold || y <= 10)) {
                    if (clReaderTitle.visibility == View.GONE) {
                        showTitleBar()
                    }
                }
            }
        }
        wvMdReader.rightAndBottomMotionCallback =
            object : ReadingWebView.RightAndBottomMotionCallback {
                override fun doSomething() {
                    finish()
                }
            }

        wvMdReader.webChromeClient = object : WebChromeClient() {
            //打印log
            override fun onConsoleMessage(consoleMessage: ConsoleMessage?): Boolean {
                Log.i(TAG, "consoleMessage?.message() = ${consoleMessage?.message()}")
//                Log.d(TAG, "consoleMessage?.lineNumber() = ${consoleMessage?.lineNumber()}")
//                Log.e(TAG, "consoleMessage?.sourceId() = ${consoleMessage?.sourceId()}")
//                Log.w(TAG, "consoleMessage?.messageLevel() = ${consoleMessage?.messageLevel()}")
                return super.onConsoleMessage(consoleMessage)
            }
        }
        wvMdReader.webViewClient = object : WebViewClient() {

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                //加载成功之后，处理图片点击事件
                if (!isInit) {
                    isInit = true
                    val mode = confMap[FlutterModuleDbConst.BRIGHTNESS_MODE] ?: 0
                    val themeRef = if (mode == FlutterModuleDbConst.LIGHT_MODE) {
                        LIGHT_THEME
                    } else DARK_THEME
                    ///设置默认主题先
                    wvMdReader.loadUrl(
                        "javascript: modifyTheme(\"$themeRef\",\"$mode\")"
                    )
                    loadFile()
                    wvMdReader.loadUrl(EXTRACT_IMG_JS_FUN)
                }
            }

            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                Log.w(TAG, "shouldOverrideUrlLoading:url = $url")
                url?.let {
                    jumpOtherWebSite(url)
                }
                return true
            }

            override fun shouldOverrideUrlLoading(
                view: WebView?,
                request: WebResourceRequest?
            ): Boolean {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    request?.url?.toString()?.let { url ->
                        jumpOtherWebSite(url)
                        Log.w(TAG, "shouldOverrideUrlLoading:url = $url")
                    }
                }
                return true
            }

            override fun shouldInterceptRequest(
                view: WebView?,
                url: String?
            ): WebResourceResponse? {
                Log.i(TAG, "shouldInterceptRequest:url = $url")
                return super.shouldInterceptRequest(view, url)
            }

        }
        wvMdReader.addJavascriptInterface(ImgClickJavascriptInterface(), JS_BRIDGE)
        if (FlutterModuleDbConst.LIGHT_MODE == confMap[FlutterModuleDbConst.BRIGHTNESS_MODE]) {
            wvMdReader.loadUrl(LIGHT_HTML_FILE)
        } else {
            wvMdReader.loadUrl(DART_HTML_FILE)
        }
    }

    private fun jumpOtherWebSite(url: String) {
        val uriIntent = Intent()
        uriIntent.action = Intent.ACTION_VIEW
        val uri = Uri.parse(url)
        uriIntent.data = uri
        startActivity(uriIntent)
    }

    override fun onDestroy() {
        releaseAnimator()
        //释放WebView
        wvMdReader.stopLoading()
        wvMdReader.settings.javaScriptEnabled = false
        wvMdReader.removeAllViews()
        wvMdReader.destroy()
        super.onDestroy()
    }

    private inner class ImgClickJavascriptInterface {
        @JavascriptInterface
        fun openImage(resourcesJsonStr: String?, index: Int?, currentImgUrl: String?) {
            Log.i(TAG, "openImage($resourcesJsonStr,$index,$currentImgUrl)")
            currentImgUrl?.let {
                BrowseImageAty.browseImage(this@MdReaderActivity, currentImgUrl)
            } ?: run {
                Toast.makeText(this@MdReaderActivity, R.string.emptyImgResource, Toast.LENGTH_LONG)
                    .show()
            }
        }

        @JavascriptInterface
        fun hideFloat() {
            Log.i(TAG, "hideFloat")
            MainHandler.runOnMain(Runnable {
                this@MdReaderActivity.hideFloat()
            })
        }
    }
}