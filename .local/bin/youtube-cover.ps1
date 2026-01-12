#Requires -Version 5.1

param(
    [Parameter(Mandatory = $false)]
    [string]$Url
)

function Invoke-DownloadYoutubeThumbnail {
    param (
        [string]$VideoUrl
    )

    # Extract the video ID from the URL
    if ($VideoUrl -match "^(?:https?:\/\/)?(?:www\.|m\.)?(?:youtube\.com\/watch\?(?:.*&)?v=|youtu\.be\/)([A-Za-z0-9_-]{11})(?:[&#?].*)?$") {
        $VideoId = $matches[1]
    } else {
        Write-Host "Invalid YouTube URL" -ForegroundColor Red
        exit 1
    }

    $ThumbnailUrl = "https://img.youtube.com/vi/$VideoId/maxresdefault.jpg"
    $HomeDir = $env:HOME, $env:USERPROFILE | Where-Object { $_ -ne $null } | Select-Object -First 1
    $OutputPath = Join-Path -Path $HomeDir -ChildPath "Downloads\$VideoId.jpg"

    try {
        Invoke-WebRequest -Uri $ThumbnailUrl -OutFile $OutputPath
        Write-Host "Thumbnail downloaded to: $OutputPath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download thumbnail: $_" -ForegroundColor Red
        exit 1
    }
}

if (-not $Url) {
    Write-Host "Usage: youtube-cover <youtube_video_url>"
    exit 1
}

Invoke-DownloadYoutubeThumbnail -VideoUrl $Url
