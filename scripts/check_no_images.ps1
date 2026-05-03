param(
    [switch]$Staged
)

# Reject image files in source control. This repository intentionally keeps
# development/process screenshots out of git history.

if ($env:WBC_ALLOW_IMAGE_COMMITS -eq "1") {
    Write-Host "WBC_ALLOW_IMAGE_COMMITS=1 set: image policy check skipped."
    exit 0
}

$imageRegex = '(?i)\.(png|jpe?g|gif|webp|bmp|tiff?|ico|svg)$'

if ($Staged) {
    $mode = "staged"
    $files = @(git diff --cached --name-only --diff-filter=ACMR)
}
else {
    $mode = "tracked"
    $files = @(git ls-files)
}

$matches = @($files | Where-Object { $_ -match $imageRegex })

if ($matches.Count -gt 0) {
    Write-Host "Image files are blocked by repository policy:" -ForegroundColor Red
    $matches | ForEach-Object { Write-Host $_ }
    Write-Host ""
    Write-Host "Move development images to .dev-artifacts/ or screenshots/ (ignored)."
    Write-Host "If an exception is truly needed, set WBC_ALLOW_IMAGE_COMMITS=1 for that command."
    exit 1
}

Write-Host "Image policy check passed ($mode)."
