#V21.03.26
add-pssnapin microsoft.exchange.management.powershell.Snapin
$adm=$false
$dominio= "@vithases.mail.onmicrosoft.com"
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
# funcion para registrar logs
function Write-Log {
  Param ([string]$logData)
  $logLine = Get-Date -Format "dd/MM/yyyy HH:mm "
  $logLine += $aliasAD + "  -  " + $logData
  Add-content $logfile -value $logLine
}
# crear carpeta para logs si no existe
$logFolder = $env:USERPROFILE + "\Gestion_Vithas_logs"
if (-not(Test-Path -Path $logFolder)) {
  New-Item -ItemType Directory -Path $logFolder
}
do {
# crear fichero de log si no existe
    $date = Get-Date -Format "yyyyMMdd"
    $logFile = $logFolder + "\Gestion_Vithas_" + $date + ".log"
    if (-not(Test-Path -Path $logFile)) {
      New-Item -ItemType File -Path $logFile
    }
    cls
# solicita userid (permite realizar búsquedas)
    $aliasAD = Read-Host -Prompt "Introduce el alias de AD (sin @vithas.es) o '?' para buscar"
    while ($aliasAD[0] -eq "?") {
      if ($aliasAD.Length -gt 1) { $searchAD=$aliasAD.TrimStart("?") }
      else { $searchAD = Read-Host -Prompt "Introduce el texto a buscar en AD" }
      Write-Host ""
      Get-ADUser -Filter "Name -like '*$searchAD*'" | Select-Object -Property SamAccountName, DistinguishedName | Sort-Object SamAccountName | Out-Host
      Write-Host ""
      $aliasAD = Read-Host -Prompt "Introduce alias (puedes seleccionar y copiar-pegar) o '?' para buscar"
    }
# Inicializa variables y busca información del usuario	
    $mailbox= $aliasAD + $dominio
    $ad_user=$null
    $buzon_o365=$null
    $buzon_exchange=$null
    $buzon_o365=Get-RemoteMailbox -Identity $aliasAD -erroraction 'silentlycontinue'	# si no vacio = buzón en o365
    $buzon_exchange=Get-Mailbox -Identity $aliasAD -erroraction 'silentlycontinue'	# si no vacio = buzón en exchange
    if ($aliasAD.Length -gt 20) { $aliasAD=$aliasAD.Substring(0,20) }
    $ad_user=Get-ADUser -Identity $aliasAD -erroraction 'silentlycontinue'	# si no vacio = existe en AD
    do {
        cls
# imprime usuario y banner
        Write-Host "Usuario: " -NoNewline
        if ($buzon_exchange) {
            Write-Host "$aliasAD - $buzon_exchange" -ForegroundColor yellow
            Write-Host $banner_exchange
        } elseif ($buzon_o365) {
            Write-Host "$aliasAD - $buzon_o365" -ForegroundColor yellow
            Write-Host $banner_o365
        } elseif ($ad_user) {
            $userName=$ad_user."Name"
            Write-Host "$aliasAD - $userName" -ForegroundColor yellow
            Write-Host $banner_sinbuzon
        } else {
            Write-Host "$aliasAD" -ForegroundColor yellow
            Write-Host $banner_sinAD
        }
# ejecuta acciones según opción elegida
        if($accion.Length -gt 1) {
            $aliasAD=$accion
            # Inicializa variables y busca información del usuario	
            $mailbox= $aliasAD + $dominio
            $ad_user=$null
            $buzon_o365=$null
            $buzon_exchange=$null
            $buzon_o365=Get-RemoteMailbox -Identity $aliasAD -erroraction 'silentlycontinue'	# si no vacio = buzón en o365
            $buzon_exchange=Get-Mailbox -Identity $aliasAD -erroraction 'silentlycontinue'	# si no vacio = buzón en exchange
            if ($aliasAD.Length -gt 20) { $aliasAD=$aliasAD.Substring(0,20) }
            $ad_user=Get-ADUser -Identity $aliasAD -properties EmailAddress -erroraction 'silentlycontinue'	# si no vacio = existe en AD
            $accion=""
            continue
        }elseif($accion -eq "M") {
            $adm = -not $adm
        }elseif($accion -eq "L") {
            notepad $logFile
        } elseif ($accion -eq "9") {
            Select-Object -InputObject $ad_user -Property Name,GivenName,Surname,SamAccountName,UserPrincipalName,Enabled,DistinguishedName,EmailAddress
            Write-Log "Busqueda de propiedades de AD"
        } elseif ($buzon_exchange) {
            if ($accion -eq "1") {
  	            Get-Mailbox $aliasAD | fl database
                Write-Log "Busqueda de BBDD de exchange"
            } elseif ($accion -eq "2" -and $adm) {
  	            New-MoveRequest $aliasAD -TargetDatabase bajasvithas -BadItemLimit 1000 -AcceptLargeDataLoss | Out-Host
                Write-Log "Movido a BBDD  de bajas de exchange"
            } elseif ($accion -eq "3" -and $adm) {
  	            Get-MoveRequestStatistics $aliasAD | ft -autosize | Out-Host
                Write-Log "Consuta estado movimiento BBDD de exchange"
            }
        } elseif ($buzon_o365 -and $adm) {
            if ($accion -eq "1") {
				Write-Host ""
                Write-Host "Esta opción elimina completamente el buzón en o365"
				Write-Host "No se debería utilizar salvo que el buzón aún no haya sido utilizado,"
				Write-Host "por ejemplo si se ha creado erroneamente el buzón"
				Write-Host ""
                $seguro = Read-Host -Prompt "¿Estás seguro de querer eliminar el buzón? ('SI' para confirmar)"
				if ($seguro -eq "SI") {
				    Disable-RemoteMailbox -Identity $aliasAD
                    Write-Log "Eliminado buzón o365"
				    Start-Sleep -Seconds 3
                    $buzon_o365=Get-RemoteMailbox -Identity $aliasAD -erroraction 'silentlycontinue'
                    $accion=""
                    continue
				} else {
					Write-Host "De acuerdo, buzón eliminado. Esta acción no se puede deshacer"
					Start-Sleep -Seconds 6
					Write-Host "Era broma ..."
				}
            }
        } elseif ($ad_user -and (-not $buzon_o365) -and $adm) {
            if ($accion -eq "1") {
                Enable-RemoteMailbox -Identity $aliasAD -RemoteRoutingAddress $mailbox | Out-Host
                Write-Log "Creado buzón o365"
                Write-Host "`nFin de la ejecución, usar opción 2 si no se actualiza la creación del buzón"
                Start-Sleep -Seconds 4
                $buzon_o365=Get-RemoteMailbox -Identity $aliasAD -erroraction 'silentlycontinue'
                $accion=""
                continue
            } elseif ($accion -eq "2") {
                $buzon_o365=Get-RemoteMailbox -Identity $aliasAD -erroraction 'silentlycontinue'
                $accion=""
                continue
            }
        }
# menu de opciones variable según el usuario y modo consulta/administrador
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
        if ($ad_user) {
				Write-Host "| 9 - Ver propiedades de AD     |"
        }
				Write-Host "|                               |"
				Write-Host "| 0 - Buscar otro usuario       |"
				Write-Host "| M - Modo consulta/admin.      |"
				Write-Host "| L - Consultar logs de hoy     |"
				Write-Host "| S - Salir                     |"
				Write-Host "\_______________________________/"
				Write-Host ""
# solicita opcion a ejecutar (en rojo para modo administrador)
        if ($adm) { write-host "Por favor, introduce la orden: " -NoNewline -ForegroundColor red}
        else { write-host "Por favor, introduce la orden: " -NoNewline }
        $accion = Read-Host
    } while ($accion -ne "0" -and $accion -ne "S") # repite hasta seleccionar buscar otro usuario o salir
} while ($accion -ne "S") # repite hasta selecionar salir