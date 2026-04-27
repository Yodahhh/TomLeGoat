# 🏠 Homelab Docker Stack

> Stack Docker complète pour homelab personnel — Jellyfin, stack ARR, VPN WireGuard, reverse proxy Traefik, domotique et plus encore.

## 📐 Architecture

```
Internet
   │
   ▼
[Box Internet / Freebox]
   │ Redirection port UDP 51820 → Serveur
   │
   └──▶ [Serveur Linux maison]
            ├── Traefik (reverse proxy HTTPS, wildcard *.votredomaine.fr)
            ├── Gluetun (VPN WireGuard → VPS auto-hébergé)
            │     ├── qBittorrent  (réseau: service:gluetun)
            │     └── ygege-vpn    (réseau: service:gluetun)
            └── /mnt/media (mergerfs — stockage agrégé)
```

### Réseau Docker

| Réseau | Driver | Usage |
|---|---|---|
| `traefik_network` | bridge | Réseau principal — tous les services web |
| `host` | host | HomeAssistant, AdGuard (accès réseau local direct) |
| `service:gluetun` | network_mode | qBittorrent, ygege-vpn (trafic via VPN) |

---

## 🐳 Services

### 🎬 Média & Streaming
| Service | Image | Port interne | Description |
|---|---|---|---|
| **Jellyfin** | `linuxserver/jellyfin` | 8096 | Serveur média open-source |
| **Jellyseerr** | `fallenbagel/jellyseerr` | 5055 | Interface de demandes films/séries |
| **jfa-go** | `hrfee/jfa-go` | 8056 | Gestion des invitations Jellyfin |

### 📥 Stack ARR (automatisation)
| Service | Image | Port interne | Description |
|---|---|---|---|
| **Sonarr** | `linuxserver/sonarr` | 8989 | Gestion séries TV |
| **Radarr** | `linuxserver/radarr` | 7878 | Gestion films |
| **Prowlarr** | `linuxserver/prowlarr` | 9696 | Gestionnaire d'indexeurs torrents |
| **Bazarr** | `linuxserver/bazarr` | 6767 | Sous-titres automatiques |
| **Bookshelf** | `pennydreadful/bookshelf:softcover` | 8787 | Gestion de livres |
| **Recyclarr** | `recyclarr/recyclarr` | — | Sync TRaSH Guides → Sonarr/Radarr (cron @daily) |

### ⚡ Automatisation avancée
| Service | Image | Port interne | Description |
|---|---|---|---|
| **autobrr** | `autobrr/autobrr` | 7474 | Saisie automatique nouvelles sorties |
| **cross-seed** | `cross-seed/cross-seed` | 2468 | Seeding croisé du contenu existant |
| **FlareSolverr** | `flaresolverr/flaresolverr` | 8191 | Bypass Cloudflare pour Prowlarr |

### 🔒 Réseau & Infrastructure
| Service | Image | Port interne | Description |
|---|---|---|---|
| **Traefik** | `traefik:v3.6` | 80/443 | Reverse proxy HTTPS, certificats Let's Encrypt |
| **Gluetun** | `qmcgaw/gluetun` | — | Client VPN WireGuard (gateway réseau) |
| **qBittorrent** | `linuxserver/qbittorrent` | 8080 | Client torrent (réseau via Gluetun) |
| **AdGuard Home** | `adguard/adguardhome` | 3000 | DNS & bloqueur de publicités |
| **Watchtower** | `containrrr/watchtower` | — | Mises à jour automatiques des containers |

### 🏠 Domotique & Outils
| Service | Image | Port interne | Description |
|---|---|---|---|
| **Home Assistant** | `linuxserver/homeassistant` | 8123 | Domotique (mode host pour mDNS/Bluetooth) |
| **Homepage** | `gethomepage/homepage` | 3000 | Dashboard central |

### 🗂️ Indexeurs YGGTorrent (double compte)
| Instance | Réseau sortant | Description |
|---|---|---|
| **ygege** | IP box internet | Compte YGG lié à l'IP de la box |
| **ygege-vpn** | IP VPS (via Gluetun) | Compte YGG lié à l'IP du VPS |

> **Pourquoi deux comptes ?** YGGTorrent lie les comptes à des IPs. Deux instances offrent de la redondance si l'IP de la box change.

---

## 🔗 Chaîne de téléchargement complète

```
Utilisateur (Jellyseerr)
    ↓ Demande film/série
Sonarr / Radarr
    ↓ Cherche releases
Prowlarr
    ├── ygege (IP box)        → YGGTorrent
    ├── ygege-vpn (IP VPS)    → YGGTorrent (compte 2)
    └── FlareSolverr (bypass Cloudflare)
         ↓ Résultat
qBittorrent (réseau Gluetun → IP VPS pour le P2P)
    ↓ Télécharge dans /mnt/media/downloads
Sonarr/Radarr (import automatique + hardlinks)
    ↓ Déplace vers /media/series ou /media/movies
Jellyfin ← Bazarr ajoute les sous-titres automatiquement
    ↓ Stream vers les utilisateurs
```

---

## 🚀 Installation

### Prérequis

- Serveur Linux (Ubuntu/Debian recommandé)
- Docker + Docker Compose installés
- Un nom de domaine avec accès DNS
- (Optionnel) Un VPS pour le tunnel WireGuard

### 1. Cloner le repo

```bash
git clone https://github.com/votre-user/docker-homelab /opt/docker
cd /opt/docker
```

### 2. Préparer l'environnement

```bash
cp .env.example .env
nano .env   # Remplir toutes les variables
```

### 3. Préparer Traefik

```bash
# Créer le fichier acme.json avec les bonnes permissions (obligatoire)
touch traefik/acme.json
chmod 600 traefik/acme.json

# Adapter votre domaine dans traefik/traefik.yml
nano traefik/traefik.yml
```

