# -*- coding: utf-8 -*-
import cx_Oracle
import os
import datetime
import re

os.environ["NLS_LANG"] = ".AL32UTF8"

# Configuracion Oracle
USERNAME = "tu_usuario"
PASSWORD = "tu_password"
DSN = "host:puerto/servicio"

# Carpeta donde estan los logs
LOG_DIR = "/backup/git_respaldo/git_logs"

def parse_commits(cur):
    print("Procesando commits...")
    commit_count = 0
    with open(os.path.join(LOG_DIR, "commits.log"), "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, 1):
            parts = line.strip().split("|", 3)
            if len(parts) < 4:
                print("Línea {} ignorada: formato incorrecto".format(line_num))
                continue

            commit_id, author, commit_date_str, message = parts

            # Parsear fecha (git log --date=iso produce formato: 2023-12-01 10:30:45 +0100)
            commit_date = None
            try:
                date_clean = re.sub(r'\s[+-]\d{4}$', '', commit_date_str.strip())
                commit_date = datetime.datetime.strptime(date_clean, "%Y-%m-%d %H:%M:%S")
            except ValueError as e:
                print("Error parseando fecha en línea {}: {} - {}".format(line_num, commit_date_str, e))

            try:
                cur.execute("SELECT COUNT(*) FROM GIT_COMMITS WHERE commit_id = :1", (commit_id,))
                exists = cur.fetchone()[0]

                if exists == 0:
                    cur.execute("""
                        INSERT INTO GIT_COMMITS (commit_id, author, commit_date, message)
                        VALUES (:1, :2, :3, :4)
                    """, (commit_id, author, commit_date, message))
                    commit_count += 1
            except Exception as e:
                print("Error insertando commit {}: {}".format(commit_id, e))

    print("Commits procesados: {}".format(commit_count))

def parse_files(cur):
    print("Procesando archivos...")
    file_count = 0
    with open(os.path.join(LOG_DIR, "files.log"), "r", encoding="utf-8") as f:
        commit_id = None
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if line.startswith("---"):
                commit_id = line[3:].strip()
            elif line and commit_id and not line.startswith("commit "):
                parts = line.split("\t", 1)
                if len(parts) == 2:
                    status, filename = parts
                    try:
                        cur.execute("""
                            INSERT INTO GIT_FILES (commit_id, status, filename)
                            VALUES (:1, :2, :3)
                        """, (commit_id, status, filename))
                        file_count += 1
                    except Exception as e:
                        print("Error insertando archivo en línea {}: {}".format(line_num, e))
                elif line and not line.startswith("Date:") and not line.startswith("Author:"):
                    print("Línea {} formato inesperado: {}...".format(line_num, line[:50]))
    
    print("Archivos procesados: {}".format(file_count))

def parse_diffs(cur):
    print("Procesando diffs...")
    diff_count = 0

    # Leer archivo intentando varios encodings
    encodings = ['utf-8', 'latin1', 'cp1252', 'iso-8859-1']
    file_content = None

    for encoding in encodings:
        try:
            with open(os.path.join(LOG_DIR, "diffs.log"), "r", encoding=encoding) as f:
                file_content = f.readlines()
            print("Archivo leido con encoding: {}".format(encoding))
            break
        except UnicodeDecodeError:
            continue

    if file_content is None:
        print("Error: No se pudo leer el archivo diffs.log con ningun encoding")
        return

    commit_id = None
    current_file = None
    diff_lines = []

    for line_num, line in enumerate(file_content, 1):
        try:
            line = line.rstrip("\n")

            if line.startswith("---") and not line.startswith("--- a/"):
                # Guardar diff anterior sin truncar
                if commit_id and current_file and diff_lines:
                    diff_text = "".join(diff_lines)
                    cur.execute("""
                        INSERT INTO GIT_DIFFS (commit_id, filename, diff_text)
                        VALUES (:1, :2, :3)
                    """, (commit_id, current_file, diff_text))
                    diff_count += 1

                commit_id = line[3:].strip()
                current_file = None
                diff_lines = []

            elif line.startswith("diff --git"):
                match = re.search(r'b/(.+)$', line)
                if match:
                    current_file = match.group(1)
                    diff_lines = [line + "\n"]

            elif line.startswith("+++ b/"):
                current_file = line[6:].strip()
                diff_lines.append(line + "\n")

            elif commit_id and current_file:
                diff_lines.append(line + "\n")

        except Exception as e:
            print("Error procesando linea {}: {}".format(line_num,e))
            continue

    # Guardar ultimo diff
    if commit_id and current_file and diff_lines:
        try:
            diff_text = "".join(diff_lines)
            if len(diff_text) > 4000:
                diff_text = diff_text[:3900] + "\n... (truncado)"
            cur.execute("""
                INSERT INTO GIT_DIFFS (commit_id, filename, diff_text)
                VALUES (:1, :2, :3)
            """, (commit_id, current_file, diff_text))
            diff_count += 1
        except Exception as e:
            print("Error insertando último diff: {}".format(e))

    print("Diffs procesados: {}".format(diff_count))


def main():
    try:
        print("Conectando a Oracle...")
        con = cx_Oracle.connect(USERNAME, PASSWORD, DSN)
        cur = con.cursor()

        print("Iniciando procesamiento...")

        for filename in ["commits.log", "files.log", "diffs.log"]:
            filepath = os.path.join(LOG_DIR, filename)
            if not os.path.exists(filepath):
                print("Error: Archivo {} no encontrado".format(filepath))
                return
            print("Archivo {}: {} bytes".format(filename, os.path.getsize(filepath)))

        parse_commits(cur)
        parse_files(cur)
        parse_diffs(cur)

        print("Haciendo commit...")
        con.commit()
        print("Proceso completado exitosamente")

    except cx_Oracle.DatabaseError as e:
        print("Error de Oracle: {}".format(e))
        if 'con' in locals():
            con.rollback()
    except Exception as e:
        print("Error general: {}".format(e))
        if 'con' in locals():
            con.rollback()
    finally:
        if 'cur' in locals():
            cur.close()
        if 'con' in locals():
            con.close()
        print("Conexion cerrada")


if __name__ == "__main__":
    main()