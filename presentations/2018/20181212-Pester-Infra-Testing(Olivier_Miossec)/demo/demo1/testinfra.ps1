$jsonPath =  join-path  -path $PSScriptRoot  -childpath 'tests.json' -Resolve



$servers = (Get-Content $jsonPath -Raw | ConvertFrom-Json) 


Describe "SQL Test" {

    context "DB Setup" {

        foreach($serv in $servers.sql) {

            foreach ($database in $serv.db) {

                It "$($serv.name) has a db name $($database)" {
                    Get-DbaDatabase -SqlInstance $serv.name -Database $database | Should not BeNullOrEmpty
                }

                It "$($database) Got a version table " {
                    Get-DbaDbTable -SqlInstance $serv.name -Database $database -Table version | Should not BeNullOrEmpty
                }

            }

        }
    }

}


Describe "SQL Test" {

    context "DB Setup" {

        foreach($serv in $servers.web) {

            it "$($serv.Name) got a Web service that retourn a HTTP status OK " {
                $WebResponse = Invoke-WebRequest -UseBasicParsing -Uri $serv.site
                $WebResponse.StatusCode | Should be 200
            }

        }

    }
}

