import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import sys

# Configuración
smtp_server = 'smtp-relay.gmail.com'
username = 'helpdesk@tudominio.com'
password = '.'  # Reemplaza con tu contraseña real
from_addr = 'helpdesk@tudominio.com'
to_addr = 'cliente@otrodominio.com'

# Crear mensaje
message = MIMEMultipart()
message['From'] = from_addr
message['To'] = to_addr
message['Subject'] = 'Prueba SMTP Relay'
body = 'Este es un correo de prueba.'
message.attach(MIMEText(body, 'plain'))

# OPCIÓN 1: Usando SSL directamente (puerto 465)
def test_ssl():
    try:
        print("Intentando conexión SSL en puerto 465...")
        server = smtplib.SMTP_SSL(smtp_server, 465)
        server.set_debuglevel(1)  # 1 = muestra detalles de la conexión
        print("Conectado. Intentando login...")
        server.login(username, password)
        print("Login exitoso. Enviando correo...")
        server.sendmail(from_addr, to_addr, message.as_string())
        print("Correo enviado exitosamente!")
        server.quit()
        return True
    except Exception as e:
        print(f"Error SSL: {e}")
        return False

# OPCIÓN 2: Usando STARTTLS (puerto 587)
def test_starttls():
    try:
        print("\nIntentando conexión STARTTLS en puerto 587...")
        server = smtplib.SMTP(smtp_server, 587)
        server.set_debuglevel(1)  # 1 = muestra detalles de la conexión
        print("Conectado. Iniciando STARTTLS...")
        server.ehlo()
        server.starttls()
        server.ehlo()
        print("STARTTLS establecido. Intentando login...")
        server.login(username, password)
        print("Login exitoso. Enviando correo...")
        server.sendmail(from_addr, to_addr, message.as_string())
        print("Correo enviado exitosamente!")
        server.quit()
        return True
    except Exception as e:
        print(f"Error STARTTLS: {e}")
        return False

# Ejecutar ambos métodos
ssl_success = test_ssl()
if not ssl_success:
    starttls_success = test_starttls()
    if not starttls_success:
        print("\nAmbos métodos fallaron. Posibles problemas:")
        print("1. Credenciales incorrectas")
        print("2. Servidor SMTP mal configurado")
        print("3. Puertos bloqueados por firewall")
        print("4. Cuenta con autenticación de dos factores (necesitas una 'contraseña de aplicación')")
        print("5. El servidor requiere configuraciones específicas")