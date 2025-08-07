Gradle
=====

## 什么是 Gradle？

Gradle 是一款基于 Groovy 的自动化构建工具，它可以简化构建过程，并提供强大的插件系统，可以支持多种语言和构建工具。Gradle 被广泛应用于 Android 开发、Java 开发、Web 开发、自动化测试、部署等领域。

## 为什么要使用 Gradle？

Gradle 的主要优点有： 

* **自动化:** Gradle 可以自动执行常见的构建任务，例如编译、测试、打包、发布等。
* **依赖管理:** Gradle 可以自动管理依赖，包括库的下载、编译、测试等。
* **增量构建:** Gradle 可以通过增量构建提高构建速度，只构建发生变化的部分。
* **插件系统:** Gradle 提供了强大的插件系统，可以扩展功能。
* **DSL:** Gradle 使用 Groovy 语言编写，具有强大的 DSL 能力。

## Windows 下使用不同版本 Gradle 的方法

在 Windows 环境下，为了适应不同项目对 Gradle 版本的需求，我们可以通过以下几种方式来管理多个 Gradle 版本：

### 1. **手动下载并配置环境变量**

* **下载多个 Gradle 版本:** 从 Gradle 官方网站下载所需的不同版本，并解压到不同的目录。
* **配置环境变量:**
    * **新建环境变量:** 为每个 Gradle 版本创建一个 GRADLE_HOME 环境变量，指向其解压目录。例如：
        * GRADLE_5_HOME=D:\gradle-5.6
        * GRADLE_6_HOME=D:\gradle-6.7
    * **修改 PATH 环境变量:** 在 PATH 环境变量中添加各个 Gradle 版本的 bin 目录。例如：
        * %GRADLE_5_HOME%\bin;
        * %GRADLE_6_HOME%\bin;

* **切换版本:** 在命令行中，通过设置 GRADLE_HOME 环境变量来切换当前使用的 Gradle 版本。例如：
    * set GRADLE_HOME=D:\gradle-5.6

### 2. **使用工具管理**

* **SDKMAN!:**
    * **安装:** 从 SDKMAN! 官方网站下载安装脚本，并运行。
    * **安装 Gradle:** 使用 `sdk install gradle <version>` 命令安装不同版本的 Gradle。
    * **使用 Gradle:** 使用 `sdk use gradle <version>` 命令切换 Gradle 版本。
* **nvm-for-windows:**
    * **安装:** 从 nvm-for-windows 官方网站下载安装脚本，并运行。
    * **安装 Gradle:** 使用 `nvm install gradle <version>` 命令安装不同版本的 Gradle。
    * **使用 Gradle:** 使用 `nvm use gradle <version>` 命令切换 Gradle 版本。

### 3. **Gradle Wrapper**

* **生成 Wrapper:** 在项目根目录下运行 `gradle wrapper` 命令生成 Gradle Wrapper。
* **指定版本:** 在 `gradle/wrapper/gradle-wrapper.properties` 文件中修改 `distributionUrl` 属性来指定 Gradle 版本。
* **运行任务:** 使用 `./gradlew <task>` 命令运行 Gradle 任务，Wrapper 会自动下载并使用指定版本的 Gradle。

### 推荐使用 Gradle Wrapper 的原因

* **项目隔离:** 每个项目都可以有自己的 Gradle 版本，避免全局配置冲突。
* **自动化下载:** Wrapper 会自动下载所需的 Gradle 版本，方便团队协作。
* **版本一致性:** 确保不同环境使用相同的 Gradle 版本。

### 注意事项

* **环境变量优先级:** 如果同时设置了全局的 GRADLE_HOME 和项目级别的 Wrapper，Wrapper 配置的优先级更高。
* **兼容性问题:** 不同 Gradle 版本之间可能存在兼容性问题，在切换版本时需要注意。
* **IDE 配置:** 在 IDE 中配置 Gradle 项目时，需要指定正确的 Gradle Home 或使用 Wrapper。

### 总结

选择哪种方式管理 Gradle 版本取决于个人偏好和项目需求。如果需要频繁切换 Gradle 版本，推荐使用 SDKMAN! 或 nvm-for-windows。如果希望每个项目使用不同的 Gradle 版本，Gradle Wrapper 是一个不错的选择。

**更多信息**

* **Gradle 官方文档:** [https://docs.gradle.org/current/userguide/gradle_wrapper.html](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
* **SDKMAN! 官方网站:** [https://sdkman.io/](https://sdkman.io/)
* **nvm-for-windows 官方网站:** [https://github.com/coreybutler/nvm-windows](https://github.com/coreybutler/nvm-windows)

# Build code
```shell
# Gradle
# Install
brew install gradle
gradle -v
# build
gradle clean build --scan
# 使用以下命令来生成详细的构建扫描报告，指出具体哪些功能已弃用以及它们的来源
gradle clean build --scan
# 使用以下命令来显示所有弃用功能的警告信息
gradle build --warning-mode all
# 检查项目中是否有 Tomcat 的依赖
gradle dependencies | grep tomcat
# 检查项目中 org.apache.tomcat.util.http.parser.LocalStrings 类的版本
gradle dependencies | grep LocalStrings
# 刷新依赖并显示堆栈跟踪信息
./gradlew clean build --refresh-dependencies --stacktrace
```

# cmd
```shell
# Gradle 项目的运行时依赖关系, 显示项目的 runtimeClasspath 配置中的所有依赖
./gradlew dependencies --configuration runtimeClasspath
```

# Reference

- [SDKMANでGradle](https://qiita.com/kuroui2/items/e25aa278e755472294d4)
- [sdkman の使い方](https://qiita.com/ekzemplaro/items/35b3581bb322f0f4d9a3)
- [GradleでMavenローカルリポジトリにpublishをする](https://qiita.com/yoyoyo_pg/items/61ea8dc2e4e434f53f99)
- [SpringBoot×OpenAPI入門　〜Generation gapパターンで作るOpenAPI〜](https://qiita.com/haruto167/items/219bb0b0167804d0c922)
