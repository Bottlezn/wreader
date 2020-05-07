## ChangeLog

[last APK](https://gitee.com/tea_too_tea_too/wreader_resources/blob/master/AndroidApk/lastRelease/DownloadUrl.md)  

### v0.1

**first version.**  
[Download url](https://gitee.com/tea_too_tea_too/wreader_resources/blob/master/AndroidApk/wreader_v0.1_release.apk)  

### v0.2

[Download url](https://gitee.com/tea_too_tea_too/wreader_resources/blob/master/AndroidApk/wreader_v0.2_release.apk) 

bug 修复：  
```
java.lang.NoSuchMethodError: java.util.concurrent.ConcurrentHashMap.keySet() 
Ljava/util/concurrent/ConcurrentHashMap$KeySetView;
```  
异常导致的许多 Android 设备 Clone 失败。  
通过修改 JGit 源码实现，具体修改类为 `FilterCommandRegistry` ： 

将以下代码  
```java
private static ConcurrentHashMap<String, FilterCommandFactory> filterCommandRegistry = new ConcurrentHashMap();
```
修改为  
```java
private static Map<String, FilterCommandFactory> filterCommandRegistry = new ConcurrentHashMap();
```

### v0.3 
[Download url](https://gitee.com/tea_too_tea_too/wreader_resources/blob/master/AndroidApk/wreader_v0.3_release.apk)  

1. **Optimize language switching performance.**  
2. Fix bugs that have been found.

