module.exports = {
  // Prowlarr torznab — récupérer les URLs dans Prowlarr :
  // Settings > Indexers > (ton indexeur) > Copy Torznab Feed
  // Remplacer YOUR_PROWLARR_API_KEY par ta clé API Prowlarr
  // (Settings > General > API Key)
  torznab: [
    "http://prowlarr:9696/13/api?apikey=YOUR_PROWLARR_API_KEY",
    "http://prowlarr:9696/15/api?apikey=YOUR_PROWLARR_API_KEY"
  ],

  // Dossier contenant les .torrent de qBittorrent (BT_backup)
  // Correspond au volume monté dans docker-compose.yml
  torrentDir: "/torrents",

  // outputDir null = injection directe via API (pas de dossier watch)
  outputDir: null,

  // Dossiers média à analyser pour le matching par données
  dataDirs: ["/media/series", "/media/movies", "/media/downloads"],

  // Injection directe dans qBittorrent
  // Format : "qbittorrent:http://USER:PASS@HOST:PORT"
  // Encoder les caractères spéciaux du mot de passe en URL encode
  action: "inject",
  torrentClients: ["qbittorrent:http://YOUR_QB_USER:YOUR_QB_PASS@gluetun:8080"],

  // Mode safe = uniquement les matchs 100% certains (même hash)
  matchMode: "safe",

  // Ne pas re-vérifier les fichiers après injection
  skipRecheck: true,

  // Catégorise les torrents cross-seedés séparément dans qBittorrent
  duplicateCategories: true,

  // Port API cross-seed
  port: 2468,

  // Délai entre les recherches (secondes)
  delay: 30,

  // Recherche automatique toutes les 24h
  searchCadence: "1d",

  // excludeRecentSearch doit être >= 3x searchCadence
  excludeRecentSearch: "3d",

  // excludeOlder doit être 2-5x excludeRecentSearch
  excludeOlder: "9d",
};
