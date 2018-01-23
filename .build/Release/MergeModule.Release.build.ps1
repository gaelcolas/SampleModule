Param (
    [string]
    $ProjectName = (property ProjectName (Split-Path -Leaf $BuildRoot) ),

    [string]
    $SourceFolder = $ProjectName,

    [string]
    $BuildOutput = (property BuildOutput 'C:\BuildOutput'),
    
    [string]
    $ModuleVersion = (property ModuleVersion $(
        if($ModuleVersion = Get-NextPSGalleryVersion -Name $ProjectName -ea 0) { $ModuleVersion } else { '0.0.1' }
        )),

    $MergeList = (property MergeList @('enum*','class*','priv*','pub*') ),
    
    [string]
    $LineSeparation = (property LineSeparation ('-' * 78))

)

Task CopySourceToModuleOut {
    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }
    $BuiltModuleFolder = [io.Path]::Combine($BuildOutput,$ProjectName)
    "Copying $BuildRoot\$SourceFolder To $BuiltModuleFolder\"
    Copy-Item -Path "$BuildRoot\$SourceFolder" -Destination "$BuiltModuleFolder\" -Recurse -Force -Exclude '*.bak'
}

Task MergeFilesToPSM1 {
    "`tORDER: $($MergeList.ToString())"
    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }
    $BuiltModuleFolder = [io.Path]::Combine($BuildOutput,$ProjectName)
    if(!$MergeList) {$MergeList = @('enum*','class*','priv*','pub*') }

    # Merge individual PS1 files into a single PSM1, and delete merged files
    $OutModulePSM1 = [io.path]::Combine($BuiltModuleFolder,"$ProjectName.psm1")
    "Merging to $OutModulePSM1"
    $MergeList | Get-MergedModule -DeleteSource -SourceFolder $BuiltModuleFolder | Out-File $OutModulePSM1 -Force
}

Task CleanOutputEmptyFolders {

    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }

    Get-ChildItem $BuildOutput -Recurse -Force | Sort-Object -Property FullName -Descending | Where-Object {
        $_.PSIsContainer -and
        $_.GetFiles().count -eq 0 -and
        $_.GetDirectories().Count -eq 0 
    } | Remove-Item
}

Task UpdateModuleManifest {

    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }
    $BuiltModule = [io.path]::Combine($BuildOutput,$ProjectName,"$ProjectName.psd1")
    Set-ModuleFunctions -Path $BuiltModule
    if($ModuleVersion) {
        Update-Metadata -path $BuiltModule -PropertyName ModuleVersion -Value $ModuleVersion
    }
}