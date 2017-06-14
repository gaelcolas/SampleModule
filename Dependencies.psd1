@{
    # Set up a mini virtual environment...
    PSDependOptions = @{
        AddToPath = $True
        Parameters = @{
        }
    }

    buildhelpers = 'latest'
    invokeBuild = 'latest'
    pester = 'latest'
    PSScriptAnalyzer = 'latest'
    PlatyPS = 'latest'
    psdeploy = 'latest'
}