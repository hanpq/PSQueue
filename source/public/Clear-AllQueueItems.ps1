function Clear-AllQueueItems
{
    <#
        .DESCRIPTION
            Discard all queued items in queue
        .PARAMETER Queue
            Queue object to discard all items in
        .EXAMPLE
            Clear-AllQueueItems -Queue $Queue
            This example shows how to discard all items of the provided queue
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Sole purpose of function to target multiple items')]
    [CmdletBinding()]
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue
    )

    $Queue.ClearAllQueueItems()

}
