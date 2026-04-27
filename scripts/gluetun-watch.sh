#!/bin/bash
# =============================================================
# gluetun-watch.sh — Surveillance et auto-restart du tunnel WireGuard
# À appeler via cron toutes les 5 minutes :
#   */5 * * * * /opt/docker/scripts/gluetun-watch.sh
# =============================================================

LOG=/var/log/gluetun-watch.log
WG_VPS="10.100.0.1"   # IP du VPS dans le réseau WireGuard (adapter si besoin)

# Vérifier si le container gluetun tourne
if ! docker ps | grep -q gluetun; then
  echo "$(date): gluetun DOWN → démarrage..." >> $LOG
  docker start gluetun
  exit 0
fi

# Test de ping avec mécanisme de retry
# Tentative 1
if docker exec gluetun ping -c 3 -W 2 $WG_VPS > /dev/null 2>&1; then
  echo "$(date): WireGuard tunnel OK (tentative 1) ✓" >> $LOG
else
  # Attente puis 2ème tentative
  echo "$(date): WireGuard tunnel KO (tentative 1) — retry dans 10s..." >> $LOG
  sleep 10
  if docker exec gluetun ping -c 5 -W 2 $WG_VPS > /dev/null 2>&1; then
    echo "$(date): WireGuard tunnel OK (tentative 2) ✓" >> $LOG
  else
    # 2 échecs consécutifs → restart
    echo "$(date): WireGuard tunnel KO (tentative 2) → restart gluetun + qbittorrent" >> $LOG
    docker restart gluetun qbittorrent
  fi
fi
