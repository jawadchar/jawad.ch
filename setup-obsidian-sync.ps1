#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sets up symlinks between your Obsidian vault and this portfolio repo
    so that writing in Obsidian automatically updates the site's blog content.

.DESCRIPTION
    Creates two Windows directory junctions (symlinks):
      - Obsidian vault\blogposts  → repo\src\content\blog
      - Obsidian vault\attachments → repo\public\images

    After running this script:
      1. Install the Obsidian Git plugin (community plugins)
      2. Configure it per the instructions in SETUP.md
      3. Write posts in blogposts\ inside Obsidian → auto-pushes → Netlify deploys

.NOTES
    Run this once from PowerShell as Administrator.
    The Obsidian vault must already exist at the path below.
#>

$RepoRoot    = Split-Path -Parent $MyInvocation.MyCommand.Path
$VaultRoot   = "C:\Users\jawad\Documents\Obsidian Vaults\IT & Cyber"
$BlogTarget  = Join-Path $RepoRoot "src\content\blog"
$ImgTarget   = Join-Path $RepoRoot "public\images"
$BlogLink    = Join-Path $VaultRoot "blogposts"
$ImgLink     = Join-Path $VaultRoot "attachments"

Write-Host "`n=== jawad.ch Obsidian Sync Setup ===" -ForegroundColor Cyan

# Verify vault exists
if (-not (Test-Path $VaultRoot)) {
    Write-Error "Obsidian vault not found at: $VaultRoot"
    Write-Host "Update the `$VaultRoot variable in this script to match your vault path." -ForegroundColor Yellow
    exit 1
}

# ── blogposts symlink ────────────────────────────────────────────────────────
if (Test-Path $BlogLink) {
    $item = Get-Item $BlogLink -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "[SKIP] blogposts symlink already exists." -ForegroundColor Yellow
    } else {
        # Real folder exists — migrate content then remove
        Write-Host "[MIGRATE] Moving existing blogposts content to repo..." -ForegroundColor Cyan
        Get-ChildItem $BlogLink | Move-Item -Destination $BlogTarget -Force
        Remove-Item $BlogLink -Recurse -Force
        cmd /c "mklink /J `"$BlogLink`" `"$BlogTarget`"" | Out-Null
        Write-Host "[OK] blogposts symlink created." -ForegroundColor Green
    }
} else {
    cmd /c "mklink /J `"$BlogLink`" `"$BlogTarget`"" | Out-Null
    Write-Host "[OK] blogposts symlink created." -ForegroundColor Green
}

# ── attachments symlink ──────────────────────────────────────────────────────
if (Test-Path $ImgLink) {
    $item = Get-Item $ImgLink -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "[SKIP] attachments symlink already exists." -ForegroundColor Yellow
    } else {
        Write-Host "[MIGRATE] Moving existing attachments to repo..." -ForegroundColor Cyan
        Get-ChildItem $ImgLink | Move-Item -Destination $ImgTarget -Force
        Remove-Item $ImgLink -Recurse -Force
        cmd /c "mklink /J `"$ImgLink`" `"$ImgTarget`"" | Out-Null
        Write-Host "[OK] attachments symlink created." -ForegroundColor Green
    }
} else {
    cmd /c "mklink /J `"$ImgLink`" `"$ImgTarget`"" | Out-Null
    Write-Host "[OK] attachments symlink created." -ForegroundColor Green
}

Write-Host "`n=== Done! Next steps ===" -ForegroundColor Cyan
Write-Host "1. In Obsidian: Settings -> Files & Links"
Write-Host "   - Set 'Default location for new attachments' to: attachments"
Write-Host "   - Turn OFF 'Use [[Wikilinks]]' (optional but recommended)"
Write-Host ""
Write-Host "2. Install the 'Obsidian Git' community plugin"
Write-Host "   Then configure it:"
Write-Host "   - Vault base path: auto-detected (the repo root)"
Write-Host "   - Auto commit after file change: ON"
Write-Host "   - Auto push after commit: ON"
Write-Host "   - Commit message: 'blog: {{date}} auto-commit'"
Write-Host ""
Write-Host "3. Ensure your git remote is set:"
Write-Host "   cd `"$RepoRoot`""
Write-Host "   git remote add origin https://github.com/jawadchar/<repo-name>.git"
Write-Host ""
Write-Host "4. Copy your resume PDF to: $RepoRoot\public\Jawad_Charafeddine_Resume.pdf"
Write-Host ""
Write-Host "5. Connect Netlify to your GitHub repo (see SETUP.md)"
Write-Host ""
