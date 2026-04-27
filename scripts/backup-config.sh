#!/bin/bash
# =============================================================
# backup-config.sh — Sauvegarde de la config Docker
# Crée une archive tar.gz contenant :
#   - docker-compose.yml
#   - scripts/
#   - README, .gitignore
# ⚠️  Le .env (secrets) est INCLUS dans la sauvegarde locale
#     mais ne doit JAMAIS être poussé sur Git.
# =============================================================

BACKUP_DIR="/opt/docker/.git-backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/server_config_$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

# Garder seulement les 5 dernières sauvegardes
ls -dt "$BACKUP_DIR"/server_config_*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm

cd /opt/docker
tar -czf "$BACKUP_FILE" \
    .env \
    docker-compose.yml \
    scripts \
    README.md \
    .gitignore \
    .git

echo "✅ Backup créé : $BACKUP_FILE"
echo "💡 Télécharger localement : scp user@server:$BACKUP_FILE ."
