# -*- coding: utf-8 -*-
import cx_Oracle
import os

# Asegurarte que usa UTF-8
os.environ["NLS_LANG"] = ".AL32UTF8"

# Configuración Oracle
USERNAME = "tu_usuario"
PASSWORD = "tu_password"
DSN = "host:puerto/servicio"

# Conectar
con = cx_Oracle.connect(USERNAME, PASSWORD, DSN)
cur = con.cursor()

# Select simple
cur.execute("SELECT SYSDATE FROM dual")
row = cur.fetchone()
print("Conexión exitosa. Fecha de Oracle:", row[0])

cur.close()
con.close()
