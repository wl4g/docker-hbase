# Docker HBase images

## 1. Quick start

- Start HBase (Standalone)

```bash
mkdir -p /mnt/disk1/log/hbase-standalone/ # Logs directory
mkdir -p /mnt/disk1/hbase-standalone/data/ # Temporary data directory

docker run -d \
--name hbase1 \
--network host \
-v /mnt/disk1/hbase-standalone/data/:/tmp/ \
-v /mnt/disk1/log/hbase-standalone/:/opt/apps/ecm/hbase/logs/ \
wl4g/hbase:hbase-2.1.0-phoenix-5.1.1 \
/bin/sh -c "hbase-daemon.sh start master; tail -f /dev/null"
```

- Run phoenix SQL client

```bash
docker exec -it hbase1 bash

# start sql cli
sqlline.py

# list tables
!tables

# exit
!quit
```

## 2. Development Guide

```bash
./build.sh build
./build.sh push
```
