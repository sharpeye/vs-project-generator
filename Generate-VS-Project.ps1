param(
    [String] $SourceDir,
    [String] $OutputFileName
)

Set-Content -Path $OutputFileName -Encoding UTF8 -Value @"
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" ToolsVersion="14.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Debug|ARM">
      <Configuration>Debug</Configuration>
      <Platform>ARM</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|ARM">
      <Configuration>Release</Configuration>
      <Platform>ARM</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Debug|x86">
      <Configuration>Debug</Configuration>
      <Platform>x86</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|x86">
      <Configuration>Release</Configuration>
      <Platform>x86</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Debug|x64">
      <Configuration>Debug</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|x64">
      <Configuration>Release</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label="Globals">
    <ProjectGuid>{d14472f1-e80c-4d22-a2b5-6694cdc04c48}</ProjectGuid>
    <Keyword>Linux</Keyword>
    <RootNamespace>makefile</RootNamespace>
    <MinimumVisualStudioVersion>14.0</MinimumVisualStudioVersion>
    <ApplicationType>Linux</ApplicationType>
    <ApplicationTypeRevision>1.0</ApplicationTypeRevision>
    <TargetLinuxPlatform>Generic</TargetLinuxPlatform>
    <LinuxProjectType>{FC1A4D80-50E9-41DA-9192-61C0DBAA00D2}</LinuxProjectType>
  </PropertyGroup>
  <Import Project="`$(VCTargetsPath)\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Debug|ARM'" Label="Configuration">
    <UseDebugLibraries>true</UseDebugLibraries>
    <ConfigurationType>Makefile</ConfigurationType>
  </PropertyGroup>
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|ARM'" Label="Configuration">
    <UseDebugLibraries>false</UseDebugLibraries>
    <ConfigurationType>Makefile</ConfigurationType>
  </PropertyGroup>
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Debug|x86'" Label="Configuration">
    <UseDebugLibraries>true</UseDebugLibraries>
    <ConfigurationType>Makefile</ConfigurationType>
  </PropertyGroup>
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|x86'" Label="Configuration">
    <UseDebugLibraries>false</UseDebugLibraries>
    <ConfigurationType>Makefile</ConfigurationType>
  </PropertyGroup>
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Debug|x64'" Label="Configuration">
    <UseDebugLibraries>true</UseDebugLibraries>
    <ConfigurationType>Makefile</ConfigurationType>
  </PropertyGroup>
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|x64'" Label="Configuration">
    <UseDebugLibraries>false</UseDebugLibraries>
    <ConfigurationType>Makefile</ConfigurationType>
  </PropertyGroup>
  <Import Project="`$(VCTargetsPath)\Microsoft.Cpp.props" />
  <ImportGroup Label="ExtensionSettings" />
  <ImportGroup Label="Shared" />
  <ImportGroup Label="PropertySheets" />
  <PropertyGroup Label="UserMacros" />
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Debug|ARM'">
    <LocalRemoteCopySources>false</LocalRemoteCopySources>
  </PropertyGroup>
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Debug|x64'">
    <LocalRemoteCopySources>false</LocalRemoteCopySources>
  </PropertyGroup>
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Debug|x86'">
    <LocalRemoteCopySources>false</LocalRemoteCopySources>
  </PropertyGroup>
    <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|ARM'">
    <LocalRemoteCopySources>false</LocalRemoteCopySources>
  </PropertyGroup>
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|x64'">
    <LocalRemoteCopySources>false</LocalRemoteCopySources>
  </PropertyGroup>
  <PropertyGroup Condition="'`$(Configuration)|`$(Platform)'=='Release|x86'">
    <LocalRemoteCopySources>false</LocalRemoteCopySources>
  </PropertyGroup>
"@

function GenerateProj{

    Push-Location $script:SourceDir

    $GenInclude = { "    <$($args[1]) Include=`"$(Resolve-Path $args[0].FullName -Relative)`" />" }

    Get-ChildItem -Recurse -File -Exclude *.h, *.cpp, *.c, *.txt, *.o, *.vcxproj, *.filters | ForEach-Object { "  <ItemGroup>"}{ . $GenInclude $_ "None" }{ "  </ItemGroup>" }
    Get-ChildItem -Recurse -File -Filter *.txt | ForEach-Object { "  <ItemGroup>"}{ . $GenInclude $_ "Text" }{ "  </ItemGroup>" }
    Get-ChildItem -Recurse -File -Filter *.cpp | ForEach-Object { "  <ItemGroup>"}{ . $GenInclude $_ "ClCompile" }{ "  </ItemGroup>" }
    Get-ChildItem -Recurse -File -Filter *.h | ForEach-Object   { "  <ItemGroup>"}{ . $GenInclude $_ "ClInclude" }{ "  </ItemGroup>" }

    Pop-Location

@"
  <ItemDefinitionGroup />
  <Import Project="`$(VCTargetsPath)\Microsoft.Cpp.targets" />
  <ImportGroup Label="ExtensionTargets" />
</Project>
"@

}

(GenerateProj) | Add-Content -Path $OutputFileName -Encoding UTF8

$OutputFileName = $OutputFileName + ".filters"

Set-Content -Path $OutputFileName -Encoding UTF8 -Value @"
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
"@

function GenerateFilters{
    Push-Location $script:SourceDir

    $GenItemGroup = {
        $name = $args[1]
        $t = $(Resolve-Path $args[0].FullName -Relative)
        $p = Split-Path -Path $t -Parent
        if( $p -eq '.')
        {
          "    <$name Include=`"$t`" />"
        }
        else
        {
          "    <$name Include=`"$t`" >"
          "      <Filter>$($p.Substring(2))</Filter>"
          "    </$name>"
        }
    }

    Get-ChildItem -Recurse -Directory | ForEach-Object {
          "  <ItemGroup>" }{

            $t = $(Resolve-Path $_.FullName -Relative)
            if( $t -ne '.'){
              "    <Filter Include=`"$($t.Substring(2))`">"
              "      <UniqueIdentifier>{$([guid]::NewGuid())}</UniqueIdentifier>"
              "    </Filter>" }}{
          "  </ItemGroup>"
    }

    Get-ChildItem -Recurse -File -Exclude *.h, *.cpp, *.c, *.txt, *.o, *.vcxproj, *.filters | ForEach-Object { "  <ItemGroup>" }{ . $GenItemGroup $_ "None" }{ "  </ItemGroup>" }
    Get-ChildItem -Recurse -File -Filter *.txt | ForEach-Object { "  <ItemGroup>" }{ . $GenItemGroup $_ "Text" }{ "  </ItemGroup>" }
    Get-ChildItem -Recurse -File -Filter *.cpp | ForEach-Object { "  <ItemGroup>" }{ . $GenItemGroup $_ "ClCompile" }{ "  </ItemGroup>" }
    Get-ChildItem -Recurse -File -Filter *.h | ForEach-Object { "  <ItemGroup>" }{ . $GenItemGroup $_ "ClInclude" }{ "  </ItemGroup>" }

    "</Project>"
    Pop-Location
}

(GenerateFilters) | Add-Content -Path $OutputFileName -Encoding UTF8
