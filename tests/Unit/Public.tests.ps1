BeforeDiscovery {
    $RootItem = Get-Item $PSScriptRoot
    while ($RootItem.GetDirectories().Name -notcontains 'source')
    {
        $RootItem = $RootItem.Parent
    }
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
                })
        }
    ).BaseName

    Import-Module $ProjectName -Force
}

InModuleScope $ProjectName {
    Describe 'Add-QueueItem' {
    }
    Describe 'Initialize-Queue' -Fixture {
        Context -Name 'When calling Initialize-Queue' {
            BeforeAll {
                $Queue = Initialize-Queue
            }
            It -Name 'Should return a object of type [ExtendedQueue]' {
                $Queue.GetType().Name | Should -Be 'ExtendedQueue'
            }
            It -Name 'Should contain a [System.Collections.Queue] object in property queue' {
                , ($Queue.Queue) | Should -BeOfType [System.Collections.Queue]
            }
            It -Name 'Should contain a [system.collections.Generic.Queue[pscustomobject]]' {
                , ($Queue.LastOperations) | Should -BeOfType [system.collections.Generic.Queue[pscustomobject]]
            }
            It -Name 'Should have default values for properties' {
                $Queue.TotalItemsAdded | Should -Be 0
                $Queue.TotalItemsRemoved | Should -Be 0
                $Queue.AddPerSec | Should -Be 0
                $Queue.RemovePerSec | Should -Be 0
                $Queue.Velocity | Should -Be 0
                $Queue.PerformanceHistory | Should -Be 50
            }
            It -Name 'Should have correct type of properties' {
                $Queue.TotalItemsAdded | Should -BeOfType [int64]
                $Queue.TotalItemsRemoved | Should -BeOfType [int64]
                $Queue.AddPerSec | Should -BeOfType [double]
                $Queue.RemovePerSec | Should -BeOfType [double]
                $Queue.Velocity | Should -BeOfType [double]
                $Queue.PerformanceHistory | Should -BeOfType [int]
            }
            It -Name 'Should have methods' {
                $Methods = @('AddQueueItem', 'GetNextQueueItem', 'ShowNextQueueItem', 'GetQueueCount', 'ClearAllQueueItems', 'GetAllQueueItems', 'RotateLastOperations', 'CalculateSpeed')
                foreach ($Method in $Methods)
                {
                    $Queue.PSObject.Members.Name | Should -Contain $Method
                }
            }
        }
    }
    Describe 'Clear-AllQueueItems' {}
    Describe 'Get-AllQueueItems' {}
    Describe 'Get-NextQueueItem' {}
    Describe 'Measure-Queue' {}
    Describe 'Show-NextQueueItem' {}
}
