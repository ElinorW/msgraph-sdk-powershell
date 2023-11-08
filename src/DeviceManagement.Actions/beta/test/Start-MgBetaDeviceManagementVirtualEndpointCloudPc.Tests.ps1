if(($null -eq $TestName) -or ($TestName -contains 'Start-MgBetaDeviceManagementVirtualEndpointCloudPc'))
{
  $loadEnvPath = Join-Path $PSScriptRoot 'loadEnv.ps1'
  if (-Not (Test-Path -Path $loadEnvPath)) {
      $loadEnvPath = Join-Path $PSScriptRoot '..\loadEnv.ps1'
  }
  . ($loadEnvPath)
  $TestRecordingFile = Join-Path $PSScriptRoot 'Start-MgBetaDeviceManagementVirtualEndpointCloudPc.Recording.json'
  $currentPath = $PSScriptRoot
  while(-not $mockingPath) {
      $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include 'HttpPipelineMocking.ps1' -File
      $currentPath = Split-Path -Path $currentPath -Parent
  }
  . ($mockingPath | Select-Object -First 1).FullName
}

Describe 'Start-MgBetaDeviceManagementVirtualEndpointCloudPc' {
    It 'PowerOn' -skip {
        { throw [System.NotImplementedException] } | Should -Not -Throw
    }

    It 'Start' -skip {
        { throw [System.NotImplementedException] } | Should -Not -Throw
    }

    It 'StartViaIdentity' -skip {
        { throw [System.NotImplementedException] } | Should -Not -Throw
    }

    It 'PowerOnViaIdentity' -skip {
        { throw [System.NotImplementedException] } | Should -Not -Throw
    }
}
