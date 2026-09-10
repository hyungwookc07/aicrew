# teamradio56 업데이트 스크립트 — 우클릭 → "PowerShell에서 실행"
#
# 하는 일: git pull → 플러그인 빌드 → SimHub 폴더에 DLL 복사.
# SimHub 설치 경로가 기본과 다르면:  .\update.ps1 -SimHubPath "D:\SimHub"
param(
    [string]$SimHubPath = "C:\Program Files (x86)\SimHub"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Fail($msg) {
    Write-Host ""
    Write-Host "❌ $msg" -ForegroundColor Red
    Read-Host "Enter를 누르면 닫힙니다"
    exit 1
}

if (-not (Test-Path (Join-Path $SimHubPath "SimHub.Plugins.dll"))) {
    Fail "SimHub을 찾을 수 없습니다: $SimHubPath  (다른 경로면 -SimHubPath 로 지정)"
}

Write-Host "▶ git pull" -ForegroundColor Cyan
git pull
if ($LASTEXITCODE -ne 0) { Fail "git pull 실패 — 위 메시지를 확인하세요" }

Write-Host "▶ 빌드" -ForegroundColor Cyan
dotnet build simhub -c Release -p:SimHubPath="$SimHubPath" -v m --nologo
if ($LASTEXITCODE -ne 0) { Fail "빌드 실패 — 위 에러를 알려주세요" }

# SimHub이 떠 있으면 DLL이 잠겨 복사가 실패한다
$simhubProc = Get-Process -Name "SimHubWPF" -ErrorAction SilentlyContinue
if ($simhubProc) {
    Write-Host ""
    Write-Host "SimHub이 실행 중입니다 — 종료한 뒤 Enter를 누르세요." -ForegroundColor Yellow
    Read-Host
}

Write-Host "▶ DLL 복사 → $SimHubPath" -ForegroundColor Cyan
Copy-Item "simhub\src\TeamRadio56.SimHub\bin\Release\net48\TeamRadio56.*.dll" `
          $SimHubPath -Force

Write-Host ""
Write-Host "✅ 업데이트 완료 — SimHub을 시작하면 새 버전이 적용됩니다." -ForegroundColor Green
Read-Host "Enter를 누르면 닫힙니다"
