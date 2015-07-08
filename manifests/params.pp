class dotnetmachinekey::params () {
  $environment    = $::environment
  $powershellexe  = 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'
  $readwrite      = "write"
  $validationkey  = undef
  $decryptionkey  = undef
  $validation     = "HMACSHA256"
}

