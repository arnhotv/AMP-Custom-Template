# DCS World Dedicated Server - AMP v1 (Windows)

Ce pack est un **premier draft privé** pour AMP.

## Ce que fait cette v1

- déclare une instance AMP Windows pour **lancer `bin\DCS_server.exe`** ;
- expose les ports AMP par défaut :
  - `10308/TCP`
  - `10308/UDP`
  - `8088/TCP`
- télécharge l'installateur modulaire officiel DCS dans `_manual_steps\` quand tu fais un **Update** dans AMP ;
- permet d'utiliser `-w <WriteDirName>` pour isoler le dossier `Saved Games` de l'instance.

## Ce que cette v1 ne fait pas encore

- elle **ne pilote pas automatiquement** `serverSettings.lua` ni `autoexec.cfg` depuis l'UI AMP ;
- elle **ne fait pas une installation silencieuse complète** du serveur DCS ;
- la console AMP restera basique, car DCS Dedicated est surtout piloté par son Web GUI.

## Arborescence attendue dans l'instance AMP

Le root de l'instance AMP doit contenir au final quelque chose comme :

```text
<instance-root>\
  bin\DCS_server.exe
  bin\DCS_updater.exe
  _manual_steps\DCS_World_Server_modular.exe
```

## Utilisation recommandée

### Option A - depuis AMP

1. Crée l'instance avec `dcs-world-server.kvp`.
2. Lance **Update** dans AMP.
3. AMP télécharge `DCS_World_Server_modular.exe` dans `_manual_steps\`.
4. Exécute manuellement cet installateur.
5. **Choisis le root de l'instance AMP comme dossier d'installation**.
6. Vérifie que `bin\DCS_server.exe` est bien présent.
7. Démarre l'instance AMP.

### Option B - avec le script PowerShell

Utilise `Install-DcsServerForAmp.ps1`.

Exemple pour télécharger puis lancer l'installateur officiel :

```powershell
.\Install-DcsServerForAmp.ps1 -AmpInstanceRoot 'C:\AMPDatastore\Instances\dcs-world-server' -DownloadInstaller -RunInstaller
```

Exemple pour mettre à jour une installation existante :

```powershell
.\Install-DcsServerForAmp.ps1 -AmpInstanceRoot 'C:\AMPDatastore\Instances\dcs-world-server' -UpdateExisting
```

## Dossier Saved Games

Par défaut, le template lance DCS avec :

```text
-w DCS.server
```

Donc DCS utilisera normalement :

```text
Saved Games\DCS.server\
```

Tu peux changer ça dans le champ AMP **Saved Games write directory name**.

## Configuration DCS

Pour cette v1, fais la config DCS ici :

- `Saved Games\<WriteDirName>\Config\serverSettings.lua`
- `Saved Games\<WriteDirName>\Config\autoexec.cfg`

Des exemples sont fournis :

- `serverSettings.lua.example`
- `autoexec.cfg.example`

## Idée pour la v2

La prochaine étape logique serait :

- ajouter un `metaconfig.json` ;
- générer automatiquement `serverSettings.lua` et `autoexec.cfg` ;
- mieux gérer l'état Ready / Stopped ;
- éventuellement tailer `dcs.log` si le chemin Saved Games est figé.
