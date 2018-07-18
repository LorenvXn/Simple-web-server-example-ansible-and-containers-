
**Machine learning and Data Vizualization**
<br>
 <i> ... with Nginx and Expect automation </i></br>



// here to be added link to how to implement environment in ansible

1) Make sure mysql service is running:

```
root@tr0n:~# docker exec shelby /etc/init.d/mysql status
 * MySQL Community Server 5.7.22 is running
root@tr0n:~# 
```

2) Make sure nginx is running:

```
root@tr0n:~# docker exec shelby /etc/init.d/nginx status
 * nginx is running
root@tr0n:~#
```

3) Create database employees and its tables, and populate them as per script <a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/Real%20case%20scenarios/Deploy%20Machine%20Learning%20and%20MysqlSHELL%20env/Using%20Expect/scripts%20and%20files/create_dba_and_tables.sh">create_dba_and_tables.sh </a>
```
root@tr0n:~# docker exec -ti shelby mysql -uroot -pabc123 -e "use employees; show tables;"
mysql: [Warning] Using a password on the command line interface can be insecure.
+----------------------+
| Tables_in_employees  |
+----------------------+
| current_dept_emp     |
| data                 |
| departments          |
| dept_emp             |
| dept_emp_latest_date |
| dept_manager         |
| employees            |
| salaries             |
| titles               |
+----------------------+
```

4) Check if mysqlsh-py is accessible:
```
root@tr0n:~# docker exec -ti shelby mysqlsh --uri root:abc123@localhost:33060/employees --py
mysqlx: [Warning] Using a password on the command line interface can be insecure.
Creating a Session to 'root@localhost:33060/employees'
Your MySQL connection id is 10 (X protocol)
Server version: 5.7.22 MySQL Community Server (GPL)
Default schema `employees` accessible through db.
MySQL Shell 1.0.11

Copyright (c) 2016, 2017, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type '\help' or '\?' for help; '\quit' to exit.

Currently in Python mode. Use \sql to switch to SQL mode and execute queries.
mysql-py> \q
Bye!
```
