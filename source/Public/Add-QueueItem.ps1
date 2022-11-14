function Add-QueueItem
{
    <#
        .DESCRIPTION
            Adds a new item to the queue
        .PARAMETER Queue
            Queue object to add items to
        .PARAMETER Items
            Defines the items to add to the queue
        .EXAMPLE
            Add-QueueItem -Queue $Queue -Item 'Foo'
            This example shows how to add an item to the queue
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'False positive')]
    [CmdletBinding()]
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue,
        [parameter(Mandatory, ValueFromPipeline)][object[]]$Items
    )

    process
    {
        $Items | ForEach-Object {
            $Queue.AddQueueItem($PSItem)
        }
    }
}
