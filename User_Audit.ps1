param(
    [int]$Days = 10,
    [string]$Path = "Chemin\Vers\Votre\Fichier.csv"
)

if (-not (Test-Path $Path)) {
    Write-Error "Fichier introuvable: $Path"
    exit 1
}

$csv = Import-Csv -Path $Path
$total = $csv.Count
$cutoff = (Get-Date).AddDays(-$Days)

$filtered = $csv | Where-Object {
    $enabled = $_.Enabled -eq "True"
    $dt = $null
    if ($_.LastLogonDate) {
        try {
            $dt = [datetime]::Parse($_.LastLogonDate.ToString())
        } catch {
            $dt = $null
        }
    }
    $enabled -and $dt -and ($dt -lt $cutoff)
}

$filtered | Select-Object DisplayName,SamAccountName,Department,Enabled,LastLogonDate |
    Export-Csv -Path "Inactive_ActiveUsers.csv" -NoTypeInformation -Encoding UTF8

$affected = $filtered.Count
$departments = $filtered | ForEach-Object { $_.Department } | Where-Object { $_ } | Sort-Object -Unique
$deptList = if ($departments) { $departments -join ", " } else { "Aucun" }

Write-Output "Total users: $total"
Write-Output "Active but inactive > $Days days: $affected"
Write-Output "Departments concerned: $deptList"
