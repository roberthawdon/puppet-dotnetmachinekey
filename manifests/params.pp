class dotnetmachinekey::params () {
  $environment    = $::environment
  $tempdir        = 'C:/Temp'
  $powershellexe  = 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'
  $readwrite      = "write"
  $validationkey  = undef
  $decryptionkey  = undef
  $validation     = "HMACSHA256"
  $removewebkey   = "true"
}

