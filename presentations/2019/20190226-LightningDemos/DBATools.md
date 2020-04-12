# DbaTools

Presentateur: Olivier Miossec [Blog](https://omiossec.github.io/) | [Twitter](https://twitter.com/omiossec_med) |  [Linkedin](https://www.linkedin.com/in/omiossec/) 


[![Youtube Video](http://img.youtube.com/vi/3OR143IPQ4o/0.jpg)](http://www.youtube.com/watch?v=3OR143IPQ4o)




Dbatools est un Module communautaire et Open Source qui permet d’automatiser plusieurs centaines de taches d’administration sur MS Sql Server. 

Le module intègre l’ensemble des outils et des binaires pour interagir avec MS Sql Server en local ou à distance. 

Il dispose de plusieurs centaines de [commandes](https://dbatools.io/commands/) 

Les sources sont disponibles  [https://github.com/sqlcollaborative/dbatools](https://github.com/sqlcollaborative/dbatools)

A l’origine du projet :  [Chrissy LeMaire](https://twitter.com/cl)


## Demo

### Installer Dbatools
```powershell
install-module -name dbatools
```

### Gérer la configuration mémoire de Sql Server
```powershell
Test-DbaMaxMemory -SqlInstance psdemo01
```

### Ajouter deux bases de données 
```powershell
New-DbaDatabase -SqlInstance psdemo01 -Name demo01, demo02 
```

### Ajouter une base de données avec un nom Random 
```powershell
New-DbaDatabase -SqlInstance psdemo01 
```

### Lister les bases de données 
```powershell
get-dbadatabase -SqlInstance psdemo01 | select-object name
```

### Extraire les informations sur les chemins de bases de données et de backup par défaut
```powershell
$DefaultPath = Get-DbaDefaultPath -SqlInstance psdemo01
$DefaultPath.data
$DefaultPath.Backup
```

### Vérifier l'utilisation des tampons mémoire des bases de données utilisateurs
```powershell
Get-DbaDbMemoryUsage -SqlInstance psdemo01 -IncludeSystemDb -Exclude 'master','model','msdb','ResourceDb'
```

### Effectuer un Backup en créer les dossiers de destination 
```powershell
Backup-DbaDatabase -SqlInstance psdemo01 -BackupDirectory 'd:\temp' -Database 'demo01','demo02' -Type Full -createfolder
```

### Fixer la valeur de MaxMemory suivant les bonnes pratiques 
```powershell
Set-DbaMaxMemory psdemo01
```