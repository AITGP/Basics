#!/bin/bash
export ORACLE_HOME=/oracle/product/19cR3/db
export LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME:$PATH

# -------------------------------
# Paso 1: Commit y push al repositorio
# -------------------------------
REPO_DIR="/backup/git_respaldo/repositorio_sql"
cd "$REPO_DIR" || { echo "No se pudo acceder al repo"; exit 1; }

FECHA=$(date +"%I:%M %p")
/usr/local/bin/git add .
/usr/local/bin/git commit -m "cambios de paquetes a las $FECHA"
/usr/local/bin/git push origin master

# -------------------------------
# Paso 2: Generar logs de git
# -------------------------------
OUTPUT_DIR="/backup/git_respaldo/git_logs"
mkdir -p "$OUTPUT_DIR"

# Commits: ID | Autor | Fecha | Mensaje
/usr/local/bin/git log --pretty=format:"%H|%an|%ad|%s" --date=iso > "$OUTPUT_DIR/commits.log"

# Archivos modificados por commit
/usr/local/bin/git log --name-status --pretty=format:"---%H" > "$OUTPUT_DIR/files.log"

# Diffs completos por commit
/usr/local/bin/git log --pretty=format:"---%H" --patch > "$OUTPUT_DIR/diffs.log"

# -------------------------------
# Paso 3: Ejecutar script Python
# -------------------------------
cd /backup/git_respaldo/ || exit 1
. .venv/bin/activate
python3 git_to_oracle.py
