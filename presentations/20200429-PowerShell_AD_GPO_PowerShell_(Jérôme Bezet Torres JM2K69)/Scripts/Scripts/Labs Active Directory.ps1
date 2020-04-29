Import-Module PSWriteWord #-Force
function New-Password
{

   $Alphabets = 'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z'
    $numbers = 0..9
    $specialCharacters = '~,!,@,#,$,%,^,&,*,(,),>,<,?,\,/,_,-,=,+'
    $array = @()
    $array += $Alphabets.Split(',') | Get-Random -Count 4
    $array[0] = $array[0].ToUpper()
    $array[-1] = $array[-1].ToUpper()
    $array += $numbers | Get-Random -Count 3
    $array += $specialCharacters.Split(',') | Get-Random -Count 3
    ($array | Get-Random -Count $array.Count) -join ""
}

function New-RandomUser {
    <#
        .SYNOPSIS
            Generate random user data from Https://randomuser.me/.
        .DESCRIPTION
            This function uses the free API for generating random user data from https://randomuser.me/
        .EXAMPLE
            Get-RandomUser 10
        .EXAMPLE
            Get-RandomUser -Amount 25 -Nationality us,gb 
        .LINK
            https://randomuser.me/
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(1,500)]
        [int] $Amount,

        [Parameter()]
        [ValidateSet('Male','Female')]
        [string] $Gender,

        # Supported nationalities: AU, BR, CA, CH, DE, DK, ES, FI, FR, GB, IE, IR, NL, NZ, TR, US
        [Parameter()]
        [string[]] $Nationality,


        [Parameter()]
        [ValidateSet('json','csv','xml')]
        [string] $Format = 'json',

        # Fields to include in the results.
        # Supported values: gender, name, location, email, login, registered, dob, phone, cell, id, picture, nat
        [Parameter()]
        [string[]] $IncludeFields,

        # Fields to exclude from the the results.
        # Supported values: gender, name, location, email, login, registered, dob, phone, cell, id, picture, nat
        [Parameter()]
        [string[]] $ExcludeFields
    )

    $rootUrl = "http://api.randomuser.me/?format=$($Format)"

    if ($Amount) {
        $rootUrl += "&results=$($Amount)"
    }

    if ($Gender) {
        $rootUrl += "&gender=$($Gender)"
    }


    if ($Nationality) {
        $rootUrl += "&nat=$($Nationality -join ',')"
    }

    if ($IncludeFields) {
        $rootUrl += "&inc=$($IncludeFields -join ',')"
    }

    if ($ExcludeFields) {
        $rootUrl += "&exc=$($ExcludeFields -join ',')"
    }
    
    Invoke-RestMethod -Uri $rootUrl
}

#region declarations des variables
# Recuperations des informations du domaine AD
$fqdn = Get-ADDomain
$fulldomain = $fqdn.DNSRoot
$domain = $fulldomain.split(".")
$Dom = $domain[0]
$Ext = $domain[1]


# Informations des Sites et Services
$Sites = ("Lyon","New-York","London")
$Services = ("Production","Marketing","IT","Direction","Helpdesk")
$Materiel = ("Computer","Server","Printers")
$FirstOU ="Sites"

#endregions
$sw = [Diagnostics.Stopwatch]::StartNew()

New-ADOrganizationalUnit -Name $FirstOU -Description $FirstOU  -Path "DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false


