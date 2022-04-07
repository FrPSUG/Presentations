Param(
    [Parameter(Position=1)]
    [string]$VMName,

    [Parameter(Position=2)]
    [string]$VMUsername,

    [Parameter(Position=3)]
    [string]$VMPasswd,

    [Parameter(Position=4)]
    [string]$VMFolder

    )
Import-module PSTeams

$IncomingWebHook ='https://Your_WebHook_Incomming_Teams'
$Time = Get-Date -UFormat "%m/%d/%Y %R"
New-AdaptiveCard -Uri $IncomingWebHook {
    New-AdaptiveContainer {
        New-AdaptiveTextBlock -Text 'Packer VM Template Creation' -Weight Bolder -Size Medium
        New-AdaptiveColumnSet {
            New-AdaptiveColumn -Width auto {
                New-AdaptiveImage -Url "https://jm2k69.github.io/img/avatar/profil.jpg" -Size Small -Style person
            }
            New-AdaptiveColumn -Width stretch {
                New-AdaptiveTextBlock -Text "Jérôme Bezet-Torres" -Weight Bolder -Wrap
                New-AdaptiveTextBlock -Text "Created $Time" -Subtle -Spacing None -Wrap
            }
        }
    }
    New-AdaptiveContainer {
        New-AdaptiveTextBlock -Text "Packer has created a Template in VMware vSphere. For more information see below." -Wrap
    }
} -Action {
    New-AdaptiveAction -Title 'Connect' -Type Action.OpenUrl -ActionUrl 'https://sco-labo-vcsa.ad.supalta.com/ui'
    New-AdaptiveAction -Title 'Detail Packer creation' -Body {
        New-AdaptiveTextBlock -Text 'Template creation detailed ' -Weight Bolder -Size Medium
        New-AdaptiveColumnSet {
            New-AdaptiveColumn -Width auto {
                New-AdaptiveImage -Url "https://jm2k69.github.io/img/avatar/profil.jpg" -Size Small -Style person
            }
            New-AdaptiveColumn -Width stretch {
                New-AdaptiveTextBlock -Text "JM2K69" -Weight Bolder -Wrap
                New-AdaptiveTextBlock -Text "Created $Time" -Subtle -Spacing None -Wrap
            }
        }
        New-AdaptiveFactSet {
            New-AdaptiveFact -Title 'Template Name:' -Value "$VMName"
            New-AdaptiveFact -Title 'Folder:' -Value "$VMFolder"
            New-AdaptiveFact -Title 'Password:' -Value "$VMPasswd"
            New-AdaptiveFact -Title 'Username:' -Value "$VMUsername"
        }
    }
}