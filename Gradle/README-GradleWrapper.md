Gradle Wrapper
=====

### Gradle Wrapper：让你的项目构建更一致

**Gradle Wrapper** (通常简称为 "Wrapper") 是一个脚本，它能让任何人在没有预先安装 Gradle 的情况下，就能够构建项目。它的核心作用是：**确保所有项目成员都使用相同的 Gradle 版本来构建项目**。这极大地解决了因版本不一致而导致的“在我的机器上能运行”的问题。

-----

### **1. 为什么你需要使用 Gradle Wrapper？**

* **版本一致性：** 强制团队中的每个人都使用特定版本的 Gradle，避免了因版本差异导致的构建失败。
* **无需手动安装：** 新加入项目的开发者或 CI/CD 服务器无需手动安装 Gradle。运行 Wrapper 脚本时，它会自动下载并缓存所需的 Gradle 版本。
* **项目级别的配置：** Gradle Wrapper 的配置（如 Gradle 版本号）是项目的一部分，可以和代码一起提交到版本控制系统（如 Git）。

-----

### **2. Gradle Wrapper 的核心文件**

当你为一个项目初始化 Gradle Wrapper 后，会在项目根目录生成以下文件和文件夹：

* `gradlew` (Linux/macOS) 和 `gradlew.bat` (Windows)：这两个是 Wrapper 的可执行脚本，用于代替 `gradle` 命令。
* `gradle/wrapper/` 文件夹：
    * `gradle-wrapper.jar`：Wrapper 的核心 Jar 包，它负责下载和执行真正的 Gradle。
    * `gradle-wrapper.properties`：配置文件，定义了要使用的 Gradle 版本和下载地址。

**`gradle-wrapper.properties` 文件示例：**

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

* `distributionUrl`：这是 Wrapper 下载 Gradle 的核心配置。它指定了 Gradle 发行版的 URL。

-----

### **3. 如何使用 Gradle Wrapper？**

一旦项目初始化了 Wrapper，你就应该停止使用系统安装的 `gradle` 命令，转而使用 Wrapper 脚本。

* **在 Linux 或 macOS 上:**
  ```bash
  ./gradlew <任务名>
  ```
  例如，`./gradlew build` 或 `./gradlew run`。
* **在 Windows 上:**
  ```bash
  gradlew <任务名>
  ```
  例如，`gradlew build` 或 `gradlew run`。

-----

### **4. 初始化和更新 Gradle Wrapper**

#### **4.1. 初始化 Wrapper**

如果你的项目还没有 Wrapper，你可以通过系统安装的 Gradle 来生成它。在项目根目录下，运行以下命令：

```bash
gradle wrapper
```

#### **4.2. 更新 Wrapper 版本**

要将项目使用的 Gradle 版本升级到最新，你只需在项目根目录运行以下命令，Wrapper 会自动更新相关的配置文件：

```bash
./gradlew wrapper --gradle-version <版本号>
```

**示例：** 将 Gradle 版本更新到 8.13.1

```bash
./gradlew wrapper --gradle-version 8.13.1
```

更新后，请确保将 `gradlew` 和 `gradlew.bat` 脚本以及 `gradle/wrapper/` 文件夹下的所有文件都提交到你的版本控制系统。

使用 Gradle Wrapper 是现代 Java 项目管理的最佳实践。它能让你的构建过程更加健壮、可预测，并极大地简化了新开发者的入职流程。