[CmdletBinding()]
Param(
  [string] $DocsLocation = (Join-Path $PSScriptRoot "../docs/"),
  [string] $ExamplesLocation = (Join-Path $PSScriptRoot "../examples/")
)
function Start-Import {
    foreach ($File in Get-ChildItem $DocsLocation) {
        $ExampleFile = (Join-Path $ExamplesLocation $File.Name)
        if (Test-Path $ExampleFile) {
           $FileEmpty = Test-FileEmpty -File $ExampleFile
           if(-not($FileEmpty)) {
              Write-Host $ExampleFile
              $Content = Get-Content -Path $ExampleFile
              Import-Examples -Content $Content -File $File
           }
        }
    }
}


function Import-Examples {
    Param (
        [object]$Content,
        [string]$File
    ) 
    $SearchBlock = "## EXAMPLES(?s).*## PARAMETERS"
    $SearchBlock2 = "## DESCRIPTION(?s).*## PARAMETERS"
    $option = [System.Text.RegularExpressions.RegexOptions]::Multiline
    $Re = [regex]::new($SearchBlock, $option)
    $Re2 = [regex]::new($SearchBlock2, $option)
    $RetainedExamples = New-Object Collections.Generic.List[string] 
    $End = 0
    $NoOfExamples = 0
    foreach ($C in $Content) {
        if ($C.StartsWith("### Example")) {
            $NoOfExamples++
        }
        $End++  
    }
    Get-ExistingDescriptions -Content $Content -File $File  -start 0 -end $End -NoOfExamples $NoOfExamples
    if(Test-Path $File){
    $TitleCount = 1
    $DestinationContent = Get-Content -Encoding UTF8 -Raw $File
    $RetainedContent = $null
    foreach ($Ex in $RetainedExamples) {
            $ContentBody = $Ex.Split("**##@**")[0]
            $ContentDescription = $Ex.Split("**##@**")[2]
            $RetainedContent += "$ContentBody$ContentDescription"  
            $TitleCount++ 
                        
    }

   
    if(-not($Null -eq $RetainedContent) -and -not($RetainedContent.Contains("Add title here"))){
     if($DestinationContent -match $Re){
        $Extracted = $Matches[0]
        $FinalOutput = "## EXAMPLES`r`n$RetainedContent`r`n## PARAMETERS"
        $text = $DestinationContent.ToString()
        if(-not($Extracted.Contains("``````powershell"))){
            $text = $text.Replace($Extracted, "## PARAMETERS") 
            Write-Host "Does not have snippet"
        }else{
            $text = $text.Replace($Extracted, $FinalOutput)
        }
          $text | Out-File $File -Encoding UTF8
     }
     if($DestinationContent -match $Re2){
        $Extracted2 = $Matches[0]
        $DescriptionCommand = [System.IO.Path]::GetFileNameWithoutExtension($File)
        $Description1 = "This example shows how to use the $DescriptionCommand Cmdlet."
        $Description2 = "To learn about permissions for this resource, see the [permissions reference](/graph/permissions-reference)."
      
        $text2 = $DestinationContent.ToString()
        if(-not($Extracted2.Contains("## EXAMPLES"))){
            Write-Host "Does not have snippet $DescriptionCommand"
            $text2 = $text2.Replace($Description1, $null)
            $text2 = $text2.Replace($Description2, $null)
            $text2 | Out-File $File -Encoding UTF8

        }
     }
     $Stream = [IO.File]::OpenWrite($File)
     try
     {
         $Stream.SetLength($stream.Length - 2)
         $Stream.Close()
     }
     catch
     {
         
     }
     $Stream.Dispose()
     $RetainedExamples.Clear()
    }
    
}
    
}

function Get-ExistingDescriptions {

    Param (
        [object]$Content,
        [string]$File,
        [string]$CommandPattern,
        [int]$Start,
        [int]$End,
        [int]$NoOfExamples
    )
    $Title = $null
    $ContentBlock = $null
 
    for ($i = $Start; $i -lt $End; $i++) {
        $Value = $Content[$i]
        $ContentBlock += "$Value`n" 
        if ($Content[$i].StartsWith("### Example")) {
            $Title = $Content[$i]
        }   
        if ($Content[$i].EndsWith("``")) {
            $Start = $i
            break;
        }
    }
    $RetainedDescription = $null
    for ($j = $Start + 1; $j -lt $end; $j++) {
       
        if ($Content[$j].StartsWith("### Example")) {
            break;
        }
        $DescVal = $Content[$j]
        $RetainedDescription += "$DescVal`n"
    }
    $RetainedExamples.Add("$ContentBlock**##@**$Title**##@**$RetainedDescription")
    if ($NoOfExamples -gt 1) {
        $NoOfExamples--
        for ($k = $Start; $k -lt $End; $k++) {
            if ($Content[$k].StartsWith("### Example")) {
                $Start = $k
                break;
            }
        }
      
        Get-ExistingDescriptions -Content $Content -File $File -start $Start -end $End -NoOfExamples $NoOfExamples
    }
   
}

