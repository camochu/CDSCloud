import-module servermanager
add-pssnapin microsoft.exchange.management.powershell.Snapin
do {
  $aliasAD = Read-Host -Prompt "Por favor, introduce el alias de AD del usuario"
  $dominio= "@vithases.mail.onmicrosoft.com"
  $mailbox= $aliasAD + $dominio
  Try {
    Write-Output "Inicio de la ejecución"
    Enable-RemoteMailbox -Identity $aliasAD -RemoteRoutingAddress $mailbox -ea Continue
  }
  Catch{
    Write-Warning "`nSe ha producido un error en la ejecución, escalar incidencia con pantallazo del error"
    $_.exception.Message
  }
  Finally {
    Write-Output "`nFin de la ejecución, en caso de detectar algun error escalar incidencia con el pantallazo "
  }
  $repetir = read-host -Prompt "`n¿Repetir[Intro] o Finalizar[F]?"
} while ($repetir -ne "F")
