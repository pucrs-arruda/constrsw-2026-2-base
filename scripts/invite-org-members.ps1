<#
.SYNOPSIS
  Convida usuários para a organização GitHub pucrs-arruda.

.DESCRIPTION
  Usa a GitHub CLI (gh) para enviar convites via API:
  PUT /orgs/{org}/memberships/{username}

.PARAMETER Org
  Slug da organização. Default: pucrs-arruda

.PARAMETER Role
  Papel do convite: member (padrão) ou admin

.PARAMETER DryRun
  Apenas lista as ações sem enviar convites

.EXAMPLE
  .\scripts\invite-org-members.ps1
  .\scripts\invite-org-members.ps1 -DryRun
  .\scripts\invite-org-members.ps1 -Role member
#>

[CmdletBinding()]
param(
  [string]$Org = "pucrs-arruda",
  [ValidateSet("member", "admin")]
  [string]$Role = "member",
  [switch]$DryRun
)

$ErrorActionPreference = "Continue"

$usernames = @(
  "Ferngzz"
  "Luiz1405"
  "viniRsilva"
  "kirschzao"
  "Edu-Ferrari"
  "guilhermeghise"
  "sduartek"
  "polettiguilherme"
  "j-araju"
  "lucaslorenzipucrs"
  "PedroWidholzerr"
  "guioliszewski"
  "lucas-afonso8"
  "matheus-corbellini"
  "mellorafaa"
  "filipepereira03"
  "gabrielahf"
  "luanpaacheco"
  "AugustoKnob"
  "erickcarpes"
  "feliribeiro"
  "blakolukas"
  "GabrielHoppe"
  "julianochies"
  "leogemin"
  "Will-Klein"
  "AntonelliAA"
  "ArthurM-Maciel"
  "joaobiasoli"
  "lnss7"
)

function Test-GhAuth {
  $null = gh auth status 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Error "GitHub CLI não autenticada. Rode: gh auth login"
    exit 1
  }
}

function Invite-Member {
  param(
    [string]$Username,
    [string]$Organization,
    [string]$MemberRole
  )

  $result = gh api `
    --method PUT `
    "/orgs/$Organization/memberships/$Username" `
    -f "role=$MemberRole" `
    2>&1

  return @{
    ExitCode = $LASTEXITCODE
    Output   = ($result | Out-String).Trim()
  }
}

Test-GhAuth

Write-Host ""
Write-Host "Organização : $Org"
Write-Host "Papel       : $Role"
Write-Host "Total       : $($usernames.Count) usuários"
if ($DryRun) {
  Write-Host "Modo        : DRY-RUN (nenhum convite será enviado)"
}
Write-Host ""

$ok = 0
$skipped = 0
$failed = 0
$failures = @()

foreach ($user in $usernames) {
  if ($DryRun) {
    Write-Host "[DRY-RUN] Convidaria @$user como $Role"
    $ok++
    continue
  }

  Write-Host -NoNewline "Convidando @$user ... "

  $response = Invite-Member -Username $user -Organization $Org -MemberRole $Role

  if ($response.ExitCode -eq 0) {
    try {
      $json = $response.Output | ConvertFrom-Json
      $state = $json.state
      $role = $json.role
      Write-Host "OK (state=$state, role=$role)" -ForegroundColor Green
      $ok++
    }
    catch {
      Write-Host "OK" -ForegroundColor Green
      $ok++
    }
  }
  else {
    $msg = $response.Output
    if ($msg -match "already a member|already been invited|pending") {
      Write-Host "já é membro / convite pendente" -ForegroundColor Yellow
      $skipped++
    }
    else {
      Write-Host "FALHOU" -ForegroundColor Red
      Write-Host "  $msg" -ForegroundColor DarkRed
      $failed++
      $failures += [PSCustomObject]@{ User = $user; Error = $msg }
    }
  }

  # Evita rate limit agressivo
  Start-Sleep -Milliseconds 250
}

Write-Host ""
Write-Host "======== Resumo ========"
Write-Host "Sucesso / dry-run : $ok"
Write-Host "Já membro/pendente: $skipped"
Write-Host "Falhas            : $failed"

if ($failures.Count -gt 0) {
  Write-Host ""
  Write-Host "Detalhes das falhas:" -ForegroundColor Red
  $failures | Format-Table -AutoSize
  exit 1
}

exit 0
