Configuration InstallPowerShellv5 {
    Param ( [string] $nodeName )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $nodeName {
        LocalConfigurationManager { 
            RebootNodeIfNeeded = $True 
        }
        Script InstallPowerShell5 {
            TestScript = {$PSVersionTable.PSVersion -ge [Version]'5.0'}
            SetScript = {
                Invoke-WebRequest -UseBasicParsing 'https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win8.1AndW2K12R2-KB3134758-x64.msu' -OutFile "$env:Windir\temp\Win8.1AndW2K12R2-KB3134758-x64.msu"
                Start-Process -FilePath wusa.exe -PassThru -Wait -ArgumentList "$env:Windir\temp\Win8.1AndW2K12R2-KB3134758-x64.msu",'/quiet','/norestart'
                $global:DSCMachineStatus = 1
            }
            Getscript = {@{Result = $PSVersionTable.PSVersion}}
        }
    }
}

InstallPowerShellv5 -nodeName $env:COMPUTERNAME -OutputPath "$env:temp\MOFs"

Set-DscLocalConfigurationManager -Path "$env:temp\MOFs"
Start-DscConfiguration -Path "$env:temp\MOFs" #-Wait -Verbose 
