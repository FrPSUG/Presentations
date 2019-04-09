$ModuleName = "<%= $PLASTER_PARAM_ModuleName %>"

$Current = (Split-Path -Path $MyInvocation.MyCommand.Path)
$Root = ((Get-Item $Current).Parent).FullName

$moduleManifest = Join-Path -Path $Root\$ModuleName -ChildPath "$ModuleName.psd1"

Describe 'Module' {
	Context 'Manifest' {
		$script:manifest = $null

		It 'has a valid manifest' {
			{
				$script:manifest = Test-ModuleManifest -Path $moduleManifest -ErrorAction Stop -WarningAction SilentlyContinue
			} | Should Not throw
		}
		
		It 'has a valid name in the manifest' {
			$script:manifest.Name | Should Be $moduleName
		}

		It 'has a valid root module' {
			$RootModule = ".\" + $ModuleName + ".psm1"
			$script:manifest.RootModule | Should Be ($RootModule)
		}

		It 'has a valid version in the manifest' {
			$script:manifest.Version -as [Version] | Should Not BeNullOrEmpty
		}
	
		It 'has a valid description' {
			$script:manifest.Description | Should Not BeNullOrEmpty
		}

		It 'has a valid author' {
			$script:manifest.Author | Should Not BeNullOrEmpty
		}
	
		It 'has a valid guid' {
			{ 
				[guid]::Parse($script:manifest.Guid) 
			} | Should Not throw
		}
	
		It 'has a valid copyright' {
			$script:manifest.CopyRight | Should Not BeNullOrEmpty
		}
	}
}