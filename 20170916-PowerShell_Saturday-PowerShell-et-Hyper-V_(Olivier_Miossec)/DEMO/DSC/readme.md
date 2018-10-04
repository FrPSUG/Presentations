**baddsc.ps1**

Montre que l'on ne peux pas avoir deux ressources du même nom dans une configuration.


**basic.dsc.ps1**

Simple configuration DSC

**simpledata.psd1**

c'est le Hashtable contenant les données de configuration.
Le Hastable doit toujours contenir le mot clé AllNodes.
La valeur de AllNodes doit être un tableau (array) de hastable.
Chaque Hastable doit contenir le mot clé NodeName (le noeud où la Configuration doit agir)

tout autre source de données peut être utiliser par exemple JSON 

**simple.data.json**
C'est les mêmes données au format JSON 
C'est un simple convertto-json 
```powershell
    [hashtable] (invoke-expression (get-content "simple.data.psd1" | out-string)) | ConvertTo-Json -Depth 6 
```
A noter le paramêtre -depth et la valeur 6 
sans cela, certain noeud de données auront pour valeur "System.Collections.Hashtable" 
pour avoir notre Hastable il faut utiliser: 
```powershell
    $JSONData | ConvertFrom-Json
```


**simple.dcs.ps1**
C'est le script de configuration dynamique; les noms des ressoures sont gérés par les données de configuration 
Attention lors d'une configuration DSC, le fichier MOF généré (Le script de configuration ne sert qu'à générer un fichier MOF) peut avoir une certaine taille et WinRm peut générer une erreur.
Il est nécessaire d'augmenter le MaxEnvelopeSizekb 
```powershell
Set-Item WSMan:\localhost\MaxEnvelopeSizekb -Value 5000
```

Pour lancer la démo, il est nécessaire de disposer du module xHyper-V et d'au moins un serveur Hyper-V (cela peut être la machine local)

```powershell
.\simple.dcs.ps1 -vmdatafile simple.data.psd1
```