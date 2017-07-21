# Generate a preview video, consisting of short clips from full video.

param (
  [string]$inFile,
  [string]$outPath,
  [string]$outPrefix = "preview_",
  [string]$outSuffix,
  [int]$previewSize = 300,
  [int]$clipDuration = 2,
  [int]$clipCount = 6
)

function New-TemporaryDirectory {
  $parent = [System.IO.Path]::GetTempPath()
  [string] $name = [System.Guid]::NewGuid()
  New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

if(-not($inFile)) { Throw "You must supply a value for -inFile" }
if(-not($outPath)) { Throw "You must supply a value for -outPath" }

if( -not (test-path $inFile)) {
  Throw "File $inFile not found"
  exit
}

$inFolder = (Get-ChildItem $inFile).Directory
$inFilename = (Get-ChildItem $inFile).Name
$inBasename = (Get-ChildItem $inFile).Basename
$inExtension = (Get-ChildItem $inFile).Extension

$tempDir = $(New-TemporaryDirectory).Fullname

# Get video duration, floor
[double]$videoDuration = $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$inFile")
$videoDuration = [int][math]::Floor($videoDuration)

# Calculate maximum clip length
$maxClipLength = [int][math]::Floor($videoDuration / $clipCount)

# correct user input if necessary
if($clipDuration -gt $maxClipLength) {
  $clipDuration = $maxClipLength
}

# create clips
$concat = "$tempDir\0.mpeg"

Invoke-Expression "ffmpeg -i '$inFile' -ss 00 -t $clipDuration -an $tempDir\0.mpeg"
1..($clipCount-1)| % {
  $s = ($maxClipLength*$_).ToString("00")
  Invoke-Expression "ffmpeg -i '$inFile' -ss $s -t $clipDuration -an $tempDir\$_.mpeg"
  $concat = "$concat|$tempDir\$_.mpeg"
}

# concatenate clips to preview video in $outPath
Invoke-Expression "ffmpeg -i 'concat:$concat' -crf 24 -vf scale='trunc(iw*min($previewSize/iw\,$previewSize/ih)/2)*2:trunc(ih*min($previewSize/iw\,$previewSize/ih)/2)*2' '$($outPath)\$($outPrefix)$($inBasename)$($outSuffix)$($inExtension)'"

# Delete temp dir
Remove-Item $tempDir -Force -Recurse
