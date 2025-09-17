# Backup de Auditoría de Objetos de Base de Datos 🔐

Este repositorio contiene backups de auditoría de los objetos auditables de la base de datos de producción. El propósito es mantener un registro histórico y seguro de los cambios en la estructura de la base de datos, como tablas, vistas, procedimientos almacenados y funciones.

---

## 📋 Contenido

El repositorio está organizado por fecha, con una carpeta para cada día en que se realizó un backup. Cada carpeta de fecha contiene archivos `.sql` que representan el estado de los objetos auditados en ese momento.

```

/
├── 2025-09-15/
│   ├── auditoria\_tablas.sql
│   ├── auditoria\_vistas.sql
│   └── auditoria\_procedimientos.sql
├── 2025-09-16/
│   ├── auditoria\_tablas.sql
│   ├── auditoria\_vistas.sql
│   └── auditoria\_procedimientos.sql
└── README.md

```
---

## 🚀 Uso

Este repositorio es de **solo lectura**. Su objetivo principal es servir como un **historial de versiones** para la auditoría y la recuperación de información.

* **Consultar el Historial:** Para ver cómo ha cambiado un objeto a lo largo del tiempo, navega por las carpetas de fecha y utiliza las herramientas de Git para comparar los archivos `.sql` correspondientes (por ejemplo, `git diff`).
* **Recuperar una Versión:** Si necesitas restaurar la definición de un objeto a un estado anterior, simplemente copia el archivo `.sql` de la fecha deseada.

---

## ⚙️ Proceso de Generación

Los archivos de auditoría se generan automáticamente a través de un script programado que se ejecuta diariamente. Este script se conecta a la base de datos de producción, extrae las definiciones de los objetos (usando herramientas como `mysqldump` para MySQL o `pg_dump` para PostgreSQL) y luego sube los cambios a este repositorio.

* **Script de Backup:** `backup_auditoria.sh`
* **Frecuencia:** Diariamente a las 2:00 AM.
* **Objetos Auditados:** Todas las tablas, vistas, funciones y procedimientos almacenados.

---

## ⚠️ Advertencia

**No hagas cambios directamente en este repositorio.** Cualquier modificación manual podría desincronizar el historial de auditoría y se sobrescribirá en el próximo backup automático.

Para cualquier duda o problema, contacta con el administrador de la base de datos.
```