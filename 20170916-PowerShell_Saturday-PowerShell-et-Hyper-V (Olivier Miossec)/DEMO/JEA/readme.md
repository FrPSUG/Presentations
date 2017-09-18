**jea.config.ps1**

Ce sont les étapes de la configuration. 
Les dossiers et la creation du manifeste du module, du fichier psrc (Role Capabilities) et du fichier pssc (Session Configuration) peuvent être créér en remoting. 
Pour l'enregistrement de la configuration (Register-PSSessionConfiguration) il est nécessaire de l'effectuer sur la machine local (directement ou en DSC).
Si vous tenter de le faire en remoting, vous aurez une erreur mais la session sera tout de même enregistrée.
Dans ce cas il faut, sur la machine local, supprimer la configuration 

```powershell
Register-PSSessionConfiguration -name NomDeLaConf -force
```


**HyperOpsJea.psd1**
C'est le nom du module que l'on utilise. Il n'est pas nécessaire que ce module exite (pas de fichier .psm1)

**HyperOpsJea.psrc**
Role Capabilities. Configuration du rôle, ce que peut faire l'utilisateur. Dans l'ex. simplement get-vm, start-vm et stop-vm, plus Ping et Trace route. 
à noter qu'il est aussi possible de limiter un cmdlet en utilisant un hastable
```powershell
@{ Name = 'get-vm'; Parameters = @{ Name = 'name'; ValidateSet = 'VM1', 'VM2' }
```
L'utilisateur ne dispose alors que de la possibilité de faire 
```powershell
get-vm -name VM1 ou VM2
```


**HyperOpsJea.pssc**
Session Configuration. Il permet de dire comment et qui peut se connecter
```powershell
RoleDefinitions = @{ 'Nom User/Groupe' = @{ RoleCapabilities = 'HyperOpsJea' } } 
```
c'est un hastable, donc il est possible d'ajouter plusieurs groupe 
il est aussi possible d'ajouter plusieurs module dans RoleCapabilities

Il est important de passer SessionType à 'RestrictedRemoteServer' pour limiter l'action de l'utilisateur, 'default' permet d'avoir l'ensemble des cmdlets. 

```powershell
RunAsVirtualAccount = $true
```
Permet de faire en sorte que l'utilisateur soit un administrateur virtuel sur les cmdlets ouvert. 

TranscriptDirectory, permet d'avoir un log des commandes de l'utilisateur. 
Cela peut être sur un share (à condition que le compte de l'ordinateur dispose des droits nécessaire)



