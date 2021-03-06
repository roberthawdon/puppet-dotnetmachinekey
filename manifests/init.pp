class dotnetmachinekey (
  $environment    = $dotnetmachinekey::params::environment,
  $tempdir        = $dotnetmachinekey::params::tempdir,
  $powershellexe  = $dotnetmachinekey::params::powershellexe,
  $readwrite      = $dotnetmachinekey::params::readwrite,
  $validationkey  = $dotnetmachinekey::params::validationkey,
  $decryptionkey  = $dotnetmachinekey::params::decryptionkey,
  $validation     = $dotnetmachinekey::params::validation,
  $removewebkey   = $dotnetmachinekey::params::removewebkey,
  ) inherits dotnetmachinekey::params {
  
      if ($osfamily == 'windows') and ($decryptionkey != undef) {

            file { 'machineKeys.ps1':
                  path    => "$tempdir/machineKeys.ps1",
                  ensure  => "file",
                  content => template('dotnetmachinekey/machineKeys.ps1'),
                  notify  => Exec['setmachinekey']
            }

            exec { 'setmachinekey':
                  refreshonly => true,
                  command     => "start-process -verb runas $powershellexe -argumentlist '-file ${tempdir}/machineKeys.ps1'",
                  provider    => "powershell"
            }
      }

      if ($osfamily == 'windows') and ($removewebkey == 'true') {

            file { 'removeWebKeys.ps1':
                  path    => "$tempdir/removeWebKeys.ps1",
                  ensure  => "file",
                  content => template('dotnetmachinekey/removeWebKeys.ps1'),
                  notify  => Exec['removewebkey']
            }

            exec { 'removewebkey':
                  refreshonly => true,
                  command     => "start-process -verb runas $powershellexe -argumentlist '-file ${tempdir}/removeWebKeys.ps1'",
                  provider    => "powershell"
            }
      }
}