foreach  ($S in $Sites)
{
        New-ADOrganizationalUnit -Name $S -Description "$S"  -Path "OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
 
     foreach ($Serv in $Services)
     {

        New-ADOrganizationalUnit -Name $Serv -Description "$S $Serv"  -Path "OU=$S,OU=$FirstOU,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
      
      switch ($S)
      {
         'Lyon' {      
                        $Employees = New-RandomUser -Amount 20 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results
                        $Directors = New-RandomUser -Amount 5 -Nationality fr -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results
                       Write-Host "Creation des utilisateurs du service $Serv pout le site de $S " -ForegroundColor Magenta
                 }
          'New-York' {
                        $Employees = New-RandomUser -Amount 20 -Nationality us -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results
                        $Directors = New-RandomUser -Amount 5 -Nationality us -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results
                        Write-Host "Creation des utilisateurs du service $Serv pout le site de $S " -ForegroundColor Magenta

                     }
          'London' {
                        $Employees = New-RandomUser -Amount 20 -Nationality gb -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results
                        $Directors = New-RandomUser -Amount 7 -Nationality gb -IncludeFields name,dob,phone,cell -ExcludeFields picture | Select-Object -ExpandProperty results
                        Write-Host "Creation des utilisateurs du service $Serv pout le site de $S " -ForegroundColor Magenta
          }
          Default {}
      }

        foreach ($user in $Employees) 
        {
            #New Password
            $userPassword = New-Password

            $newUserProperties = @{
            Name = "$($user.name.first) $($user.name.last)"
            City = "$S"
            GivenName = $user.name.first
            Surname = $user.name.last
            Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
            title = "Employees"
            department="$Serv"
            OfficePhone = $user.phone
            MobilePhone = $user.cell
            Company="$Dom"
            EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
            AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
            SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
            UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
            Enabled = $true
        }   
    
           if(!(Test-Path -Path "e:\$S\$Serv\Employés"))
           {
            New-Item -Path "e:\$S\$Serv\Employés" -ItemType Directory | Out-Null
           }
           else
           {
               #"The directory exist" 
           }


        $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

        $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
               
        $FilePathInvoice  = "e:\$S\$Serv\Employés\$($user.name.last) $($user.name.first).docx"
        Add-WordText -WordDocument $WordDocument -Text 'Création de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


        Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
        -FontSize 12, 13 `
        -Color  Black, Blue `
        -Bold  $false, $true `
        -SpacingBefore 15 `
        -Supress $True
        
        Add-WordText -WordDocument $WordDocument -Text 'Login : ', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
        -FontSize 12, 10 `
        -Color  Black, Blue `
        -Bold  $false, $true `
        -Supress $True

        Add-WordText -WordDocument $WordDocument -Text 'Mot de passe : ',"$userPassword" `
        -FontSize 12, 10 `
        -Color  Black, Blue `
        -Bold  $false, $true `
        -Supress $True
        Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie : ',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
        -FontSize 12, 10 `
        -Color  Black, Blue `
        -Bold  $false, $true `
        -SpacingAfter 15 `
        -Supress $True

        Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
        -FontSize 12 `
        -Supress $True

        Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'



           Try
            { New-ADUser @newUserProperties }   
           catch{}
    
        }

        foreach ($user in $Directors) 
        {
            #New Password
            $userPassword = New-Password


          $newUserProperties = @{
        Name = "$($user.name.first) $($user.name.last)"
        City = "$S"
        GivenName = $user.name.first
        Surname = $user.name.last
        Path = "OU=$Serv,OU=$S,OU=$FirstOU,dc=$Dom,dc=$EXT"
        title = "Directors"
        department="$Serv"
        OfficePhone = $user.phone
        MobilePhone = $user.cell
        Company="$Dom"
        EmailAddress="$($user.name.first).$($user.name.last)@$($fulldomain)"
        AccountPassword = (ConvertTo-SecureString $userPassword -AsPlainText -Force)
        SamAccountName = $($user.name.first).Substring(0,1)+$($user.name.last)
        UserPrincipalName = "$(($user.name.first).Substring(0,1)+$($user.name.last))@$($fulldomain)"
        Enabled = $true
    }

          if(!(Test-Path -Path "e:\$S\$Serv\Responsables"))
           {
            New-Item -Path "e:\$S\$Serv\Responsables" -ItemType Directory | Out-Null
           }
           else
           {
               #"The directory exist" 
           }

        $FilePathTemplate = "C:\Users\Administrator\Desktop\Template.docx"

        $WordDocument = Get-WordDocument -FilePath $FilePathTemplate
        $FilePathInvoice  = "e:\$S\$Serv\Responsables\$($user.name.last) $($user.name.first).docx"
        Add-WordText -WordDocument $WordDocument -Text 'Création de Compte' -FontSize 15 -HeadingType  Heading1 -FontFamily 'Arial' -Italic $true | Out-Null


        Add-WordText -WordDocument $WordDocument -Text 'Voici les informations qui vous permettrons de vous connecter au Domaine Active Directory', " $fulldomain" `
        -FontSize 12, 13 `
        -Color  Black, Blue `
        -Bold  $false, $true `
        -SpacingBefore 15 `
        -Supress $True
        
        Add-WordText -WordDocument $WordDocument -Text 'Login :', "$(($user.name.first).Substring(0,1)+$($user.name.last))" `
        -FontSize 12, 10 `
        -Color  Black, Blue `
        -Bold  $false, $true `
        -Supress $True

        Add-WordText -WordDocument $WordDocument -Text 'Mot de passe :',"$userPassword" `
        -FontSize 12, 10 `
        -Color  Black, Blue `
        -Bold  $false, $true `
        -Supress $True

        Add-WordText -WordDocument $WordDocument -Text 'Adresse de messagerie :',"$($user.name.first).$($user.name.last)@$($fulldomain)" `
        -FontSize 12, 10 `
        -Color  Black, Blue `
        -Bold  $false, $true `
        -SpacingAfter 15 `
        -Supress $True

        Add-WordText -WordDocument $WordDocument -Text "Le Service Informatique." `
        -FontSize 12 `
        -Supress $True

        Save-WordDocument -WordDocument $WordDocument -FilePath $FilePathInvoice -Supress $true  -Language 'fr-FR'
    
           Try{ New-ADUser @newUserProperties}
           catch{}
    
        }

     }
 
 }

 Write-Host "Creations des OU pour les groupes" -ForegroundColor Magenta
 Write-Host ""

 New-ADOrganizationalUnit -Name Groupes -Description "Groupes du Domaine"  -Path "OU=Sites,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
 New-ADOrganizationalUnit -Name Globaux -Description "Groupes Globaux"  -Path "OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
 New-ADOrganizationalUnit -Name "Domaines Locaux" -Description "Groupes de Domaines Locaux"  -Path "OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false

  Write-Host "Creations des groupes Globaux et Groupes de Domaines Locaux" -ForegroundColor Magenta
  Write-Host ""
   
 
 foreach ($item in $Services)
 {
  
   $i=$item.Replace(" ","_")
  Write-Host "Creation des groupes Globaux G_$I , G_Employes_$I et G_Responsable_$I le service $i" -ForegroundColor Magenta
  Write-Host ""
  New-ADGroup -Name "G_$i" -DisplayName "G_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global $i"
  New-ADGroup -Name "G_Employes_$i" -DisplayName "G_Employes_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global Employes $i"
  New-ADGroup -Name "G_Responsables_$i" -DisplayName "G_Responsables_$i" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Global Responsables $i"
  
   Write-Host "Creation des groupes de Domaine Locaux DL_$i`_L , DL_$i`_LM DL_$i`_CT pour le service $i" -ForegroundColor Magenta
  Write-Host ""
  New-ADGroup -Name  "DL_$i`_L" -DisplayName  "DL_$i`_L" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture"
  New-ADGroup -Name  "DL_$i`_LM" -DisplayName  "DL_$i`_LM" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture et Modification"
  New-ADGroup -Name  "DL_$i`_CT" -DisplayName  "DL_$i`_CT" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Domaine Locaux $i Controle Totale"
    

 }
 New-ADGroup -Name "G_Responsables" -DisplayName "G_Responsables" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Responsable"
 New-ADGroup -Name "G_Employes" -DisplayName "G_Employes" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Employes"

 Write-Host "Creation des groupes de Domaine Locaux DL_Accès Commun_L , DL_Accès Commun_LM DL_Accès Commun_CT " -ForegroundColor Magenta
  Write-Host ""
  New-ADGroup -Name  "DL_Acces_Commun_L" -DisplayName  "DL_Acces_Commun_L" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture"
  New-ADGroup -Name  "DL_Acces_Commun_LM" -DisplayName  "DL_Acces_Commun_LM" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT"  -Description "Groupe Domaine Locaux $i Lecture et Modification"
  New-ADGroup -Name  "DL_Acces_Commun_CT" -DisplayName  "DL_Acces_Commun_CT" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Domaine Locaux $i Controle Totale"

   Write-Host ""
   Write-Host "Creations des OU pour le materiel" -ForegroundColor Green

 New-ADOrganizationalUnit -Name Materiels -Description Materiels  -Path "OU=Sites,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
 
     

