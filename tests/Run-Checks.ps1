# Multi-Minecraft Egg - PowerShell Docker Validation Suite
param (
    [string]$Image = "potenfyr-test:all"
)

Write-Host "=== Multi-Minecraft Egg Docker Test Suite ===" -ForegroundColor Yellow
Write-Host "Target Image: $Image`n" -ForegroundColor Cyan

$testCases = @(
    @{ Type = "vanilla"; Version = "1.20.4"; File = "server.jar"; Desc = "Vanilla 1.20.4" },
    @{ Type = "paper"; Version = "1.20.4"; File = "server.jar"; Desc = "Paper 1.20.4" },
    @{ Type = "purpur"; Version = "1.20.4"; File = "server.jar"; Desc = "Purpur 1.20.4" },
    @{ Type = "folia"; Version = "latest"; File = "server.jar"; Desc = "Folia Latest" },
    @{ Type = "fabric"; Version = "1.20.4"; File = "server.jar"; Desc = "Fabric 1.20.4" },
    @{ Type = "quilt"; Version = "1.20.4"; File = "server.jar"; Desc = "Quilt 1.20.4" },
    @{ Type = "velocity"; Version = "latest"; File = "server.jar"; Desc = "Velocity Latest" },
    @{ Type = "waterfall"; Version = "latest"; File = "server.jar"; Desc = "Waterfall Latest" },
    @{ Type = "bungeecord"; Version = "latest"; File = "server.jar"; Desc = "BungeeCord Latest" },
    @{ Type = "bedrock"; Version = "latest"; File = "bedrock_server"; Desc = "Bedrock Dedicated Server Latest" },
    @{ Type = "pocketmine"; Version = "latest"; File = "PocketMine-MP.phar"; Desc = "PocketMine-MP Latest" },
    @{ Type = "neoforge"; Version = "1.20.4"; File = "unix_args.txt"; Desc = "NeoForge 1.20.4" },
    @{ Type = "forge"; Version = "1.20.1"; File = "unix_args.txt"; Desc = "Forge 1.20.1" }
)

$passed = 0
$failed = 0

foreach ($tc in $testCases) {
    Write-Host "[CHECK] Testing $($tc.Desc) ($($tc.Type) $($tc.Version))..." -ForegroundColor Cyan
    $cmd = "docker run --rm --user container -e SERVER_TYPE=$($tc.Type) -e MINECRAFT_VERSION=$($tc.Version) -e SERVER_MEMORY=1024 $Image bash -c 'bash /install.sh && test -f $($tc.File)'"
    
    $start = Get-Date
    Invoke-Expression $cmd
    $exitCode = $LASTEXITCODE
    $duration = ((Get-Date) - $start).TotalSeconds

    if ($exitCode -eq 0) {
        Write-Host "[PASS] $($tc.Desc) verified in $([math]::Round($duration, 1))s ($($tc.File) created)`n" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "[FAIL] $($tc.Desc) failed with exit code $exitCode`n" -ForegroundColor Red
        $failed++
    }
}

Write-Host "=== Test Summary ===" -ForegroundColor Yellow
Write-Host "Total: $($testCases.Count) | Passed: $passed | Failed: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })

if ($failed -gt 0) {
    exit 1
} else {
    Write-Host "`nALL LOADER AND VERSION CHECKS PASSED SUCCESSFULLY!" -ForegroundColor Green
}
