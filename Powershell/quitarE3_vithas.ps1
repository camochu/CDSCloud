#V21.03.09

function Write-UsersLicence {
  Write-Output ""
  Write-Output "Usuarios y licencia asignada (E3 = $planName )"
  Write-Output "---------------------------------------------------"
#  ForEach ($user in (Get-Content -Path $fichero)) {
#      $userUPN=$user + $dominio
  ForEach ($userUPN in (Get-Content -Path $fichero)) {
      Write-host "$userUPN : " -NoNewline
      $userList = Get-AzureADUser -ObjectID $userUPN | Select -ExpandProperty AssignedLicenses | Select SkuID 
      
      $userList | ForEach { $sku=$_.SkuId ; $licensePlanList | ForEach { If ( $sku -eq $_.ObjectId.substring($_.ObjectId.length - 36, 36) ) { Write-Host $_.SkuPartNumber -NoNewline} } }
      Write-Output ""
  }
  Write-Output "---------------------------------------------------"
  Write-Output ""
}

if($azureConnection.Account -eq $null){
    $azureConnection = Connect-AzureAD
    if ($azureConnection -eq $null) {
      Write-Output "Conexión no establecida"
      Write-Output "Posible error de autenticación o bien no se encuentra el módulo AzureAD"
      Write-Output "Para el segundo caso, instalar desde un powershell abierto como administrador: Install-Module -Name AzureAD"
    }
}
if($azureConnection.Account -ne $null){
  Write-Output "Es necesario un fichero de texto con un usuario por linea (usuario@vithas.es/net)"
  $fichero = Read-Host -Prompt "Arrastra o introduce nombre del fichero (con su ruta si es necesario)"
#  $dominio= "@vithas.es"
  $planName="ENTERPRISEPACK" # licencia E3
  $licensePlanList = Get-AzureADSubscribedSku
  Write-UsersLicence
  $respuesta = Read-Host -Prompt "¿Quieres eliminar la licencia $planName de todos esos usuarios? (S/N)"
  if ($respuesta -eq "s") {
      $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
      $License.RemoveLicenses = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
#      ForEach ($user in (Get-Content -Path $fichero)) {
#          $userUPN=$user + $dominio
      ForEach ($userUPN in (Get-Content -Path $fichero)) {
          Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $license
      }
  }
  Write-UsersLicence
}
Read-Host -Prompt "Intro para finalizar"