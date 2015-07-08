class dotnetmachinekey (
  $environment    = $dotnetmachinekey::params::environment,
  $powershellexe  = $dotnetmachinekey::params::powershellexe,
  $readwrite      = $dotnetmachinekey::params::readwrite,
  $validationkey  = $dotnetmachinekey::params::validationkey,
  $decryptionkey  = $dotnetmachinekey::params::decryptionkey,
  $validation     = $dotnetmachinekey::params::validation,
  ) inherits dotnetmachinekey::params {
  
      if ($osfamily == 'windows') and ($decryptionkey != undef) {
        exec { 'setmachinekey':
          command   => template('dotnetmachinekey/machineKeys.ps1'),
          provider  => powershell,
          logoutput => true,
          }
      }
}
