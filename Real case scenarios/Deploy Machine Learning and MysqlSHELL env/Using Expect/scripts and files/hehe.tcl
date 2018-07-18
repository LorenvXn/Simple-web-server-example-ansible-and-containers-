#!/usr/bin/expect

set timeout 10

spawn  mysqlsh --uri root:abc123@localhost:33060/employees  --py
#expect "mysql-py>" { send "db.employees.select().limit(5) \r" }
expect "mysql-py>" { send "db \r"}
expect "mysql-py>" { send "session \r"}
expect "mysql-py>" { send "import matplotlib \r" }
expect "mysql-py>" { send "import mplh5canvas \r" }
expect "mysql-py>" { send "matplotlib.use('module://mplh5canvas.backend_h5canvas') \r" }
expect "mysql-py>" { send "matplotlib.use('Agg') \r" }
expect "mysql-py>" { send "import pandas as pd \r"}
expect "mysql-py>" { send "import numpy as np \r"}
expect "mysql-py>" { send "import seaborn \r"}
expect "mysql-py>" { send "import matplotlib.pyplot as plt \r"}
expect "mysql-py>" { send "from sklearn import tree \r"}
expect "mysql-py>" { send [exec cat /extract.txt]  } 
send "\r\n"
expect "mysql-py>" { send "\r"}
sleep 2
expect "mysql-py>" { send "print(db) \r"}
sleep 2
expect "mysql-py>" { send "gender = column_to_list(\"gender\") \r"}
sleep 4
expect "mysql-py>" { send "salary = column_to_list(\"salary\") \r"}
sleep 4
expect "mysql-py>" { send "age = column_to_list(\"age\") \r"}
sleep 4
expect "mysql-py>" { send "hired = column_to_list(\"hired\") \r"}
sleep 4
expect "mysql-py>" { send "department = column_to_list(\"department\") \r"}
expect "mysql-py>"  { send [exec cat /panda.txt]  }
send "\r\n"
expect "mysql-py>" { send "\r"}
sleep 2
expect "mysql-py>" { send [exec cat /sal.txt] }
sleep 2
send "\r\n"
expect "mysql-py>" { send "\r"}
sleep 2
expect "mysql-py>" { send [exec cat /vis.txt ] } 
sleep 2
send "\r\n"
expect "mysql-py>" { send "\r"}
expect "mysql-py>" { send "plt.plot(100) \r"}
sleep 2
expect "mysql-py>" { send "plt.savefig('/home/shipit.png') \r"}
sleep 2
expect  "mysql-py>" { send [exec cat /age_sal.txt ] }
sleep 2
send "\r\n"
expect "mysql-py>" { send "\r"}
expect "mysql-py>" { send "plt.plot(100) \r"}
sleep 2
expect "mysql-py>" { send "plt.savefig('/home/shipit_1.png') \r"}
sleep 2
expect "mysql-py>" { send [exec cat /hired_sal.txt ] }
sleep 2
send "\r\n"
expect "mysql-py>" { send "\r"}
expect "mysql-py>" { send "plt.plot(100) \r"}
sleep 2
expect "mysql-py>" { send "plt.savefig('/home/shipit_2.png') \r"}
sleep 2

interact
