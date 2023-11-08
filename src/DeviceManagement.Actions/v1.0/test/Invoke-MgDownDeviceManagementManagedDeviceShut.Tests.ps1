if(($null -eq $TestName) -or ($TestName -contains 'Invoke-MgDownDeviceManagementManagedDeviceShut'))
{
  $loadEnvPath = Join-Path $PSScriptRoot 'loadEnv.ps1'
  if (-Not (Test-Path -Path $loadEnvPath)) {
      $loadEnvPath = Join-Path $PSScriptRoot '..\loadEnv.ps1'
  }
  . ($loadEnvPath)
  $TestRecordingFile = Join-Path $PSScriptRoot 'Invoke-MgDownDeviceManagementManagedDeviceShut.Recording.json'
  $currentPath = $PSScriptRoot
  while(-not $mockingPath) {
      $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include 'HttpPipelineMocking.ps1' -File
      $currentPath = Split-Path -Path $currentPath -Parent
  }
  . ($mockingPath | Select-Object -First 1).FullName
}

Describe 'Invoke-MgDownDeviceManagementManagedDeviceShut' {
    It 'Down' -skip {
        { throw [System.NotImplementedException] } | Should -Not -Throw
    }

    It 'DownViaIdentity' -skip {
        { throw [System.NotImplementedException] } | Should -Not -Throw
    }
}
