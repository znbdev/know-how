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

# Reference
