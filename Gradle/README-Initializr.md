### **Spring Boot 项目初始化 Gradle Wrapper 完整指南**

本指南将带你从零开始创建一个新的 Spring Boot 项目，并确保它使用 Gradle Wrapper 进行构建。

-----

### **1. 使用 Spring Initializr 创建项目**

[Spring Initializr](https://start.spring.io/) 是创建 Spring Boot 项目最简单、最官方的方式。

* **访问网站：** 打开浏览器，访问 [https://start.spring.io/](https://start.spring.io/)。
* **填写项目信息：**
    * **Project:** 选择 **Gradle - Groovy Project** 或 **Gradle - Kotlin Project**。推荐选择 Groovy，因为它是最常见的。
    * **Language:** 选择 **Java**。
    * **Spring Boot:** 选择一个稳定的版本，通常是推荐的 LTS (Long-Term Support) 版本。
    * **Project Metadata:**
        * **Group:** `com.example` (通常是你的公司或组织域名反写)
        * **Artifact:** `demo` (你的项目名称)
        * **Name:** `demo`
        * **Description:** 简短描述你的项目。
        * **Package name:** `com.example.demo`
        * **Packaging:** `Jar`
        * **Java:** 选择一个合适的 Java 版本，例如 `17`。
    * **Dependencies:** 点击 `ADD DEPENDENCIES...`，添加你需要的依赖，例如：
        * **Spring Web:** 用于创建 Web 应用和 RESTful API。
* **生成项目：** 点击 `GENERATE` 按钮，下载生成的 `.zip` 文件。

-----

### **2. 解压并打开项目**

1. 将下载的 `.zip` 文件解压到你喜欢的目录。
2. 使用你喜欢的 IDE（如 IntelliJ IDEA、Visual Studio Code 或 Eclipse）打开解压后的项目文件夹。大多数现代 IDE 都能识别 Gradle
   项目，并自动配置好一切。

-----

### **3. 验证 Gradle Wrapper**

Spring Initializr 默认会为 Gradle 项目生成 Wrapper。你可以通过检查项目文件夹来验证：

* **文件检查：** 在项目根目录，你会看到以下文件和文件夹：
    * `gradlew` (对于 macOS 和 Linux)
    * `gradlew.bat` (对于 Windows)
    * `gradle/` 文件夹，其中包含 `wrapper/` 文件夹和 `gradle-wrapper.jar`、`gradle-wrapper.properties` 文件。

这意味着你的项目已经自带 Gradle Wrapper 了！你无需手动执行 `gradle wrapper` 命令。

-----

### **4. 使用 Gradle Wrapper 构建项目**

现在，你可以使用 Gradle Wrapper 脚本来构建你的项目，而不是依赖于系统安装的 Gradle。

* **在项目根目录打开终端或命令提示符。**
* **构建项目：**
    * 在 macOS/Linux 上：
      ```bash
      ./gradlew build
      ```
    * 在 Windows 上：
      ```bash
      gradlew.bat build
      ```
* **首次运行：** 第一次执行此命令时，Wrapper 会自动从互联网下载 `gradle-wrapper.properties` 文件中指定的 Gradle
  版本。这可能需要一些时间，取决于你的网络速度。下载完成后，它会自动开始构建你的项目。
* **运行 Spring Boot 应用：**
    * 你可以通过 `bootRun` 任务来运行你的应用：
      ```bash
      ./gradlew bootRun
      ```
* **清理构建目录：**
  ```bash
  ./gradlew clean
  ```

-----

### **5. 总结**

使用 Spring Initializr 创建 Spring Boot 项目时，它已经为你集成了 Gradle Wrapper。你所需要做的就是下载、解压项目，然后直接使用
`gradlew` 或 `gradlew.bat` 脚本来构建和运行你的应用。这确保了你的项目在任何环境下都能保持一致的构建行为。