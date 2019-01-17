import os
import cx_Oracle
from flask import Flask, render_template, request

db_user = 'HR'
db_password = 'oracle'
db_connect = '192.168.0.66:1521/ORCL'

app = Flask(__name__)

def prepare_views():
      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      view_cursor = connection.cursor()
      view_cursor.execute('SELECT view_name FROM user_views')
      views = view_cursor.fetchall()
      view_cursor.close()
      connection.close()
      return views

@app.route('/')
def index():
      views = prepare_views()
      option_views = []
      for view in views:
            option_views.append(view[0])

      return render_template('index.html', view_options=views)

@app.route('/views', methods=['POST'])
def views():
      if request.method != 'POST':
            return "Not correct method, use with POST."
      
      
      current_view = request.form.get('view_name')
      if current_view == None:
            return "Didn't specify view."

      views = prepare_views()
      if not any(current_view in view for view in views):
            return "Non existent view: " + current_view

      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      cursor = connection.cursor()
      cursor.execute("SELECT * FROM %s" % current_view) # Is it safe?
      columns = cursor.fetchall()
      cursor.close()
      connection.close()
      
      return render_template("view_template.html", 
                              cols=columns, view=current_view) # Need to escape?


@app.route("/query", methods=["POST"])
def query():
      if request.method != 'POST':
            return "Not correct method, use with POST."
      query_text = request.form['query']
      if query_text == None:
            return "Didn't enter query"

      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      cursor = connection.cursor()
      cursor.execute(' ' + query_text)
      columns = cursor.fetchall()
      cursor.close()
      connection.close()
      return render_template("view_template.html", 
                              cols=columns, 
                              view="""Thank you for using custom query functionality. 
                                    Please do not abuse it.""")


@app.route("/add_patient", methods=["POST"])
def add_patient():
      if request.method != 'POST':
            return "Not correct method, use with POST."
      patient_id =      request.form["patient_id"]
      if (len(patient_id) > 11):
            return "PESEL składa się z maksymalnie 11 liczb"

      patient_id = int(patient_id)
      patient_name =    request.form["patient_name"]
      patient_surname = request.form["patient_surname"]
      patient_number =  request.form["patient_phone_number"]

      if (len(patient_number) > 9):
            return "Numer telefonu ma maksymalnie 9 cyfr."

      if patient_id == None or patient_name == None or patient_number == None or patient_surname == None:
            return "Please fill out all essential information."

      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      cursor = connection.cursor()
      try:
            cursor.callproc("dodaj_pacjenta", [patient_id, patient_name, 
                                                patient_surname, patient_number])
      except cx_Oracle.Error as e:
            error, = e.args
            print(error.message)

      connection.commit()
      connection.close()

      return "Dodano pacjenta o danych %d\n%s\n%s\n%s\n" % (patient_id, patient_name, 
                                                            patient_surname, patient_number)

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=1337)