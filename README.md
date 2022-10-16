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

- Run phoenix SQL client and testing

```bash
docker exec -it hbase1 bash

# start sql cli.
sqlline.py

# list all tables,
!tables

# Create test table,
create schema if not exists "test";
create table if not exists "test"."t_test1" (
    "ROW" VARCHAR PRIMARY KEY,
    "info"."name" VARCHAR(20),
    "info"."age" VARCHAR(20)
) COLUMN_ENCODED_BYTES=0;

# Display table struct.
!describe "test"."t_test1";

# Upsert test data.
upsert into "test"."t_test1" (name, age) values ("jack01", 99);

select * from "test"."t_test1" limit 10;

!quit
```

## 2. Development Guide

```bash
./build.sh build
./build.sh push
```
