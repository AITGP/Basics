#!/bin/bash

# Ruta del repositorio (ajústala a donde tengas tu repo clonado)
REPO_DIR="/backup/git_respaldo/repositorio_sql"

# Entrar al directorio
cd "$REPO_DIR" || exit

# Obtener fecha y hora en formato HH:MM AM/PM
FECHA=$(date +"%I:%M %p")

# Hacer add, commit y push
git add .
git commit -m "cambios de paquetes a las $FECHA"
git push origin master