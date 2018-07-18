
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
mysql-py> db.employees.select().limit(5)
+--------+--------------------+------------+-----------+--------+--------------------+
| emp_no | birth_date         | first_name | last_name | gender | hire_date          |
+--------+--------------------+------------+-----------+--------+--------------------+
|  10001 | 1953-09-02 0:00:00 | Georgi     | Facello   | M      | 1986-06-26 0:00:00 |
|  10002 | 1964-06-02 0:00:00 | Bezalel    | Simmel    | F      | 1985-11-21 0:00:00 |
|  10003 | 1959-12-03 0:00:00 | Parto      | Bamford   | M      | 1986-08-28 0:00:00 |
|  10004 | 1954-05-01 0:00:00 | Chirstian  | Koblick   | M      | 1986-12-01 0:00:00 |
|  10005 | 1955-01-21 0:00:00 | Kyoichi    | Maliniak  | M      | 1989-09-12 0:00:00 |
+--------+--------------------+------------+-----------+--------+--------------------+
5 rows in set (0.04 sec)

mysql-py> \q
Bye!
```
<br>

5) Obtain vizualization of the data with the help of nginx and running expect scripting

<i> files *.txt for data analysis were put under "/". Move them at your will, but do not forget to change
 path under the .tcl script </i>

Run the <a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/Real%20case%20scenarios/Deploy%20Machine%20Learning%20and%20MysqlSHELL%20env/Using%20Expect/scripts%20and%20files/hehe.tcl"> Expect</a> script to obtain relationship between:
<br>
a) Salary and Gender

![ScreenShot](https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/Real%20case%20scenarios/Deploy%20Machine%20Learning%20and%20MysqlSHELL%20env/Using%20Expect/ship_it(test).png)

<br>
b) Age and Salary

![ScreenShot](https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/Real%20case%20scenarios/Deploy%20Machine%20Learning%20and%20MysqlSHELL%20env/Using%20Expect/age_and_sal.png)

<br>
c) Hired and Salary

![ScreenShot](https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/Real%20case%20scenarios/Deploy%20Machine%20Learning%20and%20MysqlSHELL%20env/Using%20Expect/hired_salary.png)


Pictures have been obtained with the help of nginx - creating a html page that will contain the image source:

<i> for instance, for Hired and Salary, the /var/www/html/pfehehe.html looks as below: </i>

```
root@tr0n:~# docker exec shelby cat /var/www/html/pfehehe.html
<!DOCTYPE html>
<html>
<head>
<title>Hired and Salary</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
 <img src="shipit_2.png" />
</body>
</html>

```
<i> ...indeed, it needs more automation on this level... </i>
<i> to be continued </i>

<br>
6) Make predictions

<i> to be continued </i> 

