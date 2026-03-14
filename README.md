# DCS World Dedicated Server - AMP v2 (Linux + Wine draft)

Ce pack remplace la v1 Windows-only par une **v2 compatible Linux AMP via Wine**.
Il garde aussi le lancement natif Windows si un jour tu utilises un target Windows.

## Ce que fait cette v2

- rend le template visible sur **AMP Linux** (`Meta.OS=Windows, Linux`) ;
- recommande l'image Docker AMP **`cubecoders/ampbase:wine-stable`** pour éviter d'installer Wine/Xvfb directement sur l'hôte ;
- lance DCS sur Linux via **`xvfb-run -a wine "./bin/DCS_server.exe"`** ;
- génère deux fichiers de config AMP dans :
  - `_amp_generated/autoexec.cfg`
  - `_amp_generated/serverSettings.lua`
- fournit un script bash pour :
  - télécharger l'installateur officiel,
  - appliquer les configs générées dans le bon `Saved Games`,
  - lancer une mise à jour silencieuse via `DCS_updater.exe --quiet update`.

## Ce que cette v2 ne fait pas encore

- **l'installation initiale n'est pas encore complètement automatique** ;
- elle ne détecte pas encore proprement l'état **Ready** à partir d'un vrai log DCS ;
- la console AMP reste limitée, parce que DCS Dedicated est surtout pensé autour du **Web GUI**.

## Fichiers AMP principaux

Ce sont les fichiers que ton repo GitHub doit contenir à la racine :

- `dcs-world-server.kvp`
- `dcs-world-serverconfig.json`
- `dcs-world-servermetaconfig.json`
- `dcs-world-serverports.json`
- `dcs-world-serverupdates.manual.json`

Les autres fichiers sont des helpers/templates utiles pour ton repo privé :

- `dcs-world-serverautoexec.cfg`
- `dcs-world-serversettings.lua`
- `install-dcs-server-for-amp.sh`

## Procédure recommandée

### 1) Remplace les anciens fichiers du repo

Dans ton repo GitHub, remplace la v1 par cette v2.

### 2) Côté AMP

- garde ton repo custom dans AMP ;
- fais **Fetch Latest** ;
- redémarre l'instance **ADS / Application Deployment** ;
- crée une nouvelle instance DCS à partir du template.

### 3) Update AMP

L'action **Update** crée seulement :

- le root de l'instance,
- `_manual_steps/`,
- `_amp_generated/`.

### 4) Télécharge l'installateur officiel

Depuis le root de l'instance :

```bash
chmod +x install-dcs-server-for-amp.sh
./install-dcs-server-for-amp.sh download-installer
```

### 5) Installation initiale DCS

L'install initial reste manuel. Il faut exécuter l'installateur officiel sous Wine et **installer DCS directement dans le root de l'instance AMP**.

### 6) Génère puis applique les configs AMP

Sauvegarde les champs dans l'UI AMP, puis copie les fichiers générés vers le vrai `Saved Games` du préfixe Wine :

```bash
./install-dcs-server-for-amp.sh apply-config DCS.server
```

### 7) Démarrage

Démarre l'instance AMP.

Au premier démarrage, DCS doit créer son write-dir sous le préfixe Wine. Si `apply-config` te dit qu'il ne trouve pas `Saved Games/DCS.server`, démarre DCS une fois, arrête-le, puis relance `apply-config`.

## Points d'attention

- si tu changes les ports dans AMP, garde les mêmes valeurs dans les configs DCS ;
- sur Linux, ce mode reste **non officiel / best effort** car Eagle Dynamics publie officiellement le dedicated server pour **Windows** ;
- pour un usage perso/home-lab, ce draft est cohérent, mais pour un PR upstream CubeCoders il faudra probablement encore durcir le comportement `Ready/Stopped`.

## Commit conseillé

```text
DCS AMP template v2: add Linux/Wine support and generated config helpers
```
