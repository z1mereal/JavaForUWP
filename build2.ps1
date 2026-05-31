$cert = Join-Path $certDir $ProjectConfig.CertificateFileName
$appx = Join-Path $outDir $ProjectConfig.AppxFileName
$certName = if ($env:APPX_CERT_SUBJECT) {
    $env:APPX_CERT_SUBJECT
} else {
    $ProjectConfig.DefaultCertificateSubject
}

function New-BuildCodeSigningCertificate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Subject,

        [Parameter(Mandatory = $true)]
        [string]$PfxPath,

        [Parameter(Mandatory = $true)]
        [string]$Password
    )

    Write-Host "Creating new code signing certificate: $Subject"

    $newCert = New-SelfSignedCertificate `
        -Type CodeSigningCert `
        -Subject $Subject `
        -KeyUsage DigitalSignature `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -TextExtension @(
            "2.5.29.37={text}1.3.6.1.5.5.7.3.3",
            "2.5.29.19={text}"
        )

    Export-PfxCertificate `
        -Cert $newCert `
        -FilePath $PfxPath `
        -Password (ConvertTo-SecureString $Password -AsPlainText -Force) | Out-Null

    Write-Host "Generated cert file: $PfxPath"

    return $newCert
}

function Import-BuildCodeSigningCertificate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PfxPath,

        [Parameter(Mandatory = $true)]
        [string]$Password
    )

    if (-not (Test-Path $PfxPath)) {
        return $null
    }

    Write-Host "Importing existing PFX into CurrentUser\My: $PfxPath"

    $imported = Import-PfxCertificate `
        -FilePath $PfxPath `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -Password (ConvertTo-SecureString $Password -AsPlainText -Force)

    return $imported
}

function Get-BuildCodeSigningCertificates {
    Get-ChildItem Cert:\CurrentUser\My |
        Where-Object {
            $_.HasPrivateKey -and
            ($_.EnhancedKeyUsageList | Where-Object {
                $_.FriendlyName -eq "Code Signing" -or
                $_.ObjectId -eq "1.3.6.1.5.5.7.3.3"
            })
        }
}

# Ensure there is at least one usable signing certificate in CurrentUser\My.
if (-not (Test-Path $cert)) {
    $createdCert = New-BuildCodeSigningCertificate `
        -Subject $certName `
        -PfxPath $cert `
        -Password $ProjectConfig.CertificatePassword
}
else {
    Write-Host "Found existing cert file: $cert"

    $matchingStoreCert = Get-BuildCodeSigningCertificates |
        Where-Object { $_.Subject -eq $certName } |
        Sort-Object NotBefore -Descending |
        Select-Object -First 1

    if (-not $matchingStoreCert) {
        $importedCert = Import-BuildCodeSigningCertificate `
            -PfxPath $cert `
            -Password $ProjectConfig.CertificatePassword
    }
}

$allSigningCertCandidates = @(Get-BuildCodeSigningCertificates)

if (-not $allSigningCertCandidates -or $allSigningCertCandidates.Count -eq 0) {
    Write-Warning "No usable Code Signing certificate found in CurrentUser\My. Creating a fresh one."

    $createdCert = New-BuildCodeSigningCertificate `
        -Subject $certName `
        -PfxPath $cert `
        -Password $ProjectConfig.CertificatePassword

    $allSigningCertCandidates = @($createdCert)
}

$banditVaultSigningCertCandidates = @(
    $allSigningCertCandidates |
        Where-Object { $_.Subject -like "*BanditVault*" } |
        Sort-Object NotBefore -Descending
)

$matchingSubjectSigningCertCandidates = @(
    $allSigningCertCandidates |
        Where-Object { $_.Subject -eq $certName } |
        Sort-Object NotBefore -Descending
)

$otherSigningCertCandidates = @(
    $allSigningCertCandidates |
        Where-Object {
            $_.Subject -notlike "*BanditVault*" -and
            $_.Subject -ne $certName
        } |
        Sort-Object NotBefore -Descending
)

$signingCertCandidates = @($banditVaultSigningCertCandidates) +
    @($matchingSubjectSigningCertCandidates) +
    @($otherSigningCertCandidates)

# Remove duplicates by thumbprint while preserving priority order.
$seenThumbprints = @{}
$signingCertCandidates = @(
    $signingCertCandidates |
        Where-Object {
            if (-not $_) {
                return $false
            }

            if ($seenThumbprints.ContainsKey($_.Thumbprint)) {
                return $false
            }

            $seenThumbprints[$_.Thumbprint] = $true
            return $true
        }
)

if (-not $signingCertCandidates -or $signingCertCandidates.Count -eq 0) {
    throw "Signing certificate not found in the current user certificate store, and automatic certificate creation/import failed."
}

Write-Host "Signing certificate candidates:"
foreach ($candidate in $signingCertCandidates) {
    Write-Host "  $($candidate.Subject) [$($candidate.Thumbprint)]"
}