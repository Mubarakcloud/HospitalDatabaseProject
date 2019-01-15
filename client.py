import os
import cx_Oracle
from flask import Flask

db_user = 'system'
db_password = 'oracle'
db_connect = '192.168.0.66:1521/ORCL'

app = Flask(__name__)

@app.route('/')
def index():
    connection = cx_Oracle.connect(db_user, db_password, db_connect)
    cur = connection.cursor()
    cur.execute("SELECT 'Witam w szpitalu' FROM DUAL")
    col = cur.fetchone()[0]
    cur.close()
    connection.close()
    return col

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=8080) 