foreach ($item in $Materiel)
{
    New-ADOrganizationalUnit -Name $item -Description "$item"  -Path "OU=Materiels,OU=Sites,DC=$Dom,DC=$EXT" -ProtectedFromAccidentalDeletion $false
}

    Write-Host ""
    Write-Host "Creations des objets Oridnateurs pour les Serveurs Membres" -ForegroundColor Green

$Sites = ("Lyon","New-York","London")
foreach ($item in $Sites)
       {
        
        if ($item  -contains "Lyon")
        {
            
            1..3 | ForEach-Object {
         $name = "SRV"+"_"+$item.Substring(0,3)+"_"+"{0:00}" -f $_
          New-ADComputer -Name $name -Path "OU=Server,OU=Materiels,OU=Sites,DC=$Dom,DC=$Ext" 
                      }

        }

}
 

$User = $(Get-ADUser -Filter * -SearchBase "OU=Sites,dc=$Dom,dc=$Ext").count
$Group = $(Get-ADGroup -Filter * -SearchBase "OU=Sites,dc=$Dom,dc=$Ext").count
$OU = $(Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Sites,dc=$Dom,dc=$Ext").count
$Object = $(Get-ADObject -Filter * -SearchBase "OU=Sites,dc=$Dom,dc=$Ext").count

Write-Host "Nous avons créer $user Utilisateurs, $Group Groupes Acitve Directory et $OU OU soit $Object Objects. "
$sw.stop
$sw.Elapsed

<#    
foreach ($item in $Sites2)
       {

        New-ADGroup -Name "G_Assistance_Technique_$item" -DisplayName "G_Assistance_Technique_$item" -GroupScope Global -GroupCategory Security -Path "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$EXT" -Description "Groupe Employes"

        $User3= Get-ADUser -Filter ’Name -like "EMP_*3"’  -SearchBase "OU=Informatiques,OU=$item,OU=Sites,DC=$Dom,DC=$EXT" 
          Add-ADPrincipalGroupMembership -Identity $User3 -MemberOf "G_Assistance_Technique_$item"
        $User7=Get-ADUser -Filter ’Name -like "EMP_*7"’  -SearchBase "OU=Informatiques,OU=$item,OU=Sites,DC=$Dom,DC=$EXT"
         Add-ADPrincipalGroupMembership -Identity $User7 -MemberOf "G_Assistance_Technique_$item" 

       }

    Write-Host "Peuplement des Groupes Globaux" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Peuplement des Groupes Globaux_Employes et Responsables" -ForegroundColor Magenta

 #>  
<#
foreach ($item in $Sites)
{
    
    $Usersistes= Get-ADUser -Filter ’Name -like "EMP*"’  -SearchBase "OU=$item,OU=Sites,DC=$Dom,DC=$EXT"
    foreach ($i in $Usersistes)
    {
        
    Add-ADPrincipalGroupMembership -Identity $i -MemberOf "G_Employes"
    }

     $Usersistes= Get-ADUser -Filter ’Name -like "RES*"’  -SearchBase "OU=$item,OU=Sites,DC=$Dom,DC=$EXT"
    foreach ($y in $Usersistes)
    {
        
    Add-ADPrincipalGroupMembership -Identity $y -MemberOf "G_Responsables"
    
    }

    $Usersistes= Get-ADUser -Filter ’Name -like "EMP_*"’  -SearchBase "OU=$item,OU=Sites,DC=$Dom,DC=$EXT"
    foreach ($z in $Usersistes)
    {
       
      if ($z -like  "*Assu*" )
      {
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Assurance_Qualite"
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Employes_Assurance_Qualite"
      }
      elseif ($z -like  "*Comm*")
      {
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Commercial"
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Employes_Commercial"
      }
       elseif ($z -like  "*Comp*")
      {
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Comptabilite"
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Employes_Comptabilite"
      }
      elseif ($z -like  "*Dire*")
      {
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Direction"
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Employes_Direction"
      }
      elseif ($z -like  "*Envi*")
      {
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Environnement"
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Employes_Environnement"
      }
      elseif ($z -like  "*Prod*")
      {
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Production"
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Employes_Production"
      }
      elseif ($z -like  "*Rech*")
      {
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Recherche_et_Developpement"
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Employes_Recherche_et_Developpement"
      }
      elseif ($z -like  "*Ress*")
      {
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Ressources_Humaines"
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Employes_Ressources_Humaines"
      }
       elseif ($z -like  "*info*")
      {
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_informatiques"
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Employes_Informatiques"
      }
    }
    $Usersistes= Get-ADUser -Filter ’Name -like "RES_*"’  -SearchBase "OU=$item,OU=Sites,DC=$Dom,DC=$EXT"
    foreach ($w in $Usersistes)
    {
       
      if ($w -like  "*Assu*" )
      {
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Assurance_Qualite"
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Responsables_Assurance_Qualite"
      }
      elseif ($w -like  "*Comm*")
      {
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Commercial"
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Responsables_Commercial"
      }
       elseif ($w -like  "*Comp*")
      {
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Comptabilite"
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Responsables_Comptabilite"
      }
      elseif ($w -like  "*Dire*")
      {
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Direction"
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Responsables_Direction"
      }
      elseif ($w -like  "*Envi*")
      {
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Environnement"
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Responsables_Environnement"
      }
      elseif ($w -like  "*Prod*")
      {
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Production"
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Responsables_Production"
      }
      elseif ($w -like  "*Rech*")
      {
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Recherche_et_Developpement"
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Responsables_Recherche_et_Developpement"
      }
      elseif ($w -like  "*Ress*")
      {
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Ressources_Humaines"
      Add-ADPrincipalGroupMembership -Identity $w -MemberOf "G_Responsables_Ressources_Humaines"
      }
         elseif ($z -like  "*info*")
      {
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_informatiques"
      Add-ADPrincipalGroupMembership -Identity $z -MemberOf "G_Responsables_Informatiques"
      }
    }

}
    Write-Host ""
    Write-Host "Peuplement des Groupes de Domaines Locaux " -ForegroundColor Magenta

#Ajout des GL dans les DL

$groupeGL = Get-ADGroup -filter "*" -SearchBase "OU=Globaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$Ext"
$groupeDL = Get-ADGroup -filter "*" -SearchBase "OU=Domaines Locaux,OU=Groupes,OU=Sites,DC=$Dom,DC=$Ext"


foreach ($gl in $groupeGL)
{
    foreach ($dl in $groupeDL)
    {
   switch ($gl) 
    { 
        {(($gl -match "assu") -And ($dl -match "Assurance_Qualite_LM"))} {Add-ADGroupMember -Identity $dl -Members $gl} 
        
        {(($gl -notmatch "assu") -And ($gl -notmatch "info"))} {Add-ADGroupMember -Identity "DL_Assurance_Qualite_L" -Members $gl} 
        
        {(($gl -match "comm") -And ($dl -match "Commercial_LM"))} {Add-ADGroupMember -Identity $dl -Members $gl} 
        
        {(($gl -notmatch "comm") -And ($gl -notmatch "info"))} {Add-ADGroupMember -Identity "DL_Commercial_L" -Members $gl} 
        
        {(($gl -match "comp") -And ($dl -match "Comptabilite_LM"))} {Add-ADGroupMember -Identity $dl -Members $gl} 
        
        {(($gl -notmatch "comp") -And ($gl -notmatch "info"))} {Add-ADGroupMember -Identity "DL_Comptabilite_L" -Members $gl} 
        
        {(($gl -match "dir") -And ($dl -match "Direction_LM"))} { Add-ADGroupMember -Identity $dl -Members $gl}
        
        {(($gl -notmatch "dir") -And ($gl -notmatch "info"))} { Add-ADGroupMember -Identity "DL_Direction_L" -Members $gl} 
        
        {(($gl -match "Envi") -And ($dl -match "Environnement_LM")) }{Add-ADGroupMember -Identity $dl -Members $gl}

        {(($gl -notmatch "Envi") -And ($gl -notmatch "info"))}{Add-ADGroupMember -Identity "DL_Environnement_L" -Members $gl}

        {(($gl -match "Prod") -And ($dl -match "Production_LM"))}{Add-ADGroupMember -Identity $dl -Members $gl}

        {(($gl -notmatch "Prod") -And ($gl -notmatch "info"))}{ Add-ADGroupMember -Identity "DL_Production_L" -Members $gl}

        {(($gl -match "Recherche") -And ($dl -match "Recherche_et_Developpement_LM"))}{Add-ADGroupMember -Identity $dl -Members $gl}

        {(($gl -notmatch "Recherche") -And ($gl -notmatch "info"))}{Add-ADGroupMember -Identity "DL_Recherche_et_Developpement_L" -Members $gl}

        {(($gl -match "Ressources_Humaines") -And ($dl -match "DL_Ressources_Humaines_LM"))}{Add-ADGroupMember -Identity $dl -Members $gl}

        {(($gl -notmatch "Ressources_Humaines") -And ($gl -notmatch "info"))}{Add-ADGroupMember -Identity "DL_Ressources_Humaines_L" -Members $gl}

        {(($gl -match "info") -And ($dl -match "CT"))}{Add-ADGroupMember -Identity  $dl -Members $gl}
        
        default {}
    }
    }
}


##################################################################################
Import-Module NTFSSecurity -force
# Informations Partage
$chemin = "Commun"
$Drive = "E:\"
$cheminF=$drive+$chemin 

Write-Host "Creation de l'arborescence de fichier " -ForegroundColor Green

Set-Location E:\
New-Item -Name "$chemin" -ItemType directory | Out-Null
# New-SmbShare -Name $chemin -Path $cheminf -FullAccess "AUTORITE NT\Utilisateurs authentifiés" -Description "Accès $chemin " | Out-Null
New-SmbShare -Name $chemin -Path $cheminf -ChangeAccess "AUTORITE NT\Utilisateurs authentifiés" -Description "Accès $chemin " | Out-Null

Add-NTFSAccess -Path $cheminF -Account "$Dom\Administrateur" -AccessRights FullControl -AccessType Allow
Add-NTFSAccess -Path $cheminF -Account "BUILTIN\Administrateurs" -AccessRights FullControl -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles
Add-NTFSAccess -Path $cheminf -Account "$Dom\DL_Acces_Commun_CT" -AccessRights FullControl -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles
Add-NTFSAccess -Path $cheminf -Account "$Dom\DL_Acces_Commun_LM" -AccessRights Modify -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles
Add-NTFSAccess -Path $cheminf -Account "$Dom\DL_Acces_Commun_L" -AccessRights ReadAndExecute -AccessType Allow -AppliesTo ThisFolderSubfoldersAndFiles

Set-NTFSInheritance -Path $cheminF -AccessInheritanceEnabled $false -AuditInheritanceEnabled $true 


foreach ($item in $Services)
{
Set-Location $cheminF |Out-Null
New-Item -Name $item.Replace(" ","_") -ItemType directory |Out-Null
Set-Location $cheminF |Out-Null
$item2 = $item.Replace(" ","_")
$chemin = "$cheminF" + "\$item2"

    Set-NTFSInheritance -Path $item.Replace(" ","_") -AccessInheritanceEnabled $false -AuditInheritanceEnabled $true 


        $groupeL = "DL_" + $item.Replace(" ","_") + "_L" 
        $groupeLM = "DL_" + $item.Replace(" ","_") + "_LM" 
        $groupeCT = "DL_" + $item.Replace(" ","_") + "_CT" 
            Add-NTFSAccess -Path $chemin -Account "$Dom\$groupeL" -AccessRights ReadAndExecute -AccessType Allow 
           
            Add-NTFSAccess -Path $chemin -Account "$Dom\$groupeLM" -AccessRights Modify -AccessType Allow 
            
            Add-NTFSAccess -Path $chemin -Account "$Dom\$groupeCT" -AccessRights FullControl -AccessType Allow 
            
            Add-NTFSAccess -Path $chemin -Account "$Dom\Administrateur" -AccessRights FullControl -AccessType Allow
     
}

#region Definitions des autorisations NTFS
$groupeL = "DL_" +"Acces_Commun"  + "_L"
$groupeCT = "DL_" +"Acces_Commun"  + "_CT"
Add-NTFSAccess -Path $cheminf -Account "$Dom\$groupeL" -AccessRights ReadAndExecute -AccessType Allow
Add-NTFSAccess -Path $cheminf -Account "$Dom\$groupeCT" -AccessRights FullControl -AccessType Allow
#>
