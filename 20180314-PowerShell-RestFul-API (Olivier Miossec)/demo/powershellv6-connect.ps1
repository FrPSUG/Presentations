
# Open with pwsh

Invoke-RestMethod -Method get -uri "https://sophos.omiossec.work:4444//api/objects/network/host/" -SslProtocol TLS12 -SkipCertificateCheck 