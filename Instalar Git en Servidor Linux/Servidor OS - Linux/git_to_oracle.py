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
                        # MERGE para insertar solo si no existe commit_id + filename
                        cur.execute("""
                            MERGE INTO GIT_FILES t
                            USING (SELECT :1 AS commit_id, :2 AS filename, :3 AS status FROM dual) src
                            ON (t.commit_id = src.commit_id AND t.filename = src.filename)
                            WHEN NOT MATCHED THEN
                                INSERT (commit_id, status, filename)
                                VALUES (src.commit_id, src.status, src.filename)
                        """, (commit_id, filename, status))
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

    commit_re = re.compile(r'^---\s*([0-9a-fA-F]{7,40})$')
    diff_git_re = re.compile(r'^diff --git a/(.+?) b/(.+)$')

    commit_id = None
    current_file = None
    diff_lines = []

    for line_num, raw_line in enumerate(file_content, 1):
        try:
            line = raw_line.rstrip("\r\n")

            # 1) Nuevo commit
            m_commit = commit_re.match(line)
            if m_commit:
                # Guardar diff anterior si existe
                if commit_id and current_file and diff_lines:
                    diff_text = "".join(diff_lines)
                    try:
                        insert_diff(cur, commit_id, current_file, diff_text)
                        diff_count += 1
                    except Exception as e:
                        print("Error insertando diff (commit={}, file={}): {}".format(commit_id, current_file, e))

                # Iniciar nuevo commit
                commit_id = m_commit.group(1)
                current_file = None
                diff_lines = []
                continue

            # 2) Nuevo archivo (diff --git)
            m_diff = diff_git_re.match(line)
            if m_diff:
                # Guardar diff anterior antes de iniciar otro
                if commit_id and current_file and diff_lines:
                    diff_text = "".join(diff_lines)
                    try:
                        insert_diff(cur, commit_id, current_file, diff_text)
                        diff_count += 1
                    except Exception as e:
                        print("Error insertando diff (commit={}, file={}): {}".format(commit_id, current_file, e))

                a_file = m_diff.group(1).strip()
                b_file = m_diff.group(2).strip()
                chosen_file = b_file if b_file != '/dev/null' else a_file
                current_file = chosen_file
                diff_lines = [line + "\n"]
                continue

            # 3) Ajuste de filename con +++ b/...
            if line.startswith("+++ b/"):
                current_file = line[6:].strip()
                diff_lines.append(line + "\n")
                continue

            # 4) Si estamos dentro de un archivo, acumular lineas
            if current_file is not None:
                diff_lines.append(line + "\n")

        except Exception as e:
            print("Error procesando linea {}: {}".format(line_num, e))
            continue

    # Guardar el último diff
    if commit_id and current_file and diff_lines:
        try:
            diff_text = "".join(diff_lines)
            insert_diff(cur, commit_id, current_file, diff_text)
            diff_count += 1
        except Exception as e:
            print("Error insertando último diff (commit={}, file={}): {}".format(commit_id, current_file, e))

    print("Diffs procesados: {}".format(diff_count))

def insert_diff(cur, commit_id, current_file, diff_text):
    # Verificar si ya existe
    cur.execute("""
        SELECT 1 FROM GIT_DIFFS 
        WHERE commit_id = :commit_id AND filename = :filename
    """, {
        "commit_id": commit_id,
        "filename": current_file
    })
    exists = cur.fetchone()

    if not exists:
        # Forzar a que diff_text sea tratado como CLOB
        cur.setinputsizes(diff_text=cx_Oracle.CLOB)
        cur.execute("""
            INSERT INTO GIT_DIFFS (commit_id, filename, diff_text)
            VALUES (:commit_id, :filename, :diff_text)
        """, {
            "commit_id": commit_id,
            "filename": current_file,
            "diff_text": diff_text
        })


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