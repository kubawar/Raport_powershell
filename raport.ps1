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
}

if($opcja_prawa){
    
    $wynik += "`r`nUser Rights Assigment:`r`n"
}

if($opcja_wsus){
    
    $wynik += "`r`nWSUS Settings:`r`n"
}


$wynik | Out-File -PSPath "c:\$nazwapliku" -Force
$wynik += "`r`nSecurity Settings:`r`n"