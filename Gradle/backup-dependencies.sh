#!/bin/bash

# 创建备份目录
mkdir -p dependency-backup

# 使用Gradle任务列出所有依赖并下载
./gradlew dependencies --configuration runtimeClasspath > dependency-backup/dependencies-list.txt

# 复制本地缓存中的依赖文件
cp -r ~/.gradle/caches/modules-2/files-2.1/ dependency-backup/gradle-cache/

# 创建依赖信息文件
echo "Backup created on: $(date)" > dependency-backup/backup-info.txt
echo "Project: example-api" >> dependency-backup/backup-info.txt
./gradlew --version >> dependency-backup/backup-info.txt

echo "Dependencies backup completed in dependency-backup directory"
