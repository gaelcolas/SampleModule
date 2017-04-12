Param (
    [io.DirectoryInfo]
    $ProjectPath = (property ProjectPath (Join-Path $PSScriptRoot '../..' -Resolve -ErrorAction SilentlyContinue)),

    [string]
    $ProjectName = (property ProjectName (Split-Path -Leaf (Join-Path $PSScriptRoot '../..')) ),

    [string]
    $SourceFolder = $ProjectName,

    [string]
    $HelpFolder = (property HelpFolder 'docs'),

    [string]
    $BuildOutput = (property BuildOutput 'C:\BuildOutput'),

    [cultureinfo]
    $HelpCultureInfo = 'en-US',

    [string]
    $LineSeparation = (property LineSeparation ('-' * 78))

)

Task GenerateMamlFromMd {
    $LineSeparation
    "`t`t`t GENERATE MAML IN BUILD OUTPUT"
    $LineSeparation

    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $ProjectPath.FullName -ChildPath $BuildOutput
    }
    $BuiltModuleFolder = [io.Path]::Combine($BuildOutput,$ProjectName)

    New-ExternalHelp -Path "$SourceFolder\$HelpFolder" -OutputPath "$BuiltModuleFolder\$HelpCultureInfo" -Force
}

