# Dynamic construction of file path based on the current month
$monthYear = (Get-Date).ToString("MMMyyyy")
$filePathBase = "\Path\To\File\$monthYear"

# Dynamic construction of file name pattern
$dateSuffix = (Get-Date -Format 'yyyyMMdd')
$fileNamePattern = "FileToBeMonitor.$dateSuffix*"


# Combine the dynamic file path and file name pattern
$filePathPattern = Join-Path -Path $filePathBase -ChildPath $fileNamePattern

$jsonResult = @{
    prtg = @{
        result = @()
        error  = $null
    }
}

try {
    $fileInfo = Get-ChildItem $filePathPattern -ErrorAction Stop

    if ($fileInfo.Count -eq 0) {
        throw "File not found: $filePathPattern"
    }

    # Assuming you want to use the first matching file
    $file = $fileInfo[0]

    $result = @{
        channel       = "Name of File"
        value         = $file.Length
    }

    $jsonResult.prtg.result += @($result)
    # Add channel for last write time
    $resultLastWriteTime = @{
        channel       = "Last_Modified_Time"
        value         = [int]((Get-Date $file.LastWriteTime).ToString("HH") + (Get-Date $file.LastWriteTime).ToString("mm"))
    }

    $jsonResult.prtg.result += @($resultLastWriteTime)
} catch {
    $jsonResult.prtg.error = 1
    $jsonResult.prtg.text = "Error: $_"
    $jsonOutput = $jsonResult | ConvertTo-Json -Depth 100
    Write-Output $jsonOutput
    exit 1
}

# Output the JSON result without error information if successful
$jsonOutput = $jsonResult | ConvertTo-Json -Depth 100
Write-Output $jsonOutput
