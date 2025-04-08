**Tested on:** 
```plaintext
MariaDB 10.11.11 (master and replica)
master-server: Ubuntu 24.04.2 LTS
replica-server: Debian GNU/Linux 12 (bookworm)
```

## Introduction
A database that mirrors a primary database is called the replica. Changes on the master are applied to the replica without much delay. A replica can be used to  create a backup. 
This has the advantage, that the primary database is not slowed down. 

**Note:** the replication database can not serve as a backup on its own. If data
is deleted on the primary, these changes are also applied on the replica.
Backups need to be stored seperately. 

**Attention:** The normal replication setup is unsafe, because the data transfer
between master and replica is not encrypted. This setup is only useful for test 
purposes and should not be used in a production environment. 


## 1. Prepare replication on the master-server

### create a slave-user on the master-server

~~~~sql
MariaDB [(none)]> CREATE USER 'replication_user'@'%' IDENTIFIED BY 'aSuperSafePassword';

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.*  TO 'replication_user'@'%';
~~~~

### edit the file /etc/mysql/my.cnf on the master-server
```plaintext
[mysqld]
bind-address=127.0.0.1,[master-ip-addess]  #the server-address is addedd here, dont remove localhost-ip-address
local-infile=0
log-bin  #enable binary-logging
server_id=250 
log-basename=master1
binlog-format=mixed
```

### restart mariadb to apply changes
```bash
systemctl restart mariadb
```

### lock the tables

~~~~sql
MariaDB [(none)]>  FLUSH TABLES WITH READ LOCK;
~~~~


### show the positon of the current binary-log status

~~~~sql
MariaDB [(none)]>  SHOW MASTER STATUS;
~~~~


### save the following results for later

~~~~sql
MariaDB [(none)]> SHOW MASTER STATUS;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| master1-bin.000002 |      820 |              |                  |
+--------------------+----------+--------------+------------------+
~~~~



### install mariadb-backup for transfering the database
```bash
sudo apt-get install mariadb-backup
```


### create the backup for the slave and prepare the dataset

```bash
mariadb-backup --backup \
   --target-dir=/var/mariadb/backup/ \
   --user=[mariadb-user] --password=[foo]

mariadb-backup --prepare \
   --target-dir=/var/mariadb/backup/

```

### the database on the master can already be unlocked again

~~~~sql
MariaDB [(none)]> UNLOCK TABLES;
~~~~

### transfer Backup to the replica-server
```bash
rsync -avP /var/mariadb/backup ServerReplica:/var/mariadb/backup
```

## 2. Setup replication on the replica-server

### install mariadb-backup on the replica
```bash
sudo apt-get install mariadb-backup
```

### restore the backup

**Note:** Next command simply copies all the files from the backup-folder
to /var/lib/mysql/ . If /var/lib/mysql/ is not empty, an error is raised.
It is also possible to manually copy/replace single databases to this folder, that needs to be synchronous with the master. Every single database is represented by a folder with the database-name.
If the slave-database was already in use and had other database user configured in, the database mysql should not be replaced.

```bash
mariabackup --copy-back \
   --target-dir=/var/mariadb/backup/

```

### change ownership, if necessary
```bash
chown -R mysql:mysql /var/lib/mysql/
```

### reset slave on slave-server, otherwise next command can raise an error
```bash
MariaDB [(none)]> RESET SLAVE;
```

### apply master settings on slave server
~~~~sql
MariaDB [(none)]> 
CHANGE MASTER TO
  MASTER_HOST='[master-ip-address]',
  MASTER_USER='replication_user',
  MASTER_PASSWORD='aSuperSafePassword',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='master1-bin.000002',
  MASTER_LOG_POS=820,
  MASTER_CONNECT_RETRY=10;
~~~~
  
### start the slave  
```bash
MariaDB [(none)]> START SLAVE;
```

### show slave status 
**Note:** next command shows a long status list, there should not be any errors. Further it is recommended to monitor both databases or trigger a database change on master and check, if the change was immediately applied on the slave  

~~~~sql
MariaDB [(none)]> SHOW SLAVE STATUS \G
~~~~




