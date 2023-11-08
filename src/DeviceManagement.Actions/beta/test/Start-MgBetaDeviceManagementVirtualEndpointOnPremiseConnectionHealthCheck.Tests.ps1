if(($null -eq $TestName) -or ($TestName -contains 'Start-MgBetaDeviceManagementVirtualEndpointOnPremiseConnectionHealthCheck'))
{
  $loadEnvPath = Join-Path $PSScriptRoot 'loadEnv.ps1'
  if (-Not (Test-Path -Path $loadEnvPath)) {
      $loadEnvPath = Join-Path $PSScriptRoot '..\loadEnv.ps1'
  }
  . ($loadEnvPath)
  $TestRecordingFile = Join-Path $PSScriptRoot 'Start-MgBetaDeviceManagementVirtualEndpointOnPremiseConnectionHealthCheck.Recording.json'
  $currentPath = $PSScriptRoot
  while(-not $mockingPath) {
      $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include 'HttpPipelineMocking.ps1' -File
      $currentPath = Split-Path -Path $currentPath -Parent
  }
  . ($mockingPath | Select-Object -First 1).FullName
}

Describe 'Start-MgBetaDeviceManagementVirtualEndpointOnPremiseConnectionHealthCheck' {
    It 'Run' -skip {
        { throw [System.NotImplementedException] } | Should -Not -Throw
    }

    It 'RunViaIdentity' -skip {
        { throw [System.NotImplementedException] } | Should -Not -Throw
    }
}
