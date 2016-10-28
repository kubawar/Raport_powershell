#[CMDLetBinding()]
#Param(
#    [parameter(Mandatory=$true)][char]$opcja='a'
#)
write-host "Podaj odpowiedni parametr do raportowania: (u-uslugi,p-procesy,r-uprawnienia,s-security,w-wsus,a-wszystko)"
try{
[char]$opcja = Read-Host -ErrorAction Stop
}catch{
    Write-Host "Uruchom skrypt raz jeszcze i podaj prosze pojedyncza literke"
}
$maszyna = $env:COMPUTERNAME
$domena= $env:USERDOMAIN
$user = $env:USERNAME
$data = get-date -Format 'yyyyMMdd HH:mm:ss'
$data1 = get-date -Format 'yyyydM_HH_mm_ss'
$nazwapliku = $data1+"_"+$maszyna+".txt"
cmd /r secedit /export /cfg c:\sec.cfg
$seccfg = Get-Content C:\sec.cfg
#$seccfg = Import-Csv C:\sec.cfg -Delimiter '=' -Header name,value
Remove-Item C:\sec.cfg




$opcja_serwisy = $opcja_procesy = $opcja_security = $opcja_prawa = $opcja_wsus = $false

if($opcja -eq 'a'){
    $opcja_serwisy = $opcja_procesy = $opcja_security = $opcja_prawa = $opcja_wsus = $true
}elseif($opcja -eq 'u'){
    $opcja_serwisy = $true
}elseif($opcja -eq 's'){
    $opcja_security = $true
}elseif($opcja -eq 'p'){
    $opcja_procesy = $true
}elseif($opcja -eq 'r'){
    $opcja_prawa = $true
}elseif($opcja -eq 'w'){
    $opcja_wsus = $true
}else{
    write-host "Nie podano poprawnego parametru. Uruchom skrypt ponownie"
    exit
}

$wynik = "";
$wynik += "Data wykonania testu: $data`r`nWykonal: $domena\$user`r`nMaszyna: $maszyna`r`n"

if($opcja_serwisy){    
    $lista_serwisow = Get-Content -Path c:\srv.txt
    $wynik += "`r`nSerwisy:`r`n"
    foreach($s in $lista_serwisow){
        try{
            $serwis = Get-Service -Name $s -ErrorAction Stop
        }catch{
            $wynik += "Usluga $s nie istnieje`r`n"
        }
        if($serwis) {$wynik += "Usluga $s istnieje i ma status: $($serwis.Status)`r`n"}
    }
}

if($opcja_procesy){
    $lista_procesow = Get-Content -Path c:\proc.txt
    $wynik += "`r`nProcesy:`r`n"
    foreach($p in $lista_procesow){
        try{
            $proces = Get-Process -Name $p -ErrorAction Stop
        }catch{
            $wynik += "Proces $p nie istnieje`r`n"
            continue
        }    
        if($proces) {
            $proces_ile = $proces.count
            $wynik += "Proces $p jest uruchomiony w liczbie: $proces_ile`r`n"
        }
    }
}

if($opcja_security){
    $wynik += "`r`nSecurity settings:`r`n"

    $wynik += "Accounts: Administrator account status: "
    $adminstatus = $seccfg | Select-String -Pattern "EnableAdminAccount = 0"
    if($adminstatus -like "EnableAdminAccount = 0"){ $wynik += "PASS`r`n"}
    else{ $wynik += "FAIL`r`n"}
    $wynik += "Accounts: Rename Administrator account: "
    $adminname = $seccfg | Select-String -Pattern 'NewAdministratorName = "ADATUMAdmin"'
    if($adminname -like 'NewAdministratorName = "ADATUMAdmin"'){ $wynik += "PASS`r`n"}
    else{ $wynik += "FAIL`r`n"}

    $wynik += "Accounts: Rename Guest account: "
    $guestname = $seccfg | Select-String -Pattern 'NewGuestName = "ADATUMGuest"'
    if($guestname -like 'NewGuestName = "ADATUMGuest"'){ $wynik += "PASS`r`n"}
    else{ $wynik += "FAIL`r`n"}

}

if($opcja_prawa){
    $wynik += "`r`nUser Rights Assigment:`r`n"

    $wynik += "Take ownership of files or other objects: "
    $prawaowner = $seccfg | Select-String -Pattern 'SeTakeOwnershipPrivilege = \*S-1-5-32-544'
    if($prawaowner -like 'SeTakeOwnershipPrivilege = *S-1-5-32-544'){ $wynik += "PASS`r`n"}
    else{ $wynik += "FAIL`r`n"}
    $wynik += "Back up files and direcotries: "
    $prawaback = $seccfg | Select-String -Pattern 'SeBackupPrivilege = \*S-1-5-32-544'
    if($prawaback -like 'SeBackupPrivilege = *S-1-5-32-544'){ $wynik += "PASS`r`n"}
    else{ $wynik += "FAIL`r`n"}
    $wynik += "Shut down the system: "
    $prawashutdown = $seccfg | Select-String -Pattern 'SeRemoteShutdownPrivilege = \*S-1-5-32-544'
    if($prawashutdown -like 'SeRemoteShutdownPrivilege = *S-1-5-32-544'){ $wynik += "PASS`r`n"}
    else{ $wynik += "FAIL`r`n"}
}

if($opcja_wsus){
    $wynik += "`r`nWSUS Settings:`r`n"
    $wsus1 = Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    $wynik += "Configure automatic updating - 4 Auto download and chedule install: "
    if($wsus1.AUOptions -eq 4){ $wynik += "PASS`r`n"}
    else{ $wynik += "FAIL`r`n"}
    $wynik += "Scheduled Install Time: "
    if($wsus1.ScheduledInstallTime -eq 3){ $wynik += "PASS`r`n"}
    else{ $wynik += "FAIL`r`n"}
    $wsus2 = Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\
    $wynik += "Set the intranet update service for detecting updates: "
    if($wsus2.WUServer -like "http://test.pl:8530"){ $wynik += "PASS`r`n"}
    else{ $wynik += "FAIL`r`n"}
    $wynik += "Set the intranet statistc server: "
    if($wsus2.WUStatusServer -like "http://test.pl:8530"){ $wynik += "PASS`r`n"}
    else{ $wynik += "FAIL`r`n"}
}


$wynik | Out-File -PSPath "c:\$nazwapliku" -Force
$wynik += "`r`nSecurity Settings:`r`n"