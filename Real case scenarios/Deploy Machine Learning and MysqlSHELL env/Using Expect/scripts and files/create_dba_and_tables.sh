#!/usr/bin/sh 

######
# script based on Percona material:
# https://www.percona.com/blog/2017/01/16/ad-hoc-data-visualization-and-machine-learning-with-mysqlshell/
# ... and ...
# https://github.com/datacharmer/test_db
#####

#### create database employees ###

docker exec shelby mysql -uroot  -pabc123 -e "DROP DATABASE IF EXISTS employees; 
CREATE DATABASE IF NOT EXISTS employees;"


### create table employees ###

docker exec shelby mysql -uroot -pabc123 -e "use employees; CREATE TABLE employees (
    `emp_no`      INT             NOT NULL,
    `birth_date`  DATE            NOT NULL,
    `first_name`  VARCHAR(14)     NOT NULL,
    `last_name`   VARCHAR(16)     NOT NULL,
    `gender`      ENUM ('M','F')  NOT NULL,
    `hire_date`   DATE            NOT NULL,
    PRIMARY KEY (`emp_no`)
);" 


### create tables departments, dept_emp, table_titles, salaries  ###

docker exec shelby mysql -uroot -pabc123 -e "use employees; CREATE TABLE departments (
    `dept_no`     CHAR(4)         NOT NULL,
    `dept_name`   VARCHAR(40)     NOT NULL,
    PRIMARY KEY (`dept_no`),
    UNIQUE  KEY (`dept_name`)
);


CREATE TABLE dept_emp (
    `emp_no`      INT             NOT NULL,
    `dept_no`     CHAR(4)         NOT NULL,
    `from_date`   DATE            NOT NULL,
    `to_date`     DATE            NOT NULL,
    FOREIGN KEY (`emp_no`)  REFERENCES employees   (`emp_no`)  ON DELETE CASCADE,
    FOREIGN KEY (`dept_no`) REFERENCES departments (`dept_no`) ON DELETE CASCADE,
    PRIMARY KEY (`emp_no`,`dept_no`)
);


CREATE TABLE titles (
    `emp_no`      INT             NOT NULL,
    `title`       VARCHAR(50)     NOT NULL,
    `from_date`   DATE            NOT NULL,
    `to_date`     DATE,
    FOREIGN KEY (`emp_no`) REFERENCES employees (`emp_no`) ON DELETE CASCADE,
    PRIMARY KEY (`emp_no`,`title`, `from_date`)
);



CREATE TABLE salaries (
    `emp_no`      INT             NOT NULL,
    `salary`      INT             NOT NULL,
    `from_date`   DATE            NOT NULL,
    `to_date`     DATE            NOT NULL,
    FOREIGN KEY (`emp_no`) REFERENCES employees (`emp_no`) ON DELETE CASCADE,
    PRIMARY KEY (`emp_no`, `from_date`)
);"


### supposing the dump files are copied under /test folder
### of the container shelby

docker exec shelby wget -P /test https://github.com/datacharmer/test_db/blob/master/load_salaries1.dump 
docker exec shelby wget -P /test https://github.com/datacharmer/test_db/blob/master/load_salaries2.dump
docker exec shelby wget -P /test https://github.com/datacharmer/test_db/blob/master/load_salaries3.dump
docker exec shelby wget -P /test https://github.com/datacharmer/test_db/blob/master/load_departments.dump
docker exec shelby wget -P /test https://github.com/datacharmer/test_db/blob/master/load_titles.dump
docker exec shelby wget -P /test https://github.com/datacharmer/test_db/blob/master/load_dept_manager.dump
docker exec shelby wget -P /test https://github.com/datacharmer/test_db/blob/master/load_dept_emp.dump

##################
# Check it in a simple way:
# root@tr0n:~# docker exec shelby ls /test
# load_departments.dump
# load_dept_emp.dump
# load_dept_manager.dump
# load_salaries1.dump
# load_salaries2.dump
# load_salaries3.dump
# load_titles.dump



### insert data into tables ###

docker exec shelby mysql -uroot -pabc123 -e "use employees;
SELECT 'LOADING departments' as 'INFO';
source /test/load_departments.dump ;
SELECT 'LOADING employees' as 'INFO';
source /test/load_employees.dump ;
SELECT 'LOADING dept_emp' as 'INFO';
source /test/load_dept_emp.dump ;
SELECT 'LOADING dept_manager' as 'INFO';
source /test/load_dept_manager.dump ;
SELECT 'LOADING titles' as 'INFO';
source /test/load_titles.dump ;
SELECT 'LOADING salaries' as 'INFO';
source /test/load_salaries1.dump ;
source /test/load_salaries2.dump ;
source /test/load_salaries3.dump ;"

### create table data ###

docker exec shelby mysql -uroot -pabc123 -e "use employees; CREATE TABLE `data` (
  `emp_no` int(11) NOT NULL,
  `age` int(11) DEFAULT NULL,
  `hired` int(11) DEFAULT NULL,
  `gender` int(11) DEFAULT NULL,
  `salary` int(11) DEFAULT NULL,
  `department` int(11) DEFAULT NULL,
  PRIMARY KEY (`emp_no`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;"

### insert data into data ### 
docker exec shelby mysql -uroot -pabc123 -e "use employees; INSERT INTO data SELECT employees.emp_no, 
YEAR(now()) - YEAR(birth_date) as age, YEAR(now()) - YEAR(hire_date) as hired, 
IF(gender='M',0,1) as gender, max(salary) as salary, RIGHT(dept_no,1) as department from employees, salaries, dept_emp 
WHERE employees.emp_no = salaries.emp_no and employees.emp_no = dept_emp.emp_no and dept_emp.to_date="9999-01-01" 
GROUP BY emp_no, dept_emp.dept_no;"
