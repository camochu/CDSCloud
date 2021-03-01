#import-module servermanager
add-pssnapin microsoft.exchange.management.powershell.Snapin
do {
  cls
  $aliasAD = Read-Host -Prompt "Por favor, introduce el alias de AD del usuario"
  do {
#    if (($accion -ge "1") -and ($accion -le "3")) {
      cls
      Write-Output "Buzón de: $aliasAD"
      Write-Output "*********************************"
      write-output ""
      if ($accion -eq "1") {
#      Write-Output "Buscando ..."
	  Get-Mailbox $aliasAD | fl database
      } elseif ($accion -eq "2") {
	  New-MoveRequest $aliasAD -TargetDatabase bajasvithas -BadItemLimit 1000 -AcceptLargeDataLoss
      } elseif ($accion -eq "3") {
	  Get-MoveRequestStatistics $aliasAD | ft -autosize
      }
      write-output " _______________________________"
      Write-Output "/           Ordenes             \"
      Write-Output "|                               |"
      Write-Output "| 1 - Ver BBDD actual           |"
      Write-Output "| 2 - Mover a bajas             |"
      Write-Output "| 3 - Ver progreso movimiento   |"
      Write-Output "|                               |"
      Write-Output "| 9 - Repetir para otro usuario |"
      Write-Output "| 0 - Salir                     |"
      Write-Output "\_______________________________/"
      Write-Output ""
      $accion = Read-Host -Prompt "Por favor, introduce la orden"
#    }
  } while (($accion -ne "9") -and ($accion -ne "0"))
} while ($accion -ne "0")
