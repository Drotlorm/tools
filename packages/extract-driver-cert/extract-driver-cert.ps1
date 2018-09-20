#### EXTRACT DRIVERS AND CERTIFICATE SCRPIT

# DEFINE PULSE SERVER IP
Set-Variable -Name "SERVER_ADDRESS" -Value ""

# DEFINE EXTRACT METHOD
Set-Variable -Name "EXTRACT_METHOD" -Value ""

# Define variable
#$DebugPreference = "Continue"
$DebugPreference = "SilentlyContinue"
Set-Variable -Name "PASSWORD" -Value "s3cr3t"
Set-Variable -Name "USER" -Value "driver"
Set-Variable -Name "SHARE" -Value "\\$SERVER_ADDRESS\drivers"

Write-Debug "SERVER_ADDRESS : $SERVER_ADDRESS" 
Write-Debug "PASSWORD : $PASSWORD"

# Check if $SERVER_ADDRESS is full filled
if ([string]::IsNullOrEmpty($SERVER_ADDRESS)) {
    Write-Host "#####################################################"
    Write-Host "### Extract driver and certificate script need Pulse ip"
    Write-Host "### Pass as script argument the Pulse ip addresse with -SERVER_ADDRESS 192.168.1.1"
    Write-Host ""
    exit 1
}

# Check if $EXTRACT_METHOD is filled
if ([string]::IsNullOrEmpty($EXTRACT_METHOD)) {
    Write-Host "#####################################################"
    Write-Host "### Extract driver and certificate script use by default ddc"
    Write-Host "### (ddc.exe is Double Driver software)"
    Write-Host "### To use Windows pnputil.exe"
    Write-Host "### Pass as script argument -EXTRACT_METHOD pnp"
    Write-Host ""
}

# Grant acces 
Enable-WSManCredSSP  -Role "Client" -DelegateComputer $SERVER_ADDRESS -force  | Out-Null

Write-Debug "Share path : $SHARE"

# Get the list of drive letter used or reserved
$DRIVE_LIST=(Get-PSDrive -PSProvider filesystem).Name 
Write-Debug "Drive list in used : $DRIVE_LIST"

# Create credential object
$userPassword = ConvertTo-SecureString -String $PASSWORD -AsPlainText -Force
$credential= New-Object System.Management.Automation.PSCredential("drivers", $userPassword)

# Find first free drive letter
Foreach ($DRIVE_LETTER in "ZYXWVUTSRQPONMLKJIHGFED".ToCharArray()) { 
    If ($DRIVE_LIST -notcontains $DRIVE_LETTER) { 
        Write-Debug "Drive letter will be used : $DRIVE_LETTER"
        
        # Mount Pulse driver folder on the drive
        New-PSDrive -Name $DRIVE_LETTER -PSProvider filesystem  -Root $SHARE -Persist -Scope Global -Credential $credential 
        break
    } 
} 

# Determine Windows OS
$SHORT_OS = (Get-WmiObject Win32_OperatingSystem).name -split ' '
$WINDOWS_FOLDER=$SHORT_OS[1] + $SHORT_OS[2]
Write-Debug "Windows OS used as folder : $WINDOWS_FOLDER"

# Get computer properties
$computerSystem = (Get-WmiObject -Class:Win32_ComputerSystem)

# Determine computer manufacturer
$MANUF = ($computerSystem.Manufacturer -replace " ","_") 
$MANUF  -replace ".",""
Write-Debug "Manufacturer : $MANUF"

# Determine computer manufacturer
$MODEL = ($computerSystem.Model -replace " ","_") 
Write-Debug "Model : $MODEL"

# Deternime base path for export
$BASE_PATH = $DRIVE_LETTER + ":" + "\" + $WINDOWS_FOLDER + "\" + $MANUF + "\" + $MODEL
Write-Debug "Base path : $BASE_PATH"

# Deternime base path for export
$DRIVER_PATH = $BASE_PATH + "\DRIVERS"
Write-Debug "Driver path : $DRIVER_PATH"

# Create directory structure for driver export
New-Item -Path $DRIVER_PATH -ItemType directory -Force | Out-Null

# Deternime extraction method
If ($EXTRACT_METHOD -eq "pnp") {

  & "c:\Windows\System32\pnputil.exe" /export-driver * $DRIVER_PATH | Out-Null

  }  Else {

  & ".\ddc.exe" b /target:$DRIVER_PATH 2>&1 | Out-Null

} 

#### EXTRACT CERTIFICAT

# Deternime base path for export
$CERT_PATH = $BASE_PATH + "\CERTS\"
Write-Debug "Certificate path : $CERT_PATH"

# Create directory structure for certificate export
New-Item -Path $CERT_PATH -ItemType directory -Force | Out-Null

# Find all Cert thumbprint
$CertToExport  = (Get-ChildItem -Path Cert:\LocalMachine\TrustedPublisher | Where-Object {$_.Subject -like "*"}).Thumbprint

# For in list of Cert Thumbprint 
foreach($CertToExport in $CertToExport)
{
    # Get the Name of the Cert
    $CertName = (Get-ChildItem -Path Cert:\LocalMachine\TrustedPublisher | Where-Object {$_.Thumbprint -eq "$CertToExport"}).DnsNameList.Punycode  
    # Get the Cert object
    $CertToExport = dir cert:\LocalMachine\TrustedPublisher | where {$_.ThumbPrint -eq "$CertToExport"}    
    # Export the Cert In Bytes For The CER format   
    $CertToExportInBytesForCERFile = $CertToExport.export("Cert")
    # Deternime certificate path and name for export
    $CERT_PATH_NAME = $CERT_PATH + $CertName + ".cer"
    Write-Debug "Certificat path to export : $CERT_PATH_NAME"
    # Write The Files Based Upon The Exported Bytes
    [system.IO.file]::WriteAllBytes($CERT_PATH_NAME, $CertToExportInBytesForCERFile)
}

Write-Host "#################################################"
Write-Host "OS : $WINDOWS_FOLDER"
Write-Host "Manufacturer : $MANUF"
Write-Host "Model : $MODEL"
Write-Host "#################################################"
Write-Host ""
Write-Host "#################################################"
Write-Host "List all drivers and certificat Trusted Publisher"
Write-Host "#################################################"
Write-Host ""

tree /F $DRIVE_LETTER":"\$WINDOWS_FOLDER\$MANUF\$MODEL

Get-PSDrive $DRIVE_LETTER |Remove-PSDrive
