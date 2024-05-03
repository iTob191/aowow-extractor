param(
	[Parameter(Position = 0, Mandatory)]
	[string]$DataPath,
	[Parameter(Position = 1, Mandatory)]
	[string]$OutPath
)

$ErrorActionPreference = "Stop"

function Write-Help {
	Write-Host ""
	Write-Host "Usage: $ScriptName <data directory> <output directory>"
	Write-Host ""
	Write-Host "  data directory:     path to the data directory containing the mpq files"
	Write-Host "  output directory:   path to the output directory"
}

function Write-Err {
	[Console]::ForegroundColor = [ConsoleColor]::Red
	[Console]::Error.WriteLine("error: $args")
	[Console]::ResetColor()
}

if (-not (Test-Path $DataPath -PathType Container)) {
	Write-Err "cannot find the data directory at $DataPath"
	exit 1
}

if (-not (Test-Path $OutPath -PathType Container)) {
	try {
		New-Item -Path $OutPath -ItemType Directory -ErrorAction Stop | Out-Null
	}
	catch {
		Write-Err "could not create output directory $OutPath"
		exit 1
	}
}

Write-Host "Building docker container ..."
docker build --quiet --tag=aowow-extractor . | Out-Null || $(exit 1)

Write-Host "Starting docker container ..."
docker run --rm -it -v "${DataPath}:/data:ro" -v "${OutPath}:/out:rw" aowow-extractor || $(exit 1)
