BeforeDiscovery {
        $RootItem = Get-Item $PSScriptRoot
    while ($RootItem.GetDirectories().Name -notcontains "source") {$RootItem = $RootItem.Parent}
    $ProjectPath = $RootItem.FullName
    $ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
        ($_.Directory.Name -eq 'source') -and
            $(try
                {
                    Test-ModuleManifest $_.FullName -ErrorAction Stop
                }
                catch
                {
                    $false
                }) }
    ).BaseName

    Import-Module $ProjectName -Force
}

InModuleScope $ProjectName {
    Describe 'Assert-FolderExist' {
        Context 'Default' {
            It 'Folder is created' {
                'TestDrive:\FolderDoesNotExists' | Assert-FolderExist
                'TestDrive:\FolderDoesNotExists' | Should -Exist
            }

            It 'Folder is still present' {
                New-Item -Path 'TestDrive:\FolderExists' -ItemType Directory
                'TestDrive:\FolderExists' | Assert-FolderExist
                'TestDrive:\FolderExists' | Should -Exist
            }
        }
    }


    Describe 'Invoke-GarbageCollect' {
        Context 'Default' {
            It 'Should not throw' {
                { Invoke-GarbageCollect } | Should -Not -Throw
            }
        }
    }

    Describe 'pslog' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { [datetime]'2000-01-01 01:00:00+00:00' }
            $CompareString = ([datetime]'2000-01-01 01:00:00+00:00').ToString('yyyy-MM-ddThh:mm:ss.ffffzzz')
        }
        Context 'Success' {
            It 'Log file should have content' {
                pslog -Severity Success -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tSuccess`tdefault`tMessage"
            }
        }
        Context 'Info' {
            It 'Log file should have content' {
                pslog -Severity Info -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tInfo`tdefault`tMessage"
            }
        }
        Context 'Warning' {
            It 'Log file should have content' {
                pslog -Severity Warning -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tWarning`tdefault`tMessage"
            }
        }
        Context 'Error' {
            It 'Log file should have content' {
                pslog -Severity Error -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tError`tdefault`tMessage"
            }
        }
        Context 'Verbose' {
            It 'Log file should have content' {
                pslog -Severity Verbose -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole -Verbose:$true
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tVerbose`tdefault`tMessage"
            }
        }
        Context 'Debug' {
            It 'Log file should have content' {
                pslog -Severity Debug -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole -Debug:$true
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tDebug`tdefault`tMessage"
            }
        }
    }

    Describe 'pslog additional behavior' {
        It 'uses the default log directory when no override is provided' {
            Mock Assert-FolderExist {}
            Mock Add-Content {}

            pslog -Severity Info -Message 'Default directory' -DoNotLogToConsole

            Assert-MockCalled Assert-FolderExist -Times 1
            Assert-MockCalled Add-Content -Times 1
        }

        It 'writes each severity to its corresponding console stream' {
            Mock Write-Host {}
            Mock Write-Information {}
            Mock Write-Warning {}
            Mock Write-Error {}
            Mock Write-Verbose {}
            Mock Write-Debug {}
            $LogDirectory = 'TestDrive:\ConsoleLogs'

            pslog -Severity Success -Message 'Success' -LogDirectoryOverride $LogDirectory
            pslog -Severity Info -Message 'Info' -LogDirectoryOverride $LogDirectory
            pslog -Severity Warning -Message 'Warning' -LogDirectoryOverride $LogDirectory
            pslog -Severity Error -Message 'Error' -LogDirectoryOverride $LogDirectory
            pslog -Severity Verbose -Message 'Verbose' -LogDirectoryOverride $LogDirectory -Verbose
            pslog -Severity Debug -Message 'Debug' -LogDirectoryOverride $LogDirectory -Debug

            Assert-MockCalled Write-Host -Times 1
            Assert-MockCalled Write-Information -Times 1
            Assert-MockCalled Write-Warning -Times 1
            Assert-MockCalled Write-Error -Times 1
            Assert-MockCalled Write-Verbose -Times 1
            Assert-MockCalled Write-Debug -Times 1
        }

        It 'rethrows error severity when Throw is specified' {
            { pslog -Severity Error -Message 'Expected failure' -LogDirectoryOverride 'TestDrive:\ErrorLogs' -DoNotLogToConsole -Throw } |
                Should -Throw
        }

        It 'does not write verbose or debug entries when their preferences are disabled' {
            Mock Get-Date { [datetime]'2000-01-01 01:00:00+00:00' }
            $PreviousVerbosePreference = $VerbosePreference
            $PreviousDebugPreference = $DebugPreference
            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            $LogDirectory = 'TestDrive:\DisabledLogs'
            $LogFileName = ([datetime]'2000-01-01 01:00:00+00:00').ToString('yyy-MM-dd') + '.log'
            $LogFile = Join-Path $LogDirectory $LogFileName

            try
            {
                pslog -Severity Verbose -Message 'Not logged' -LogDirectoryOverride $LogDirectory -DoNotLogToConsole
                pslog -Severity Debug -Message 'Not logged' -LogDirectoryOverride $LogDirectory -DoNotLogToConsole

                Test-Path -LiteralPath $LogFile | Should -BeFalse
            }
            finally
            {
                $VerbosePreference = $PreviousVerbosePreference
                $DebugPreference = $PreviousDebugPreference
            }
        }
    }

    Describe 'Write-PSProgress' {
        Context 'Default' {
            It 'Should not throw' {
                $ProgressPreference = 'SilentlyContinue'
                {
                    1..5 | ForEach-Object -Begin { $StartTime = Get-Date } -Process {
                        Write-PSProgress -Activity 'Looping' -Target $PSItem -Counter $PSItem -Total 5 -StartTime $StartTime
                    }
                    Write-PSProgress -Activity 'Looping' -Completed
                } | Should -Not -Throw
            }
        }

        It 'writes no-time progress with IDs and clamps completion above 100 percent' {
            Mock Write-Progress {}

            Write-PSProgress -Activity 'NoTimeStats' -Id 2 -ParentId 1 -Target 'item' -Counter 12 -Total 10 -NoTimeStats -DisableDynamicUpdateFrquency

            Assert-MockCalled Write-Progress -Times 1 -ParameterFilter {
                $Id -eq 2 -and
                $ParentId -eq 1 -and
                $PercentComplete -eq 100 -and
                $Status -eq '12/10 - 100%'
            }
            Write-PSProgress -Activity 'NoTimeStats' -Id 2 -Completed
        }

        It 'skips progress updates between dynamic frequency intervals' {
            Mock Write-Progress {}

            Write-PSProgress -Activity 'SkippedUpdate' -Counter 2 -Total 1000 -NoTimeStats

            Assert-MockCalled Write-Progress -Times 0
            Write-PSProgress -Activity 'SkippedUpdate' -Completed
        }

        It 'reports zero remaining time before processing the first item' {
            Mock Write-Progress {}
            $Activity = 'ZeroCounter'

            Write-PSProgress -Activity $Activity -Counter 0 -Total 1 -StartTime ([datetime]::Now.AddSeconds(-1))

            Assert-MockCalled Write-Progress -Times 1 -ParameterFilter { $SecondsRemaining -eq 0 }
            Write-PSProgress -Activity $Activity -Completed
        }

        It 'writes a completion update and clears its start-time variable' {
            Mock Write-Progress {}
            $Activity = 'CompletedUpdate'
            $VariableName = 'ProgressStartTime_CompletedUpdate'
            Write-PSProgress -Activity $Activity -Counter 1 -Total 1 -NoTimeStats

            Write-PSProgress -Activity $Activity -Id 3 -Completed

            Assert-MockCalled Write-Progress -Times 1 -ParameterFilter { $Completed }
            Get-Variable -Name $VariableName -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }

        It 'rethrows failures while clearing its start-time variable' {
            Mock Remove-Variable {
                Remove-Item -LiteralPath "Variable:global:$Name" -ErrorAction SilentlyContinue
                throw 'Removal failed'
            }
            $Activity = 'FailedCleanup'
            Write-PSProgress -Activity $Activity -Counter 1 -Total 1 -NoTimeStats

            { Write-PSProgress -Activity $Activity -Completed } | Should -Throw '*Removal failed*'
        }
    }
}
