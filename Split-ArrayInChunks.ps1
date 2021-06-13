function Split-ArrayInChunks {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]
        $InputArray,

        [Parameter(Mandatory = $true)]
        [int]
        $NumberOfChunks
    )

    $arrayList = New-Object System.Collections.ArrayList

    # populate
    0..($NumberOfChunks - 1) | ForEach-Object {
        [void]$arrayList.Add((New-Object System.Collections.ArrayList))
    }

    $chunkSize = [Math]::Floor($InputArray.Count / $NumberOfChunks);
    $count = 0
    $currChunkList = 0
    foreach ($elem in $InputArray) {
        if ($count -gt $chunkSize) {
            $count = 0
            $currChunkList += 1
        }

        [void]$arrayList[$currChunkList].Add($elem)
        $count++
    }

    return $arrayList.ToArray()
}