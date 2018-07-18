#!/usr/bin/sh 


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
