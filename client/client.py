import os
import cx_Oracle
from flask import Flask, render_template, request

db_user = 'HR'
db_password = 'oracle'
db_connect = '127.0.0.1:1521/ORCL'

app = Flask(__name__)

def prepare_views():
      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      view_cursor = connection.cursor()
      view_cursor.execute('SELECT view_name FROM user_views')
      views = view_cursor.fetchall()
      view_cursor.close()
      connection.close()
      return views

def prepare_patient_ids():
      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      cursor = connection.cursor()
      cursor.execute('SELECT PESEL FROM pacjent')
      ids = cursor.fetchall()
      cursor.close()
      connection.close()
      return ids

@app.route('/')
def index():
      views = prepare_views()
      ids = prepare_patient_ids()
      option_views = []
      for view in views:
            option_views.append(view[0])
      option_ids = []
      for idd in ids:
            if (idd[0] != 0): # Don't want anonymized PESEL to show up.
                  option_ids.append(idd[0])

      return render_template('index.html', view_options=views, patient_ids=option_ids)

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

      parameter = request.form['parameter']
      if current_view == "PACJENCI_NA_MIEJSCU":
            connection = cx_Oracle.connect(db_user, db_password, db_connect)
            cursor = connection.cursor()
            cursor.execute("SELECT * FROM %s" % (current_view)) # Is it safe?
            columns = cursor.fetchall()
            cursor.close()
            connection.close()
      else:
            if parameter == None or parameter == '':
                  return "Parametr musi być użyty"   
            
            if current_view == "DYZURY_W_OKRESIE":
                  if not parameter.isdigit():
                        return "Okres musi być cyfrą."
  
                  connection = cx_Oracle.connect(db_user, db_password, db_connect)
                  cursor = connection.cursor()
                  cursor.execute("SELECT * FROM %s WHERE %s.data_rozpoczecia > SYSDATE - %d" % (current_view, current_view, int(parameter))) # Is it safe?
                  columns = cursor.fetchall()
                  cursor.close()
                  connection.close()

            elif current_view == "PRACOWNICY_ODDZIALU":

                  connection = cx_Oracle.connect(db_user, db_password, db_connect)
                  cursor = connection.cursor()
                  cursor.execute("SELECT * FROM %s WHERE %s.nazwa_oddzialu = '%s'" % (current_view, current_view, parameter)) # Is it safe?
                  columns = cursor.fetchall()
                  cursor.close()
                  connection.close()

            else:
                  if not parameter.isdigit():
                        return "Pesel musi być cyfrą."

                  connection = cx_Oracle.connect(db_user, db_password, db_connect)
                  cursor = connection.cursor()
                  cursor.execute("SELECT * FROM %s WHERE %s.pesel = %d" % (current_view, current_view, int(parameter))) # Is it safe?
                  columns = cursor.fetchall()
                  cursor.close()
                  connection.close()
      
      return render_template("view_template.html", 
                              cols=columns, view=current_view)


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
      if len(patient_id) > 11 or int(patient_id) <= 0:
            return "PESEL składa się z maksymalnie 11 liczb i musi być dodatni"

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
      except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.message)

      connection.commit()
      connection.close()

      return "Dodano pacjenta o danych %d\n%s\n%s\n%s\n" % (patient_id, patient_name, 
                                                            patient_surname, patient_number)

@app.route('/receive_patient', methods=["POST"])
def receive_patient():
      if request.method != 'POST':
            return "Not correct method, use with POST."

      patient_id = request.form["patient_id"]
      if len(patient_id) > 11 or int(patient_id) <= 0:
            return "PESEL składa się z maksymalnie 11 liczb"
      patient_id = int(patient_id)
      patient_ward = request.form["patient_ward"]
      patient_room = request.form["patient_room"]

      if patient_id == None or patient_room == None or patient_ward == None:
            return "Fill out all essential information"

      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      cursor = connection.cursor()
      try:
            cursor.callproc("przyjmij_pacjenta", [patient_id, patient_ward, 
                                                patient_room])
      except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.message)

      connection.commit()
      connection.close()

      return "Przyjęto pacjenta o PESELU %s do oddziału %s do sali %s" % (patient_id, patient_ward, patient_room)

@app.route('/unsubscibe-patient', methods=["POST"])
def unsubscibe_patient():
      if request.method != 'POST':
            return "Not correct method, use with POST."

      patient_id = request.form["patient_id"]
      if len(patient_id) > 11 or int(patient_id) <= 0:
            return "PESEL składa się z maksymalnie 11 liczb"

      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      cursor = connection.cursor()

      try:
            cursor.callproc("wypisz_pacjenta", [int(patient_id)])
      except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.message)

      connection.commit()
      connection.close()
      return "Wypisano pacjenta o PESELU %s" % patient_id

@app.route('/add_diagnose')
def add_diagnose():
      if request.method != 'POST':
            return "Not correct method, use with POST."

      patient_id = request.form["patient_id"]
      patient_diagnose = request.form["patient_diagnose"]
      if len(patient_id) > 11 or int(patient_id) <= 0:
            return "PESEL składa się z maksymalnie 11 liczb"

      if patient_diagnose == None:
            return "Diagnoza musi być podana"

      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      cursor = connection.cursor()
      try:
            cursor.callproc("wypisz_pacjenta", [int(patient_id), patient_diagnose])
      except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.message)

      connection.commit()
      connection.close()
      return "Dodano diagnozę %s dla pacjenta o PESELU %s" % patient_diagnose, patient_id

@app.route('/add_symptom')
def add_symptom():
      if request.method != 'POST':
            return "Not correct method, use with POST."

      patient_id = request.form["patient_id"]
      patient_symptom = request.form["patient_symptom"]
      if len(patient_id) > 11 or int(patient_id) <= 0:
            return "PESEL składa się z maksymalnie 11 liczb"

      if patient_symptom == None:
            return "Diagnoza musi być podana"

      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      cursor = connection.cursor()
      try:
            cursor.callproc("dodaj_objawy", [int(patient_id), patient_symptom])
      except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.message)

      connection.commit()
      connection.close()
      return "Dodano symptomy %s dla pacjenta o PESELU %s" % patient_symptom, patient_id


@app.route('/add_money')
def add_money():
      connection = cx_Oracle.connect(db_user, db_password, db_connect)
      cursor = connection.cursor()
      try:
            cursor.callproc("dodatek_dyzurowy")
      except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.message)

      connection.commit()
      connection.close()
      return "Dodatek dodany"

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=1337)