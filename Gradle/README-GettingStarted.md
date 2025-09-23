-----

### Gradle 入门指南：从安装到使用（Windows & macOS）

本指南将带你从零开始，逐步掌握 Gradle 的安装与基本使用，让你能够轻松地自动化你的项目构建。

-----

### **1. 准备工作：安装 Java 开发工具包 (JDK)**

Gradle 运行需要 Java 环境，因此你必须先安装 JDK。推荐安装 **JDK 8 或更高版本**。

* **Windows:** 访问 Oracle 或 OpenJDK 官网下载并安装 JDK。安装完成后，确保将 Java 的 `bin` 目录添加到系统的环境变量 `Path`
  中。
* **macOS:** 最简单的方法是使用 Homebrew。打开终端，输入以下命令：
  ```bash
  brew install openjdk
  ```
  安装完成后，根据终端提示设置 JAVA\_HOME 环境变量。

验证安装是否成功，打开终端或命令提示符，输入：

```bash
java -version
```

如果能看到 Java 版本信息，说明安装成功。

-----

### **2. 安装 Gradle**

#### **2.1. Windows**

1. **下载 Gradle:** 访问 [Gradle 官方下载页面](https://gradle.org/releases/)，下载最新版本的 **binary-only** 文件（例如
   `gradle-8.x.x-bin.zip`）。
2. **解压文件:** 将下载的压缩包解压到你喜欢的目录，例如 `C:\Gradle`。
3. **配置环境变量:**
    * 打开“系统属性” -\> “高级” -\> “环境变量”。
    * 在“系统变量”下，点击“新建”。
    * 变量名：`GRADLE_HOME`
    * 变量值：`C:\Gradle`（替换为你解压的路径）
    * 在“系统变量”中找到 `Path`，双击编辑。
    * 点击“新建”，添加 `%GRADLE_HOME%\bin`。
    * 点击“确定”保存。

#### **2.2. macOS**

使用 Homebrew 是最简单快捷的方法：

```bash
brew install gradle
```

Homebrew 会自动处理安装和环境变量配置。

#### **2.3. 验证安装**

打开新的终端或命令提示符，输入：

```bash
gradle -v
```

如果能看到 Gradle 版本信息，恭喜你，安装成功了！

-----

### **3. 创建一个简单的 Java 项目**

让我们创建一个简单的项目来体验 Gradle 的魔力。

1. 创建一个新文件夹，例如 `my-app`。
2. 在 `my-app` 文件夹中，创建一个名为 `build.gradle` 的文件。

#### **`build.gradle` 文件**

`build.gradle` 是 Gradle 的核心配置文件，用 Groovy 语法编写。对于一个简单的 Java 项目，可以添加以下内容：

```groovy
// 1. 应用 Java 插件
//    'java' 插件提供了编译、测试和打包 Java 项目所需的所有任务。
plugins {
    id 'java'
}

// 2. 配置仓库
//    Gradle 需要知道去哪里下载依赖。这里我们使用 Maven Central 仓库。
repositories {
    mavenCentral()
}

// 3. 配置依赖
//    'implementation' 表示这些依赖在编译和运行时都需要。
dependencies {
    // 举个例子，添加一个 JUnit 5 的测试依赖。
    // 'testImplementation' 表示该依赖只在测试时需要。
    testImplementation 'org.junit.jupiter:junit-jupiter-api:5.11.0'
    testRuntimeOnly 'org.junit.jupiter:junit-jupiter-engine:5.11.0'
}

// 4. 配置项目版本
//    定义项目的版本号。
version = '1.0'

// 5. 配置任务
//    可以定义自定义任务。这里我们定义一个简单的打印任务。
task hello {
    doLast {
        println 'Hello, Gradle!'
    }
}
```

#### **创建源代码**

按照约定，Gradle 会在以下目录中查找源代码：

* `src/main/java`：存放主程序代码
* `src/test/java`：存放测试代码

在 `my-app` 文件夹下，创建 `src/main/java/App.java`：

```java
public class App {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

-----

### **4. Gradle 常用命令**

在 `my-app` 文件夹下，打开终端或命令提示符，你可以执行各种 Gradle 任务。

* **执行自定义任务:**

  ```bash
  gradle hello
  ```

  这会执行你在 `build.gradle` 中定义的 `hello` 任务，输出 `Hello, Gradle!`。

* **查看所有任务:**

  ```bash
  gradle tasks
  ```

  这会列出所有可用的任务，包括 Gradle 内置的以及你自定义的。

* **编译项目:**

  ```bash
  gradle build
  ```

  这是最常用的命令之一。它会执行编译、测试、打包等一系列任务。执行成功后，会在项目目录下生成一个 `build`
  文件夹，其中包含编译后的类文件、测试报告和可执行的 Jar 包等。

* **运行项目:**

  ```bash
  gradle run
  ```

  如果你在 `build.gradle` 中应用了 `application` 插件并配置了主类，你可以直接运行项目。

* **清理项目:**

  ```bash
  gradle clean
  ```

  这会删除 `build` 文件夹，让你重新开始构建。

通过这些基本命令，你已经可以开始使用 Gradle
管理你的项目了。要深入学习，可以查阅 [Gradle 官方文档](https://docs.gradle.org/current/userguide/userguide.html)。

-----

### 如何将 Gradle 升级到最新版本

要将 Gradle 从 8.13 升级到最新版本，你可以采取以下两种方法。如果你是通过官方安装包或 Homebrew 安装的，那么方法一最简单。如果你是在项目中使用了
Gradle Wrapper，那么方法二最常见。

-----

### **方法一：通过安装方式升级**

如果你是通过下载官方二进制文件或使用包管理器（如 Homebrew）来安装 Gradle 的，那么升级过程非常直接。

* **Windows (手动安装):**
    1. 访问 [Gradle 官方下载页面](https://gradle.org/releases/)，下载最新版本的 **binary-only** 文件。
    2. 解压文件到你之前安装的目录，例如 `C:\Gradle`，覆盖旧版本的文件。
    3. 因为环境变量已经配置好了，所以不需要再做任何更改。
* **macOS (使用 Homebrew):**
    1. 打开终端，运行 Homebrew 的升级命令：
       ```bash
       brew upgrade gradle
       ```
    2. Homebrew 会自动下载并安装最新版本的 Gradle。

升级后，再次运行 `gradle -v` 即可验证新版本是否生效。

-----

### **方法二：通过 Gradle Wrapper (推荐)**

在大多数实际项目中，我们都使用 **Gradle Wrapper**（一个 `gradlew` 或 `gradlew.bat` 脚本），它能确保团队中的每个人都使用相同版本的
Gradle，而无需手动安装。

升级 Gradle Wrapper 是最安全、最方便的升级方式。你只需在项目的根目录下运行一个命令即可：

```bash
./gradlew wrapper --gradle-version 8.13.1
```

> **注意：** 将 `8.13.1` 替换为你想要升级到的具体版本号。你可以在 [Gradle 官方发布页面](https://gradle.org/releases/)
找到最新版本。

执行此命令后，Gradle Wrapper 会自动更新你项目中的以下文件：

* `gradle/wrapper/gradle-wrapper.properties`：这个文件会更新 `distributionUrl`，指向新版本的 Gradle。
* `gradle/wrapper/gradle-wrapper.jar`：这个 Jar 文件也会被替换为最新版本。

当下次你或你的队友运行 `./gradlew` 命令时，Wrapper 会自动下载指定版本并使用它来构建项目。

**总结：**

* 如果你的项目使用 Gradle Wrapper，强烈推荐使用**方法二**来升级，这能确保项目构建的一致性。
* 如果你是在系统级别使用 Gradle，并且所有项目都使用相同的版本，那么**方法一**更适合你。