Function Test-FileEmpty {

    Param ([Parameter(Mandatory = $true)][string]$File)
  
    if ((Test-Path -LiteralPath $File) -and !((Get-Content -LiteralPath $file -Raw) -match '\S')) {return $true} else {return $false}
  
  }
Start-Import
# SIG # Begin signature block
# MIInzgYJKoZIhvcNAQcCoIInvzCCJ7sCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAz9Jnkqy4aEzym
# l5WpNrPY5IdvYruTSJuJnfcx6eHpDqCCDYUwggYDMIID66ADAgECAhMzAAADTU6R
# phoosHiPAAAAAANNMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjMwMzE2MTg0MzI4WhcNMjQwMzE0MTg0MzI4WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDUKPcKGVa6cboGQU03ONbUKyl4WpH6Q2Xo9cP3RhXTOa6C6THltd2RfnjlUQG+
# Mwoy93iGmGKEMF/jyO2XdiwMP427j90C/PMY/d5vY31sx+udtbif7GCJ7jJ1vLzd
# j28zV4r0FGG6yEv+tUNelTIsFmmSb0FUiJtU4r5sfCThvg8dI/F9Hh6xMZoVti+k
# bVla+hlG8bf4s00VTw4uAZhjGTFCYFRytKJ3/mteg2qnwvHDOgV7QSdV5dWdd0+x
# zcuG0qgd3oCCAjH8ZmjmowkHUe4dUmbcZfXsgWlOfc6DG7JS+DeJak1DvabamYqH
# g1AUeZ0+skpkwrKwXTFwBRltAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUId2Img2Sp05U6XI04jli2KohL+8w
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwMDUxNzAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# ACMET8WuzLrDwexuTUZe9v2xrW8WGUPRQVmyJ1b/BzKYBZ5aU4Qvh5LzZe9jOExD
# YUlKb/Y73lqIIfUcEO/6W3b+7t1P9m9M1xPrZv5cfnSCguooPDq4rQe/iCdNDwHT
# 6XYW6yetxTJMOo4tUDbSS0YiZr7Mab2wkjgNFa0jRFheS9daTS1oJ/z5bNlGinxq
# 2v8azSP/GcH/t8eTrHQfcax3WbPELoGHIbryrSUaOCphsnCNUqUN5FbEMlat5MuY
# 94rGMJnq1IEd6S8ngK6C8E9SWpGEO3NDa0NlAViorpGfI0NYIbdynyOB846aWAjN
# fgThIcdzdWFvAl/6ktWXLETn8u/lYQyWGmul3yz+w06puIPD9p4KPiWBkCesKDHv
# XLrT3BbLZ8dKqSOV8DtzLFAfc9qAsNiG8EoathluJBsbyFbpebadKlErFidAX8KE
# usk8htHqiSkNxydamL/tKfx3V/vDAoQE59ysv4r3pE+zdyfMairvkFNNw7cPn1kH
# Gcww9dFSY2QwAxhMzmoM0G+M+YvBnBu5wjfxNrMRilRbxM6Cj9hKFh0YTwba6M7z
# ntHHpX3d+nabjFm/TnMRROOgIXJzYbzKKaO2g1kWeyG2QtvIR147zlrbQD4X10Ab
# rRg9CpwW7xYxywezj+iNAc+QmFzR94dzJkEPUSCJPsTFMIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGZ8wghmbAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAANNTpGmGiiweI8AAAAA
# A00wDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIBc+
# SHAcMqkUGbpZWvieD3oQAZBBhpOFQst74Pw83r95MEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAy5HKCUYawjEF7l6jTGGEcR2UJsUQspchE8wZ
# X5aHcBqPN2fpX2szXkS9Exkx2SjbKOJNw3/kF8wuXNgcxoUlpgw2hmymTTcekp6q
# 3HJV43I34Im+DEGUSq1J4M3Or7SV4cPdLoKbsr2ywYtD+KRyZSjkS1d4y61Rk/7b
# LpCorFxhwVGIIFGw1ziqvtC6UPwKblIBNmZgRkaFcbkRnsEmIc+RB3sjK04+GEmc
# ygr6ZenQ0wpbwaVqCVTWjc11EijQwOK/1UOjkNOwfnlwkvUw+abHpgBKdW6/TTaD
# dpurGVXWSsdfmbdauvigJtAv1Mcciq2MkJ8Yquqg27OPYz7Uv6GCFykwghclBgor
# BgEEAYI3AwMBMYIXFTCCFxEGCSqGSIb3DQEHAqCCFwIwghb+AgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFZBgsqhkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCA/OBnL4wmWRBvoSmhHLEJfnC9NTNJco45l
# SF5Iv17ouQIGZV3rSWK0GBMyMDIzMTIwNzEzMzMyOS4yNjVaMASAAgH0oIHYpIHV
# MIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsT
# HVRoYWxlcyBUU1MgRVNOOjJBRDQtNEI5Mi1GQTAxMSUwIwYDVQQDExxNaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIReDCCBycwggUPoAMCAQICEzMAAAHenkie
# lp8oRD0AAQAAAd4wDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwHhcNMjMxMDEyMTkwNzEyWhcNMjUwMTEwMTkwNzEyWjCB0jELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9z
# b2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjoyQUQ0LTRCOTItRkEwMTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALSB
# 9ByF9UIDhA6xFrOniw/xsDl8sSi9rOCOXSSO4VMQjnNGAo5VHx0iijMEMH9LY2SU
# IBkVQS0Ml6kR+TagkUPbaEpwjhQ1mprhRgJT/jlSnic42VDAo0en4JI6xnXoAoWo
# KySY8/ROIKdpphgI7OJb4XHk1P3sX2pNZ32LDY1ktchK1/hWyPlblaXAHRu0E3yn
# vwrS8/bcorANO6DjuysyS9zUmr+w3H3AEvSgs2ReuLj2pkBcfW1UPCFudLd7IPZ2
# RC4odQcEPnY12jypYPnS6yZAs0pLpq0KRFUyB1x6x6OU73sudiHON16mE0l6LLT9
# OmGo0S94Bxg3N/3aE6fUbnVoemVc7FkFLum8KkZcbQ7cOHSAWGJxdCvo5OtUtRdS
# qf85FklCXIIkg4sm7nM9TktUVfO0kp6kx7mysgD0Qrxx6/5oaqnwOTWLNzK+BCi1
# G7nUD1pteuXvQp8fE1KpTjnG/1OJeehwKNNPjGt98V0BmogZTe3SxBkOeOQyLA++
# 5Hyg/L68pe+DrZoZPXJaGU/iBiFmL+ul/Oi3d83zLAHlHQmH/VGNBfRwP+ixvqhy
# k/EebwuXVJY+rTyfbRfuh9n0AaMhhNxxg6tGKyZS4EAEiDxrF9mAZEy8e8rf6dlK
# IX5d3aQLo9fDda1ZTOw+XAcAvj2/N3DLVGZlHnHlAgMBAAGjggFJMIIBRTAdBgNV
# HQ4EFgQUazAmbxseaapgdxzK8Os+naPQEsgwHwYDVR0jBBgwFoAUn6cVXQBeYl2D
# 9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
# LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQAD
# ggIBAOKUwHsXDacGOvUIgs5HDgPs0LZ1qyHS6C6wfKlLaD36tZfbWt1x+GMiazSu
# y+GsxiVHzkhMW+FqK8gruLQWN/sOCX+fGUgT9LT21cRIpcZj4/ZFIvwtkBcsCz1X
# EUsXYOSJUPitY7E8bbldmmhYZ29p+XQpIcsG/q+YjkqBW9mw0ru1MfxMTQs9MTDi
# D28gAVGrPA3NykiSChvdqS7VX+/LcEz9Ubzto/w28WA8HOCHqBTbDRHmiP7MIj+S
# QmI9VIayYsIGRjvelmNa0OvbU9CJSz/NfMEgf2NHMZUYW8KqWEjIjPfHIKxWlNMY
# huWfWRSHZCKyIANA0aJL4soHQtzzZ2MnNfjYY851wHYjGgwUj/hlLRgQO5S30Zx7
# 8GqBKfylp25aOWJ/qPhC+DXM2gXajIXbl+jpGcVANwtFFujCJRdZbeH1R+Q41Fjg
# Bg4m3OTFDGot5DSuVkQgjku7pOVPtldE46QlDg/2WhPpTQxXH64sP1GfkAwUtt6r
# rZM/PCwRG6girYmnTRLLsicBhoYLh+EEFjVviXAGTk6pnu8jx/4WPWu0jsz7yFzg
# 82/FMqCk9wK3LvyLAyDHN+FxbHAxtgwad7oLQPM0WGERdB1umPCIiYsSf/j79EqH
# doNwQYROVm+ZX10RX3n6bRmAnskeNhi0wnVaeVogLMdGD+nqMIIHcTCCBVmgAwIB
# AgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0
# IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1
# WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOThpkzntHIhC3miy9ckeb0O
# 1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZn
# hUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V29YZQ3MFEyHFcUTE3oAo4bo3t
# 1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxq
# D89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkNyjYtcI4xyDUoveO0hyTD4MmP
# frVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7KMtXAhjBcTyziYrLNueKNiOSW
# rAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRfNN0Sidb9pSB9fvzZnkXftnIv
# 231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zb
# r17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEBc8pnol7XKHYC4jMYcten
# IPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5C4lh8zYGNRiER9vcG9H9stQc
# xWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8FdsaN8cIFRg/eKtFtvUeh17a
# j54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQU
# n6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUwUzBRBgwrBgEEAYI3TIN9AQEw
# QTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9E
# b2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/
# MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJ
# oEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01p
# Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYB
# BQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCdVX38Kq3h
# LB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEztTnXwnE2P9pkbHzQdTltuw8x
# 5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gngugnue99qb74p
# y27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G82jfZfakVqr3lbYoVSfQJL1A
# oL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbC
# HcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI95ko+ZjtPu4b6MhrZlvSP9pEB
# 9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNt
# yo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZKCS6OEuabvshVGtqRRFHqfG3
# rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcV
# v7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6TPmb/wrpNPgkNWcr4A24
# 5oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvpe784cETRkPHIqzqKOghif9lw
# Y1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAtQwggI9AgEBMIIBAKGB2KSB1TCB
# 0jELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
# TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
# aGFsZXMgVFNTIEVTTjoyQUQ0LTRCOTItRkEwMTElMCMGA1UEAxMcTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAaKBSisy4y86pl8Xy
# 22CJZExE2vOggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAN
# BgkqhkiG9w0BAQUFAAIFAOkcL/YwIhgPMjAyMzEyMDcxOTUwMTRaGA8yMDIzMTIw
# ODE5NTAxNFowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA6Rwv9gIBADAHAgEAAgIV
# djAHAgEAAgIRNjAKAgUA6R2BdgIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEE
# AYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GB
# AEI5kgEv6+WM4KzIh17rd93J+WBLBHhDc77l2wBcv6Mbzjj4dgWl9OQsIFsj18Je
# +CaHlWDk8XovtETiY3xFuhhSUsfsRMnQky2ABzpiwQ7xMaLCxqk1LBlJeMBf+9tW
# FhoCKUbVhLkQnUxXFnudsYHH/P+farKOEIPZo8aTdyirMYIEDTCCBAkCAQEwgZMw
# fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
# TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHenkielp8oRD0AAQAA
# Ad4wDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRAB
# BDAvBgkqhkiG9w0BCQQxIgQgSWjRHXbTYXqQq4nJlBqTGWMLCNS4Gx+G9CXjWSDt
# K34wgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCCOPiOfDcFeEBBJAn/mC3Mg
# rT5w/U2z81LYD44Hc34dezCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
# QSAyMDEwAhMzAAAB3p5InpafKEQ9AAEAAAHeMCIEINQuFfpVnF0P8HEgXXf2lS5k
# +0SFlTJzViC583r/kETHMA0GCSqGSIb3DQEBCwUABIICAHnMBNHjS02Neuph8BCK
# H7KJv5KohhzjMbzcieea50/4ttnfrsvorembjX+3jNcnTdI4c2qrGvKAHjAspJAF
# yZPjnDLCpwN4yfJeek++8leSEDcY75g3GZq9XVANSjKTNY2bmXRpK552j72nyCMh
# m9KQE6mpWEWqhDZ+4m+EJfRN2oJGRZ92NBZWJahpK6laHhp0gMSUxCJz75uFdE2J
# MtR9bEi6j+7f0ZBc6ddPxEB+5uT7+RbrKNaCzMYMwgnc/tdVd2WxuPtdfG9656mo
# wtmT+0i3dbXs31kgL9ZNX2PF65I6gthZLKnrBrqoV5FmLKzQ5byR4+oUEmS3j2Id
# ajOIyUzsMHtvbK8h28U0HEyQpqqhoCYDAdVCc3JVicjMS+6pN+gGSSiWfSlENUr6
# QYsrIzDoxMo3jRYkX7Z/FQOxvESWsplHbcwdxR3BQEPTdfYfyi/KSNF4yOlC+1pX
# WKJcZFhvnwxZUEy/oUw7kqNQ0V3htLU7SWL2x6NhHIGmjMU7CvvuROTYuGAa6rcq
# GG+oHIySeqMRsjBzLsvJJefDGLiwQAoGDbrEESKUC0DxSJFBFWchSizi3XNEsUNV
# GxzNwkNmOJ3jkS1RLU0KK2Z8MwMYvwBifH1k+k0yOF0Vvg2S2zFmqoPqt2V6e52G
# Sd+/T+8/n1s2SsmlGtS8mMvh
# SIG # End signature block
