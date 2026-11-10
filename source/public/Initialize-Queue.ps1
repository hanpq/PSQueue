function Initialize-Queue
{
    <#
        .DESCRIPTION
            This cmdlet initializes a new queue object.

            The returned object is a wrapper class for the System.Collection.Queue class. This class (ExtendedQueue)
            provides additional functionality compared to the standard Queue class. The Queue object is
            stored as a property of the returned object called "Queue". The object returned also contains properties
            containing counts of added items, removed items, additions per sec, removes per sec and
            velocity (delta between add & remove per sec.). The module cmdlet Measure-Queue returns these metrics.

        .EXAMPLE
            $Queue = Initialize-Queue
            This example will create a new instance of the queue object
    #>

    [CmdletBinding()]
    param(
    )

    return ([ExtendedQueue]::new())
}
#endregion
