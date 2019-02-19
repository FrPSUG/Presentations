param (
    $BuildModulePath=$Env:BUILD_SOURCESDIRECTORY,
    $ModuleName = $ENV:ModuleName
)


$ModuleManifestPath = "$($BuildModulePath)\build\$($ModuleName)\$($ModuleName).psd1"


Get-Module -Name $ModuleName | remove-module

$ModuleInformation = Import-module -Name $ModuleManifestPath -PassThru

Describe "$ModuleName Module - Testing Manifest File (.psd1)"{

    Context "$ModuleName Module Configuration" {

        It "Should contains RootModule" {
            $ModuleInformation.RootModule | Should not BeNullOrEmpty
        }

        It "Should contains Author" {
            $ModuleInformation.Author | Should not BeNullOrEmpty
        }

        It "Should contains Company Name" {
             $ModuleInformation.CompanyName|Should not BeNullOrEmpty
            }

        It "Should contains Description" {
            $ModuleInformation.Description | Should not BeNullOrEmpty
        }

    }

    Context "Testing Internal Functions from $ModuleName" {



            it "get-psmWorldClock Return a datetime" {

                $TimeResult = get-psmWorldClock -timeZone CET

                ($TimeResult.gettype()).Name | Should be "DateTime"

            }







    }

}