### 4. Remplacer `votredomaine.fr`

Dans `docker-compose.yml`, remplacer toutes les occurrences de `votredomaine.fr` par votre domaine :

```bash
sed -i 's/votredomaine.fr/mondomaine.com/g' docker-compose.yml
```

### 5. Lancer la stack

```bash
sudo docker compose up -d

# Vérifier l'état
sudo docker compose ps
```

---

## 🌐 URLs (avec votre domaine)

| Service | URL |
|---|---|
| Homepage (dashboard) | `https://home.votredomaine.fr` |
| Jellyfin | `https://jellyfin.votredomaine.fr` |
| Jellyseerr | `https://requests.votredomaine.fr` |
| Sonarr | `https://sonarr.votredomaine.fr` |
| Radarr | `https://radarr.votredomaine.fr` |
| Prowlarr | `https://prowlarr.votredomaine.fr` |
| Bazarr | `https://bazarr.votredomaine.fr` |
| qBittorrent | `https://qbittorrent.votredomaine.fr` |
| Traefik Dashboard | `https://traefik.votredomaine.fr` |
| Home Assistant | `https://assistant.votredomaine.fr` |
| AdGuard Home | `https://adguard.votredomaine.fr` |
| autobrr | `https://autobrr.votredomaine.fr` |
| cross-seed | `https://xseed.votredomaine.fr` |
| Bookshelf | `https://lazy.votredomaine.fr` |
| jfa-go (invitations) | `https://invite.votredomaine.fr` |

---

## 📦 Structure des dossiers

```
/opt/docker/
├── docker-compose.yml          # Fichier principal de la stack
├── .env                        # Secrets (ignoré par Git !)
├── .env.example                # Template de variables
├── .gitignore
├── traefik/
│   ├── traefik.yml             # Config statique Traefik
│   ├── config.yml              # Config dynamique (middlewares)
│   └── acme.json               # Certificats TLS (chmod 600 requis)
└── [service]/                  # Dossier de config par service
    └── ...
```

### Stockage média

```
/mnt/media/
├── movies/       → Radarr + Jellyfin
├── series/       → Sonarr + Jellyfin
├── books/        → Bookshelf
└── downloads/    → qBittorrent
    ├── incomplete/
    └── watch/    → Dossier de surveillance cross-seed
```

> ⚠️ **Important** : `downloads/` et `movies/`/`series/` doivent être sur le **même système de fichiers** pour que les hardlinks fonctionnent (économie d'espace disque).

---

## 🔒 VPN — Gluetun WireGuard

Gluetun agit comme une gateway réseau pour qBittorrent et ygege-vpn. Tout leur trafic sort par l'IP du VPS.

```yaml
# Dans .env
WIREGUARD_ENDPOINT_IP=your_vps_ip
WIREGUARD_ENDPOINT_PORT=51820
WIREGUARD_PRIVATE_KEY=...   # wg genkey
WIREGUARD_PUBLIC_KEY=...    # Clé publique du serveur VPS
WIREGUARD_ADDRESSES=10.100.0.2/24
```

### Vérifier que le VPN fonctionne

```bash
# L'IP retournée doit être celle de ton VPS
docker exec gluetun curl ifconfig.me

# Redémarrer si nécessaire
docker compose restart gluetun qbittorrent
```

---

## 🔄 Watchtower — Mises à jour automatiques

Watchtower vérifie toutes les **48h** et met à jour uniquement les containers avec le label :
```yaml
labels:
  - "com.centurylinklabs.watchtower.enable=true"
```

> Traefik, Gluetun et qBittorrent sont **exclus** des mises à jour auto (versions fixées pour stabilité).

---

## 🏠 HomeAssistant & AdGuard — Mode Host

Ces deux services utilisent `network_mode: host` car ils ont besoin d'accéder directement au réseau local (mDNS, Bluetooth, port 53).

Pour que Traefik puisse leur router des requêtes, on utilise l'IP de la gateway Docker (`172.18.0.1`) :

```yaml
labels:
  - "traefik.http.services.homeassistant.loadbalancer.server.url=http://172.18.0.1:8123"
```

> Adapter l'IP de la gateway si votre réseau Docker est différent (`docker network inspect traefik_network | grep Gateway`).

---

## 🧰 Commandes utiles

```bash
# État de tous les containers
sudo docker compose ps -a

# Logs d'un service
docker compose logs -f sonarr

# Redémarrer un service
docker compose restart radarr

# Mettre à jour un service manuellement
docker compose pull jellyfin && docker compose up -d jellyfin

# Nettoyage Docker (images orphelines)
docker system prune -f

# Espace disque
df -h /mnt/media
docker system df
```

---

## ⚠️ Sécurité

- ✅ **Ne jamais committer `.env`** (déjà dans `.gitignore`)
- ✅ **`traefik/acme.json` doit être en `chmod 600`**
- ✅ Changer les mots de passe par défaut de qBittorrent dès l'installation
- ✅ Ne pas exposer FlareSolverr (port 8191) sur internet
- ✅ Utiliser des mots de passe forts (20+ caractères)

---

## 📚 Ressources

- [TRaSH Guides](https://trash-guides.info/) — Profils qualité optimaux pour Sonarr/Radarr
- [Servarr Wiki](https://wiki.servarr.com/) — Documentation officielle ARR
- [Gluetun Wiki](https://github.com/qdm12/gluetun-wiki) — Configuration VPN avancée
- [Traefik Docs](https://doc.traefik.io/traefik/) — Documentation Traefik
- [Jellyfin Docs](https://jellyfin.org/docs/) — Documentation Jellyfin

---

## 📝 Licence

MIT — libre d'utilisation et d'adaptation.
