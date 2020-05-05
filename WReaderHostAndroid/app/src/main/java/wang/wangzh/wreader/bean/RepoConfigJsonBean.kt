package wang.wangzh.wreader.bean

/**
 * @author : wangzhanhong
 * @Date : 2020/3/10 15:50
 * @Description : 从json文件中导入配置信息的映射类
 * @param gitUri 远程仓库的uri
 * @param targetDir git仓库的存放目录 name，如果为空会解析git仓库的name直接写入
 * @param authenticationWay 鉴权方式，常量值见[GitAuthenticationWayConst]
 * @param account GitAuthenticationWayConst.ACCOUNT_AND_PASSWORD的鉴权账号
 * @param pwd GitAuthenticationWayConst.ACCOUNT_AND_PASSWORD的鉴权密码
 * @param priKey GitAuthenticationWayConst.KEY_PAIR的私钥字符串
 * @param pubKey GitAuthenticationWayConst.KEY_PAIR的公钥字符串
 * @param priKeyPassword GitAuthenticationWayConst.KEY_PAIR的密钥对密码
 */
class RepoConfigJsonBean(
    val gitUri: String,
    val targetDir: String?,
    val authenticationWay: Int,
    val account: String?,
    val pwd: String?,
    val priKey: String?,
    val pubKey: String?,
    val priKeyPassword: String?
)