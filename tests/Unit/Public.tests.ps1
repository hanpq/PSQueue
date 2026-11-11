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
        It 'adds individual and piped items in order' {
            $Queue = Initialize-Queue

            Add-QueueItem -Queue $Queue -Items 'first'
            @('second', 'third') | Add-QueueItem -Queue $Queue

            @(Get-AllQueueItems -Queue $Queue) | Should -Be @('first', 'second', 'third')
        }
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
    Describe 'Clear-AllQueueItems' {
        It 'removes all queued items without changing the add count' {
            $Queue = Initialize-Queue
            Add-QueueItem -Queue $Queue -Items @('first', 'second')

            Clear-AllQueueItems -Queue $Queue

            (Measure-Queue -Queue $Queue).QueueCount | Should -Be 0
            $Queue.TotalItemsAdded | Should -Be 2
        }

        It 'does not fail when the queue is empty' {
            $Queue = Initialize-Queue

            { Clear-AllQueueItems -Queue $Queue } | Should -Not -Throw
        }
    }

    Describe 'Get-AllQueueItems' {
        It 'returns every queued item and empties the queue' {
            $Queue = Initialize-Queue
            Add-QueueItem -Queue $Queue -Items @('first', 'second', 'third')

            @(Get-AllQueueItems -Queue $Queue) | Should -Be @('first', 'second', 'third')
            (Measure-Queue -Queue $Queue).QueueCount | Should -Be 0
        }

        It 'returns no items when the queue is empty' {
            $Queue = Initialize-Queue

            @(Get-AllQueueItems -Queue $Queue) | Should -BeNullOrEmpty
        }
    }

    Describe 'Get-NextQueueItem' {
        It 'returns and removes the oldest item' {
            $Queue = Initialize-Queue
            Add-QueueItem -Queue $Queue -Items @('first', 'second')

            Get-NextQueueItem -Queue $Queue | Should -Be 'first'
            (Measure-Queue -Queue $Queue).QueueCount | Should -Be 1
        }

        It 'returns null when the queue is empty' {
            $Queue = Initialize-Queue

            Get-NextQueueItem -Queue $Queue | Should -BeNullOrEmpty
        }
    }

    Describe 'Show-NextQueueItem' {
        It 'returns the oldest item without removing it' {
            $Queue = Initialize-Queue
            Add-QueueItem -Queue $Queue -Items @('first', 'second')

            Show-NextQueueItem -Queue $Queue | Should -Be 'first'
            (Measure-Queue -Queue $Queue).QueueCount | Should -Be 2
        }

        It 'throws when the queue is empty' {
            $Queue = Initialize-Queue

            { Show-NextQueueItem -Queue $Queue } | Should -Throw
        }
    }

    Describe 'Measure-Queue' {
        It 'returns the queue count and rounded performance metrics' {
            $Queue = Initialize-Queue
            Add-QueueItem -Queue $Queue -Items 'first'
            $Queue.AddPerSec = 12.346
            $Queue.RemovePerSec = 2.344
            $Queue.Velocity = 10.002

            $Metrics = Measure-Queue -Queue $Queue

            $Metrics.QueueCount | Should -Be 1
            $Metrics.AddsPerSec | Should -Be 12.35
            $Metrics.RemovesPerSec | Should -Be 2.34
            $Metrics.Velocity | Should -Be 10
        }
    }
}
