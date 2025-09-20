package com.example.api;

import java.io.*;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;

public class DownloadDependencies {
    public static void main(String[] args) {
        // 创建依赖下载目录
        File dir = new File("dependency-jars");
        if (!dir.exists()) {
            dir.mkdirs();
        }

        // 依赖项列表
        String[][] dependencies = {
                {"spring-boot-starter-web-2.5.0.jar", "https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-web/2.5.0/spring-boot-starter-web-2.5.0.jar"},
                {"spring-boot-starter-data-jpa-2.5.0.jar", "https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-data-jpa/2.5.0/spring-boot-starter-data-jpa-2.5.0.jar"},
                {"springfox-boot-starter-3.0.0.jar", "https://repo1.maven.org/maven2/io/springfox/springfox-boot-starter/3.0.0/springfox-boot-starter-3.0.0.jar"},
                {"h2-1.4.200.jar", "https://repo1.maven.org/maven2/com/h2database/h2/1.4.200/h2-1.4.200.jar"},
                {"mysql-connector-java-8.0.23.jar", "https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.23/mysql-connector-java-8.0.23.jar"},
                {"ojdbc8-19.3.0.0.jar", "https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar"},
                {"java-dotenv-5.0.0.jar", "https://repo1.maven.org/maven2/io/github/cdimascio/java-dotenv/5.0.0/java-dotenv-5.0.0.jar"}
        };

        // 下载每个依赖项
        for (String[] dep : dependencies) {
            try {
                downloadFile(dep[1], "dependency-jars/" + dep[0]);
                System.out.println("Downloaded: " + dep[0]);
            } catch (Exception e) {
                System.err.println("Failed to download: " + dep[0] + " - " + e.getMessage());
            }
        }

        System.out.println("Dependencies downloaded and backed up to dependency-jars directory");
    }

    private static void downloadFile(String urlString, String fileName) throws Exception {
        URL url = new URL(urlString);
        ReadableByteChannel rbc = Channels.newChannel(url.openStream());
        FileOutputStream fos = new FileOutputStream(fileName);
        fos.getChannel().transferFrom(rbc, 0, Long.MAX_VALUE);
        fos.close();
        rbc.close();
    }
}
