# =================================
# Config
# =================================

# Editable
$buildConfig = "Release"
$projectName ="Vendr.Contrib.PaymentProviders.Provider1"
$projectDependencies = @('')

# Non-editable
$rootDir = $PSScriptRoot
$solutionPath = "$rootDir\$projectName.sln"
$srcDir = "$rootDir\src";
$artifactsDir = "$rootDir\artifacts";
$artifactFilesDir =  "$artifactsDir\files";
$artifactPackagesDir = "$artifactsDir\packages";

Clear-Host

$ErrorActionPreference = "Stop"

Write-Host "=================================" -ForegroundColor Green
Write-Host "Clean" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "Cleaning project folders" -ForegroundColor Cyan
Get-ChildItem -Path $srcDir -Recurse -Directory  | Where-Object{$_.Name -Match "^(bin|obj)$"} | Remove-Item -Recurse

Write-Host "Cleaning artifacts folder" -ForegroundColor Cyan
if (Test-Path $artifactsDir) { 
    Remove-Item $artifactsDir -Recurse
}

Write-Host "Cleaning temp folder" -ForegroundColor Cyan
if (Test-Path .\temp) { 
    Remove-Item .\temp -Recurse
}

Write-Host "=================================" -ForegroundColor Green
Write-Host "Setup" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "Installing required NuGet packages" -ForegroundColor Cyan

Install-Package -Name GitVersion.CommandLine -ProviderName NuGet -Scope CurrentUser -RequiredVersion  5.7.0 -Destination .\temp -Force
Install-Package -Name ILRepack -ProviderName NuGet -Scope CurrentUser -RequiredVersion 2.0.18 -Destination .\temp -Force

Write-Host "Installing required global tools" -ForegroundColor Cyan

dotnet tool install Umbraco.Tools.Packages --tool-path .\temp

Write-Host "Calculating GitVersion info" -ForegroundColor Cyan

$gitVersionOutput = .\temp\GitVersion.CommandLine.5.7.0\tools\Gitversion.exe /nofetch | Out-String
$gitVersion = $gitVersionOutput | ConvertFrom-Json

$nuGetVersion = $gitVersion.NugetVersion
$nuGetVersionV2 = $gitVersion.NugetVersionV2
$assemblyVersion = $gitVersion.AssemblyVersion
$assemblyFileVersion = $gitVersion.AssemblyFileVersion
$assemblyInformationalVersion = $gitVersion.SemVer + "/" + $gitVersion.Sha

Write-Host "NuGet Version: $nuGetVersion"
Write-Host "NuGet Version V2: $nuGetVersionV2"
Write-Host "Assembly Version: $assemblyVersion"
Write-Host "Assembly File Version: $assemblyFileVersion"
Write-Host "Assembly Informational Version: $assemblyInformationalVersion"

Write-Host "=================================" -ForegroundColor Green
Write-Host "Restore" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "Restoring solution $projectName.sln" -ForegroundColor Cyan

dotnet restore $solutionPath

Write-Host "=================================" -ForegroundColor Green
Write-Host "Compile" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "Compiling solution $projectName.sln" -ForegroundColor Cyan

dotnet build $solutionPath --configuration $buildConfig --no-restore -p:AssemblyVersion=$assemblyVersion -p:FileVersion=$assemblyFileVersion -p:InformationalVersion=$assemblyInformationalVersion -p:CopyLocalLockFileAssemblies=true

Write-Host "=================================" -ForegroundColor Green
Write-Host "Prepare" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "Preparing build files" -ForegroundColor Cyan

$binDir = "$srcDir\$projectName\bin\$buildConfig\netstandard2.0"
$inputDll = "$binDir\$projectName.dll"
$outputDll = "$artifactFilesDir\bin\$projectName.merged.dll"
$additionalDlls = $projectDependencies.ForEach({
    if (-not ([string]::IsNullOrEmpty($_))) {
        "$binDir\$_"
    }
})

Write-Host "Merging dependencies" -ForegroundColor Cyan

.\temp\ILRepack.2.0.18\tools\ILRepack.exe /ndebug /internalize /copyattrs /targetplatform:v4 /lib:$binDir /out:$outputDll $inputDll $additionalDlls 

Write-Host "=================================" -ForegroundColor Green
Write-Host "Pack" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "Packing NuGet package" -ForegroundColor Cyan

dotnet pack $solutionPath --configuration $buildConfig --no-build -p:PackageVersion=$nuGetVersionV2 --output $artifactPackagesDir

Write-Host "Packing Umbraco package" -ForegroundColor Cyan

$umbracoPackageXmlDir = "$rootDir\build\Umbraco";
$umbracoPackageXmlFile = "$umbracoPackageXmlDir\$projectName.package.xml";

.\temp\UmbPack.exe pack $umbracoPackageXmlFile -n '{name}.{version}.zip' -v $nuGetVersion -o $artifactPackagesDir -p "ArtifactsDirectory=$artifactsDir"

Write-Host "=================================" -ForegroundColor Green
Write-Host "Done!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

if (Test-Path .\temp) { 
    Remove-Item .\temp -Recurse
}