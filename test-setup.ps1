# Supabaseサービスのクリーンインストールテストスクリプト

Write-Host "=== Supabase Clean Install Test ===" -ForegroundColor Cyan
Write-Host ""

# 1. 既存のコンテナを停止して削除
Write-Host "1. Stopping and removing existing containers..." -ForegroundColor Yellow
docker-compose down -v
Write-Host "   Done!" -ForegroundColor Green
Write-Host ""

# 2. データベースボリュームをクリーンアップ
Write-Host "2. Cleaning up database volumes..." -ForegroundColor Yellow
if (Test-Path ".\volumes\db\data") {
    Remove-Item -Recurse -Force ".\volumes\db\data\*" -ErrorAction SilentlyContinue
    Write-Host "   Database volume cleaned!" -ForegroundColor Green
} else {
    Write-Host "   No existing data volume found." -ForegroundColor Gray
}
Write-Host ""

# 3. .envファイルの存在確認
Write-Host "3. Checking .env file..." -ForegroundColor Yellow
if (Test-Path ".\.env") {
    Write-Host "   .env file exists!" -ForegroundColor Green
    
    # POSTGRES_PASSWORDの確認
    $envContent = Get-Content ".\.env" -Raw
    if ($envContent -match "POSTGRES_PASSWORD=(.+)") {
        $password = $matches[1].Trim()
        if ($password -eq "your-super-secret-and-long-postgres-password") {
            Write-Host "   WARNING: Please change POSTGRES_PASSWORD in .env file before production use!" -ForegroundColor Red
        } else {
            Write-Host "   POSTGRES_PASSWORD is set." -ForegroundColor Green
        }
    }
} else {
    Write-Host "   ERROR: .env file not found!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 4. コンテナを起動
Write-Host "4. Starting containers..." -ForegroundColor Yellow
docker-compose up -d
Write-Host "   Containers started!" -ForegroundColor Green
Write-Host ""

# 5. データベースの起動を待機
Write-Host "5. Waiting for database to be healthy..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$healthy = $false

while ($attempt -lt $maxAttempts -and -not $healthy) {
    $attempt++
    Start-Sleep -Seconds 2
    
    $dbStatus = docker inspect --format='{{.State.Health.Status}}' supabase-db 2>$null
    if ($dbStatus -eq "healthy") {
        $healthy = $true
        Write-Host "   Database is healthy!" -ForegroundColor Green
    } else {
        Write-Host "   Attempt $attempt/$maxAttempts - Status: $dbStatus" -ForegroundColor Gray
    }
}

if (-not $healthy) {
    Write-Host "   ERROR: Database did not become healthy in time!" -ForegroundColor Red
    Write-Host "   Check logs with: docker logs supabase-db" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# 6. すべてのサービスの状態を確認
Write-Host "6. Checking all services status..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

$services = @("supabase-db", "supabase-auth", "supabase-rest", "supabase-meta", "supabase-studio")
$allHealthy = $true

foreach ($service in $services) {
    $status = docker ps --filter "name=$service" --format "{{.Status}}"
    
    if ($status -match "Up" -and $status -notmatch "Restarting") {
        Write-Host "   ✓ $service : $status" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $service : $status" -ForegroundColor Red
        $allHealthy = $false
    }
}
Write-Host ""

# 7. 最終結果
if ($allHealthy) {
    Write-Host "=== SUCCESS ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "All services are running!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available services:" -ForegroundColor Cyan
    Write-Host "  - Supabase Studio: http://localhost:8081" -ForegroundColor White
    Write-Host "  - PostgREST API:   http://localhost:3000" -ForegroundColor White
    Write-Host "  - Supabase Auth:   http://localhost:9999" -ForegroundColor White
    Write-Host "  - Postgres Meta:   http://localhost:8080" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "=== WARNING ===" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Some services are not running properly." -ForegroundColor Yellow
    Write-Host "Check logs with: docker-compose logs" -ForegroundColor White
    Write-Host ""
    Write-Host "To check specific service:" -ForegroundColor White
    Write-Host "  docker logs supabase-auth" -ForegroundColor Gray
    Write-Host "  docker logs supabase-rest" -ForegroundColor Gray
    Write-Host ""
}

# 8. ログの確認を提案
Write-Host "To view all logs: docker-compose logs -f" -ForegroundColor Cyan
Write-Host "To stop services: docker-compose down" -ForegroundColor Cyan
