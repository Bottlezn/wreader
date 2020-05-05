## WReader

**一个功能简单、页面简陋、却又实用的带有 Git 只读功能的阅读器。提供私有 Git 仓库克隆，分支、标签检出与切换等功能，主要用于阅读 Markdown 笔记。**  

## 运行  

1. Clone 项目：`git clone git@github.com:Bottlezn/wreader.git `
2. 目前 v0.1 版本的 tag 是 `v0.1`。切换到该 tag，`git chekout -b fromTag/v0.1 v0.1`
3. 假设根路径是 `$ROOT_DIR`，`cd $ROOT_DIR/wreader_flutter_module` ,在 terminal 中运行  
    ```
    flutter pub get
    flutter create .
    ```
4. Android 项目 `WReaderHostAndroid` 直接使用 AndroidStudio 打开即可。
5. iOS 项目 `WReaderHostiOS` 需要在 `WReaderHostiOS` 目录下运行 `pod install`之后再打开，我的 XCode 版本是 11 。

## 快速使用  

**建议使用 json 文件导入的方式来 Clone 项目。**  

- 密钥对导入格式：`authenticationWay` 是的值为2，`priKey` , `pubKey` 和 `priKeyPassword` 使用 Base64 编码。其中 `priKey` 必须是 `BEGIN RSA PRIVATE KEY` 开头的，不要使用 `BEGIN OPENSSH PRIVATE KEY` 开头的，WReader 依赖的 JSCH 库不支持该格式。
    ```json
    {
        "gitUri":"git仓库的uri，支持git与http协议",
        "targetDir":"clone仓库的目录名称，就是`git clone git@xxx targetDir`中的dir。可以不填写，使用默认值",
        "authenticationWay":2,
        "priKey":"使用Base64编码过的私钥字符串内容，必须是这个`BEGIN RSA PRIVATE KEY`开头的",
        "pubKey":"使用Base64编码过的公钥字符串内容",
        "priKeyPassword":"使用Base64编码过的私钥密码，私钥没有加密的话传空即可"
    }
    ```
- 账号密码导入格式： `authenticationWay` 是的值为1。  
    ```json
    {
        "gitUri":"git仓库的uri，支持git与http协议",
        "targetDir":"clone仓库的目录名称，就是`git clone git@xxx targetDir`中的dir。可以不填写，使用默认值",
        "authenticationWay":1,
        "account": "使用Base64编码过的账号", 
        "pwd": "使用Base64编码过的密码内容"
    }
    ```

## 注意  

iOS 平台的功能尚未完成.

## email  
我的邮箱地址： `wdu_udw@163.com` 。

## LICENSE

## LICENSE

[LICENSE](LICENSE)