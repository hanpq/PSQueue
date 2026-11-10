function Get-AllQueueItems
{
    <#
        .DESCRIPTION
            Collect all remaining queue items
        .PARAMETER Queue
            Queue object to discard all items in
        .EXAMPLE
            Get-AllQueueItems -Queue $Queue
            This example how to retreive all queue items remaining in the queue
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Sole purpose of function to target multiple items')]
    [CmdletBinding()]
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue
    )

    $Queue.GetAllQueuedItems()

}
