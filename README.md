# Docker HBase images

## 1. Quick start

- Start HBase (Standalone)

```bash
docker run -d \
--name hbase1 \
--network host \
wl4g/hbase:hbase-2.1.0-phoenix-5.1.1 \
/bin/sh -c "hbase-daemon.sh start master; tail -f /dev/null"
```

## 2. Development Guide

```bash
./build.sh build
./build.sh push
```
