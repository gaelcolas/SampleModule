Param (
    [string]
    $BuildOutput = (property BuildOutput 'BuildOutput'),

    [string]
    $ProjectName = (property ProjectName (Split-Path -Leaf $BuildRoot) ),

    [string]
    $PesterOutputFormat = (property PesterOutputFormat 'NUnitXml'),

    [string]
    $APPVEYOR_JOB_ID = $(try {property APPVEYOR_JOB_ID} catch {})
)

# Synopsis: Uploading Unit Test results to AppVeyor
task UploadUnitTestResultsToAppVeyor -If {(property BuildSystem 'unknown') -eq 'AppVeyor'} {

    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
    }

    $TestOutputPath  = [system.io.path]::Combine($BuildOutput,'testResults','unit',$PesterOutputFormat)
    $TestResultFiles = Get-ChildItem -Path $TestOutputPath -Filter *.xml
    $TestResultFiles | Add-TestResultToAppveyor
}