#!/bin/bash
REPO_DIR="/backup/git_respaldo/repositorio_sql"
OUTPUT_DIR="/backup/git_respaldo/git_logs"

mkdir -p "$OUTPUT_DIR"
cd "$REPO_DIR" || exit 1

# Commits: ID | Autor | Fecha | Mensaje
git log --pretty=format:"%H|%an|%ad|%s" --date=iso > "$OUTPUT_DIR/commits.log"

# Archivos modificados por commit
git log --name-status --pretty=format:"---%H" > "$OUTPUT_DIR/files.log"

# Diffs completos por commit
git log --pretty=format:"---%H" --patch > "$OUTPUT_DIR/diffs.log"
