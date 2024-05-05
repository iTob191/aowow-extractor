# AoWoW Extractor

This is a docker based script to automate the generation of data required for [AoWoW](https://github.com/Sarjuuk/aowow)'s setup. Includes the data extraction ([step 4](https://github.com/Sarjuuk/aowow/blob/master/README.md#4-extract-the-client-archives-mpqs)) and conversion of audio files ([step 5](https://github.com/Sarjuuk/aowow/blob/master/README.md#5-reencode-the-audio-files)). The script also converts all images from BLP to PNG to prevent the issues described in [Troubleshooting](https://github.com/Sarjuuk/aowow/blob/master/README.md#troubleshooting).

## Requirements

* [Docker](https://docs.docker.com/get-docker/)
* WoW (WotLK) installation with the desired locales

## Usage

1. Clone the repository including submodules
2. Run `extract.sh` on Linux or `extract.ps1` on Windows with PowerShell. Run the script without parameters for usage information.

## Note on errors

The script will most likely print "There were errors" at the end. Those are _not_ necessarily critical errors that prevent the AoWoW setup from working. MPQ archives are somewhat messy and contain junk data.

The script executes tasks in parallel. Unfortunately, this sometimes results in log messages appearing out of order. So the file producing the error might not always be the one written directly above the error message but for example the one below. If you know a good way to fix this, please let me know.
