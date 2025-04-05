[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $DebugExport,
    [Switch]
    $NoVersionIncrement,
    [Switch]
    $VersionIncrement
)

$project_name_key = "config/name"
$project_version_key = "config/version"

$config = ([xml](Get-Content '.\export_config.xml')).config

$exports = $config.exports.export

$version_prefix = $config.version_prefix

$git_main_branch = $config.git_main_branch

$exports_base_dir = $config.exports_base_dir

$godot_command = $config.godot_command
$additional_command_args = $config.additional_args

$increment_version_config = $config.increment_version -eq "true"

if (!(Test-Path -PathType Leaf .\project.godot))
{
    Write-Error "Couldn't find project.godot: must be run from project root"
    exit 1;
}

#====  PROJECT NAME  ====#

# Get the project name from project.godot
$project_name_groups = (Select-String -Path .\project.godot -Pattern "$project_name_key=""(.*)""").Matches.Groups

if ($project_name_groups)
{
    $project_name = $project_name_groups[1].Value
}
else
{
    Write-Error "Invalid project.godot: missing or empty project name ($project_name_key)"
    exit 1;
}

#====  VERSION - GET AND UPDATE  ====#

# Get the version from project.godot
# Note that this must end with a number, which is what will be considered the build number
$version_groups = (Select-String -Path .\project.godot -Pattern "$project_version_key=""((.*)([0-9]+))""").Matches.Groups

$version_string = "$version_prefix$project_version"

if ($version_groups)
{
    # Set the version string
    $project_version = $version_groups[1].Value
    $version_string = "$version_prefix$project_version"

    $should_increment_version = $increment_version_config

    if ($NoVersionIncrement)
    {
        should_increment_version = $false
    }
    elseif ($VersionIncrement)
    {
        should_increment_version = $true
    }

    # If on non-main branch, append the commit number
    if ((git rev-parse --abbrev-ref HEAD) -ne $git_main_branch -or $DebugExport)
    {
        $commit = (git rev-parse --short HEAD)

        $version_string = "$version_string $commit"
    }
    # Only increment version if on main branch and set to do so
    elseif ($should_increment_version)
    {
        $rev_number = $version_groups[3].Value
        $rest = $version_groups[2].Value

        $new_rev_number = [int]$rev_number+1

        $new_version = "$rest$new_rev_number"

        Write-Host "Updating project version ($project_version_key) from $rest$rev_number to $new_version" -ForegroundColor Green

        (Get-Content .\project.godot) `
            -replace "$project_version_key="".*""", "$project_version_key=""$new_version""" |
            Out-File .\project.godot -Encoding ASCII
    }
}
else
{
    Write-Host "Couldn't find project version ($project_version_key), ommitting from export path" -ForegroundColor Red
    $version_string = ""
}

#====  CREATE BASE DIRECTORIES  ====#

$export_versioned_dir = "$exports_base_dir\$project_name$version_string"

New-Item -Path $export_versioned_dir -ItemType Directory


#====  EXPORT TEAMPLATES FROM CONFIG  ====#

foreach ($export in $exports)
{
    $export_name = $export.name

    $project_and_version = "$project_name$version_string"

    $export_file_name = "$project_and_version - $export_name"

    $export_zip_file = "$export_file_name.zip"

    $export_file_name = $export.file_name -replace "\[project_and_version\]", "$project_and_version"

    $export_path = "$export_versioned_dir\$export_name"
    $export_file_path = "$export_path\$export_file_name"

    $export_switch = "--export-release"
    if ($DebugExport)
    {
        $export_switch = "--export-debug"
    }

    Write-Host "Creating directory for export '$export_name': $export_path" -ForegroundColor Green
    New-Item -Path "$export_path" -ItemType Directory

    Write-Host "Exporting for '$export_name', to file $export_file_path" -ForegroundColor Green
    $cmd_args = "$export_switch ""$export_name"" ""$export_file_path"" $additional_command_args"
    Write-Host "> $godot_command $cmd_args"
    Start-Process -Wait "$godot_command" "$cmd_args"
    
    Write-Host "Compressing contents of '$export_path\' to '$export_versioned_dir\$export_zip_file'" -ForegroundColor Green
    Compress-Archive "$export_path\*" -DestinationPath "$export_versioned_dir\$export_zip_file"
}