# Backup de Auditoría de Objetos de Base de Datos 🔐

Este repositorio contiene backups de auditoría de los objetos auditables de la base de datos de producción. El propósito es mantener un registro histórico y seguro de los cambios en la estructura de la base de datos, como tablas, vistas, procedimientos almacenados y funciones.

---

## 📋 Contenido
BBDD - estan todos los scripts que se deben correr a nivel de base de datos.
Servidor OS - Linux  - estan todos los comandos que se deberian ejecutar en el servidor.

## 🚀 Uso

Este repositorio es de **solo lectura**. Su objetivo principal es servir como un **historial de versiones** para la auditoría y la recuperación de información.

* **Consultar el Historial:** Para ver cómo ha cambiado un objeto a lo largo del tiempo, navega por las carpetas de fecha y utiliza las herramientas de Git para comparar los archivos `.sql` correspondientes (por ejemplo, `git diff`).
* **Recuperar una Versión:** Si necesitas restaurar la definición de un objeto a un estado anterior, simplemente copia el archivo `.sql` de la fecha deseada.

---

## ⚙️ Proceso de Generación

Los archivos de auditoría se generan automáticamente a través de un script programado que se ejecuta diariamente. Este script se conecta a la base de datos de producción, extrae las definiciones de los objetos y luego sube los cambios a este repositorio.

* **Script de Backup:** `backup_auditoria.sh`
* **Frecuencia:** Diariamente a las 2:00 AM.
* **Objetos Auditados:** Todas las tablas, vistas, funciones y procedimientos almacenados.

---
## Ejemplo
![](https://github.com/AITGP/Basics/blob/master/Instalar%20Git%20en%20Servidor%20Linux/Git_Oracle_Apex.gif)

## ⚠️ Advertencia

Para cualquier duda o problema, contacta con el administrador de la base de datos.
```