#!/bin/bash

# 创建依赖下载目录
mkdir -p dependency-jars

# 从build.gradle中提取依赖并下载
# 这里列出关键依赖进行手动下载备份
curl -L -o dependency-jars/spring-boot-starter-web-2.5.0.jar https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-web/2.5.0/spring-boot-starter-web-2.5.0.jar
curl -L -o dependency-jars/spring-boot-starter-data-jpa-2.5.0.jar https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-data-jpa/2.5.0/spring-boot-starter-data-jpa-2.5.0.jar
curl -L -o dependency-jars/springfox-boot-starter-3.0.0.jar https://repo1.maven.org/maven2/io/springfox/springfox-boot-starter/3.0.0/springfox-boot-starter-3.0.0.jar
curl -L -o dependency-jars/h2-1.4.200.jar https://repo1.maven.org/maven2/com/h2database/h2/1.4.200/h2-1.4.200.jar
curl -L -o dependency-jars/mysql-connector-java-8.0.23.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.23/mysql-connector-java-8.0.23.jar
curl -L -o dependency-jars/ojdbc8-19.3.0.0.jar https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar
curl -L -o dependency-jars/java-dotenv-5.0.0.jar https://repo1.maven.org/maven2/io/github/cdimascio/java-dotenv/5.0.0/java-dotenv-5.0.0.jar

echo "Dependencies downloaded and backed up to dependency-jars directory"
