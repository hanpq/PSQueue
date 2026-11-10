function Get-NextQueueItem
{
    <#
        .DESCRIPTION
            Returns the next object from queue. That object will be removed from the queue.
        .PARAMETER Queue
            Queue object to retreive next items from
        .EXAMPLE
            Get-NextQueueItem -Queue $Queue
            This example with return the next item in queue.
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue
    )

    return $Queue.GetNextQueueItem()

}
