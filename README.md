# preview-video.ps1
Generate a preview video, consisting of short clips from full video.

## Usage

Single file

    preview_video.ps1 -inFile Movie.mp4

Different output directory

    preview_video.ps1 -inFile Movie.mp4 -outPath .\previews\

Prefix and suffix. Default prefix is "preview_"

    preview_video.ps1 -inFile Movie.mp4 -outPath .\previews\ -outPrefix "prefix_" -outSuffix "_suffix"

Whole Directory

    dir -File .\vids\ | %{ preview_video.ps1 -inFile $_.fullname -outPath .\vids\prev\ -outPrefix "prefix_" -outSuffix "_suffix" }

Change dimensions of preview video or clip duration and quantity

    preview_video.ps1 -inFile Movie.mp4 -previewSize 250 -clipDuration 3 -clipCount 5

## License
http://marco.mit-license.org
