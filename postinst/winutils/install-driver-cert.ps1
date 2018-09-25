#### INSTALL DRIVER AND CERT
#### install-driver.ps1

# Define the Cert folder to import
$folderPath = "c:\Windows\INF\driverpack"

# Define variable
$DebugPreference = "Continue"
#$DebugPreference = "SilentlyContinue"

Write-Host "####################################"
Write-Host "#### List of certificate added #####"
Write-Host "####################################"


Get-ChildItem $folderPath -Recurse -Filter "*.cer" |
ForEach-Object {

    # Target the Cert
    $CertToImport = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $_.FullName

    # Define the scope 
    $CertStoreScope = "LocalMachine"
    # Define the store 
    $CertStoreName = "TrustedPublisher"
    $CertStore = New-Object System.Security.Cryptography.X509Certificates.X509Store $CertStoreName, $CertStoreScope

    # Import
    $CertStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $CertStore.Add($CertToImport)
    $CertStore.Close()
    Write-Host ("# " + $_.FullName)
}

Write-Host "############################################"
Write-Host "#### List of driver added to the store #####"
Write-Host "############################################"

Get-ChildItem $folderPath -Recurse -Filter "*.inf" |
ForEach-Object {
    pnputil.exe /add-driver $_.FullName /install
    Write-Debug ("$folderPath\" + $_.FullName)
}
