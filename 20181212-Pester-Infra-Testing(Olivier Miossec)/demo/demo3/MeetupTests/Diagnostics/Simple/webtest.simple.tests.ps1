Describe 'web site configuration' {

    context "Web file" {

        it "As a iisstart.htm file" {

            test-path "c:\inetpub\wwwroot\iisstart.htm" | should be $true

        }

        it "As a pester.png file" {

            test-path "c:\inetpub\wwwroot\pester.png" | should be $true

        }

    }

    context "Web Config" {

        $AppPool = Get-IISAppPool -Name DefaultAppPool

        it "Got an application pool started" {
            $AppPool.state | Should be "Started"
        }

        it "Got an application pool with Pool Identity" {
            $AppPool.ProcessModel.IdentityType| Should be "ApplicationPoolIdentity"
        }

    }

    context "Web site is OK" {

        it "Respond to http request" {
            $WebResponse = Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost' 
            $WebResponse.StatusCode | Should be 200
        }



    }

}