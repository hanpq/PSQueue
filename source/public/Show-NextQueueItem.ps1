function Show-NextQueueItem
{
    <#
        .DESCRIPTION
            Shows the next item in queue without removing it from queue.
        .PARAMETER Queue
            Queue object to retreive performance metrics for.
        .EXAMPLE
            Show-NextQueueItem
            Description of example
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue
    )

    return $Queue.ShowNextQueueItem()

}
