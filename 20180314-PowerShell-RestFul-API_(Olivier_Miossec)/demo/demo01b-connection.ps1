# Simple connexion 

Invoke-RestMethod -Method get -uri "https://sophos.omiossec.work:4444//api/objects/network/host/" 


# ajout d'une methode .net pour ne pas valider le certificat SSL 

$netDefinition = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }

"@

[System.Net.ServicePointManager]::CheckCertificateRevocationList = $false;
Add-Type $netDefinition
 
[ServerCertificateValidationCallback]::Ignore();

Invoke-RestMethod -Method get -uri "https://sophos.omiossec.work:4444//api/objects/network/host/" 






# Utilisation de tls 1.2

# ajout d'une methode .net pour ne pas valider le certificat SSL 

$netDefinition = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }

"@

[System.Net.ServicePointManager]::CheckCertificateRevocationList = $false;
Add-Type $netDefinition
 
[ServerCertificateValidationCallback]::Ignore();

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-RestMethod -Method get -uri "https://sophos.omiossec.work:4444//api/objects/network/host/" 