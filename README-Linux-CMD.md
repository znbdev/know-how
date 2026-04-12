Linux CMD
=====

# SCP to server

```shell script
# Local <=> Server
SERVER_USERNAME=opc && echo ${SERVER_USERNAME}
WORK_DATE=$(date +%Y%m%d) && echo ${WORK_DATE}
SERVER_HOST=yourip && echo ${SERVER_HOST}
SERVER_DIR=/home/${SERVER_USERNAME}/workspace/${WORK_DATE} && echo ${SERVER_DIR}
WORK_DIR=~/workspace/work/${WORK_DATE} && echo ${WORK_DIR}
mkdir ${WORK_DIR}
cd ${WORK_DIR} && pwd

# Local to Server
scp -r ${WORK_DIR} ${SERVER_USERNAME}@${SERVER_HOST}:${SERVER_DIR}
# Server to Local
scp -r ${SERVER_USERNAME}@${SERVER_HOST}:${SERVER_DIR} ./

```

# 一行命令来关闭占用指定端口的进程，以关闭 3000 端口为例

```bash
sudo kill -9 $(sudo lsof -t -i:3000)
```

# Reference
