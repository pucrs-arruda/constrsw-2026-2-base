<#
.SYNOPSIS
  Roda todos os testes da API oauth e limpa tudo no final.

.DESCRIPTION
  1. Testes isolados (unitarios, integracao MockMvc, contrato com Keycloak simulado)
  2. Sobe/reconstroi a stack (docker compose up -d --build) e espera ficar healthy
  3. Teste fim a fim contra a API e o Keycloak reais (dados de teste sao excluidos pelo proprio teste)
  4. Limpeza: remove backend/oauth/target e, se a stack nao estava no ar antes, docker compose down

  Nao precisa de Maven/Java na maquina: os testes rodam no container maven:3.9-eclipse-temurin-21.

.PARAMETER KeepStack
  Nao derruba a stack no final, mesmo que ela tenha sido iniciada pelo script.

.EXAMPLE
  .\scripts\run-all-tests.ps1
  .\scripts\run-all-tests.ps1 -KeepStack
#>
param(
    [switch]$KeepStack
)

# 'Continue' (e nao 'Stop'): no Windows PowerShell 5.1, stderr de comandos nativos
# (docker) vira erro terminante com 'Stop'. Exit codes sao conferidos via $LASTEXITCODE.
$ErrorActionPreference = 'Continue'

$Root = Split-Path -Parent $PSScriptRoot
$OAuthDir = Join-Path $Root 'backend\oauth'
$EnvFile = Join-Path $Root '.env'
$MavenImage = 'maven:3.9-eclipse-temurin-21'
$M2Cache = Join-Path $env:USERPROFILE '.m2'

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

function Get-EnvValue($name, $default) {
    $line = Get-Content $EnvFile | Where-Object { $_ -match "^$name=" } | Select-Object -First 1
    if ($line) { return ($line -split '=', 2)[1].Trim() }
    return $default
}

function Get-Health($container) {
    $status = docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' $container 2>$null
    if ($LASTEXITCODE -ne 0) { return 'missing' }
    return $status
}

function Wait-Healthy($containers, $timeoutSec) {
    $deadline = (Get-Date).AddSeconds($timeoutSec)
    foreach ($c in $containers) {
        while ((Get-Health $c) -ne 'healthy') {
            if ((Get-Date) -gt $deadline) { throw "Timeout esperando '$c' ficar healthy (status: $(Get-Health $c))" }
            Start-Sleep -Seconds 3
        }
        Write-Host "    $c healthy"
    }
}

# Roda Maven num container descartavel e apaga target/ ao final, preservando o exit code.
function Invoke-Maven($mavenArgs, $dockerArgs) {
    $cmd = "mvn -B $mavenArgs; rc=`$?; rm -rf target; exit `$rc"
    $allArgs = @('run', '--rm') + $dockerArgs + @(
        '-v', "${OAuthDir}:/app",
        '-v', "${M2Cache}:/root/.m2",
        '-w', '/app',
        $MavenImage, 'sh', '-c', $cmd)
    & docker @allArgs | Out-Host
    return $LASTEXITCODE
}

$results = [ordered]@{}
$stackWasUp = (Get-Health 'oauth') -eq 'healthy'

try {
    Write-Step 'Testes isolados (unitarios + integracao + contrato)'
    $results['Testes isolados'] = Invoke-Maven 'test' @()

    Write-Step 'Subindo a stack com o codigo atual (docker compose up -d --build)'
    Push-Location $Root
    try {
        docker compose up -d --build
        if ($LASTEXITCODE -ne 0) { throw 'docker compose up falhou' }
    } finally { Pop-Location }
    Wait-Healthy @('keycloak', 'oauth') 240

    Write-Step 'Teste fim a fim (API + Keycloak reais)'
    $network = docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' oauth
    $apiPort = Get-EnvValue 'OAUTH_INTERNAL_API_PORT' '3001'
    $kcPort = Get-EnvValue 'KEYCLOAK_INTERNAL_API_PORT' '8080'
    $results['Teste fim a fim'] = Invoke-Maven 'test -Pe2e' @(
        '--network', $network,
        '-e', "E2E_BASE_URL=http://oauth:$apiPort",
        '-e', "E2E_KEYCLOAK_URL=http://keycloak:$kcPort",
        '-e', "KEYCLOAK_REALM=$(Get-EnvValue 'KEYCLOAK_REALM' 'constrsw')",
        '-e', "KEYCLOAK_ADMIN=$(Get-EnvValue 'KEYCLOAK_ADMIN' 'admin')",
        '-e', "KEYCLOAK_ADMIN_PASSWORD=$(Get-EnvValue 'KEYCLOAK_ADMIN_PASSWORD' 'a12345678')")
}
catch {
    Write-Host "`nERRO: $_" -ForegroundColor Red
    $results['Execucao do script'] = 1
}
finally {
    Write-Step 'Limpeza'
    $target = Join-Path $OAuthDir 'target'
    if (Test-Path $target) { Remove-Item -Recurse -Force $target }
    Write-Host '    backend/oauth/target removido'
    Write-Host '    usuarios/roles de teste (e2e-*) excluidos do Keycloak pelo proprio teste'

    if ($stackWasUp -or $KeepStack) {
        Write-Host '    stack mantida no ar'
    } else {
        Push-Location $Root
        try { docker compose down } finally { Pop-Location }
        Write-Host '    stack derrubada (docker compose down)'
    }
}

Write-Step 'Resumo'
$failed = $false
foreach ($name in $results.Keys) {
    if ($results[$name] -eq 0) {
        Write-Host ("    [OK]    {0}" -f $name) -ForegroundColor Green
    } else {
        Write-Host ("    [FALHA] {0}" -f $name) -ForegroundColor Red
        $failed = $true
    }
}
if ($failed) { exit 1 } else { exit 0 }
