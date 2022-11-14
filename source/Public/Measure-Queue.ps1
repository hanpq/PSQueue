function Measure-Queue
{
    <#
        .DESCRIPTION
            Returns an object with performance metrics for the provided queue.
        .PARAMETER Queue
            Queue object to retreive performance metrics for.
        .EXAMPLE
            Measure-Queue -Queue $Queue
            This example will return a object containing performance metrics for the provided queue.
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue
    )

    return [pscustomobject]@{
        QueueCount    = $Queue.GetQueueCount()
        AddsPerSec    = [Math]::Round($Queue.AddPerSec, 2)
        RemovesPerSec = [Math]::Round($Queue.RemovePerSec, 2)
        Velocity      = [Math]::Round($Queue.Velocity, 2)
    }

}
