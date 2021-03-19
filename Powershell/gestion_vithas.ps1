#V21.03.18
add-pssnapin microsoft.exchange.management.powershell.Snapin
$adm=$false
$banner_exchange="  ____             __          ______          _                            
 |  _ \           /_/         |  ____|        | |                           
 | |_) |_   _ _______  _ __   | |__  __  _____| |__   __ _ _ __   __ _  ___ 
 |  _ <| | | |_  / _ \| '_ \  |  __| \ \/ / __| '_ \ / _' | '_ \ / _' |/ _ \
 | |_) | |_| |/ / (_) | | | | | |____ >  < (__| | | | (_| | | | | (_| |  __/
 |____/ \__,_/___\___/|_| |_| |______/_/\_\___|_| |_|\__,_|_| |_|\__, |\___|
                                                                  __/ |     
                                                                 |___/      "
$banner_o365="  ____             __           ____ ____    __ _____ 
 |  _ \           /_/          / __ \___ \  / /| ____|
 | |_) |_   _ _______  _ __   | |  | |__) |/ /_| |__  
 |  _ <| | | |_  / _ \| '_ \  | |  | |__ <| '_ \___ \ 
 | |_) | |_| |/ / (_) | | | | | |__| |__) | (_) |__) |
 |____/ \__,_/___\___/|_| |_|  \____/____/ \___/____/ "
$banner_sinbuzon="   _____ _         _                __        
  / ____(_)       | |              /_/        
 | (___  _ _ __   | |__  _   _ _______  _ __  
  \___ \| | '_ \  | '_ \| | | |_  / _ \| '_ \ 
  ____) | | | | | | |_) | |_| |/ / (_) | | | |
 |_____/|_|_| |_| |_.__/ \__,_/___\___/|_| |_|"
$banner_sinAD="  _   _                   _     _                               _____  
 | \ | |                 (_)   | |                        /\   |  __ \ 
 |  \| | ___     _____  ___ ___| |_ ___    ___ _ __      /  \  | |  | |
 | . ' |/ _ \   / _ \ \/ / / __| __/ _ \  / _ \ '_ \    / /\ \ | |  | |
 | |\  | (_) | |  __/>  <| \__ \ ||  __/ |  __/ | | |  / ____ \| |__| |
 |_| \_|\___/   \___/_/\_\_|___/\__\___|  \___|_| |_| /_/    \_\_____/ "
do {
    cls
    $aliasAD = Read-Host -Prompt "Introduce el alias de AD (sin @vithas.es) o '?' para buscar"
    while ($aliasAD -eq "?") {
      $searchAD = Read-Host -Prompt "Introduce el texto a buscar en AD"
      Write-Host ""
      Get-ADUser -Filter "Name -like '*$searchAD*'" | Select-Object -Property SamAccountName, DistinguishedName | Sort-Object SamAccountName | Out-Host
      Write-Host ""
      $aliasAD = Read-Host -Prompt "Introduce alias (puedes seleccionar y copiar-pegar) o '?' para buscar"
    }
    $dominio= "@vithases.mail.onmicrosoft.com"
    $mailbox= $aliasAD + $dominio
    $ad_user=$null
    $buzon_o365=$null
    $buzon_exchange=$null
    $ad_user=Get-ADUser -Identity $aliasAD -erroraction 'silentlycontinue'
    $buzon_o365=Get-RemoteMailbox -Identity $aliasAD -erroraction 'silentlycontinue'
    $buzon_exchange=Get-Mailbox -Identity $aliasAD -erroraction 'silentlycontinue'
    do {
        cls
        Write-Host "Usuario: " -NoNewline
        if ($buzon_exchange) {
            Write-Host "$aliasAD - $buzon_exchange" -ForegroundColor yellow
            Write-Host $banner_exchange
        } elseif ($buzon_o365) {
            Write-Host "$aliasAD - $buzon_o365" -ForegroundColor yellow
            Write-Host $banner_o365
        } elseif ($ad_user) {
            Write-Host "$aliasAD" -ForegroundColor yellow
            Write-Host $banner_sinbuzon
        } else {
            Write-Host "$aliasAD" -ForegroundColor yellow
            Write-Host $banner_sinAD
        }
        if($accion -eq "M") { $adm = -not $adm }
        if ($buzon_exchange) {
            if ($accion -eq "1") {
  	            Get-Mailbox $aliasAD | fl database
            } elseif ($accion -eq "2" -and $adm) {
  	            New-MoveRequest $aliasAD -TargetDatabase bajasvithas -BadItemLimit 1000 -AcceptLargeDataLoss | Out-Host
            } elseif ($accion -eq "3" -and $adm) {
  	            Get-MoveRequestStatistics $aliasAD | ft -autosize | Out-Host
            }
        } elseif ($buzon_o365 -and $adm) {
            if ($accion -eq "1") {
                Disable-RemoteMailbox -Identity $aliasAD
                Start-Sleep -Seconds 3
                $buzon_o365=Get-RemoteMailbox -Identity $aliasAD -erroraction 'silentlycontinue'
                $accion="8"
                continue
            }
        } elseif ($ad_user -and (-not $buzon_o365) -and $adm) {
            if ($accion -eq "1") {
                Enable-RemoteMailbox -Identity $aliasAD -RemoteRoutingAddress $mailbox | Out-Host
                Write-Host "`nFin de la ejecución, en caso de detectar algun error escalar incidencia con el pantallazo "
                Start-Sleep -Seconds 3
                $buzon_o365=Get-RemoteMailbox -Identity $aliasAD -erroraction 'silentlycontinue'
                $accion="8"
                continue
            } elseif ($accion -eq "2") {
                $buzon_o365=Get-RemoteMailbox -Identity $aliasAD -erroraction 'silentlycontinue'
                $accion=""
                continue
            }
        }
        Write-Host " _______________________________"
        if ($adm) {
        Write-Host "/   Ordenes (" -NoNewline
        Write-Host "Administrador" -NoNewline -ForegroundColor red
        Write-Host ")     \" 
        } else {
        Write-Host "/     Ordenes (Consulta)        \"
        }
        Write-Host "|                               |"
        if ($buzon_exchange) {
        Write-Host "| 1 - Ver BBDD actual           |"
        if ($adm) {
        Write-Host "| 2 - Mover a bajas             |"
        Write-Host "| 3 - Ver progreso movimiento   |"
        }
        } elseif ($ad_user -and (-not $buzon_o365) -and $adm) {
        Write-Host "| 1 - Crear buzón O365          |"
        Write-Host "| 2 - Actualizar creación buzón |"
        } elseif ($buzon_o365 -and $adm) {
        Write-Host "| 1 - Eliminar buzón o365       |"
        }
        Write-Host "|                               |"
        Write-Host "| 0 - Buscar otro usuario       |"
        Write-Host "| M - Modo consulta/admin.      |"
        Write-Host "| S - Salir                     |"
        Write-Host "\_______________________________/"
        Write-Host ""
        if ($adm) { write-host "Por favor, introduce la orden: " -NoNewline -ForegroundColor red}
        else { write-host "Por favor, introduce la orden: " -NoNewline }
        $accion = Read-Host
    } while ($accion -ne "0" -and $accion -ne "S")
} while ($accion -ne "S")