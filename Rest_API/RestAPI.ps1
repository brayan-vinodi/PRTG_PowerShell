param (
    [string]$Username,
    [string]$Password
)

# Initialize JSON result object
$jsonResult = @{
    prtg = @{
        result = @()
        error  = $null
    }
}

# Check if username and password are provided
if (-not $Username -or -not $Password) {
    $jsonResult.prtg.error = 1
    $jsonResult.prtg.text = "Username and password are required."
    Write-Output ($jsonResult | ConvertTo-Json -Depth 100)
    exit 1
}

# Define the API URL
$apiUrl = "ENTER_API_URL_HERE"

# Create a credential object
$credential = New-Object System.Management.Automation.PSCredential ($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))

try {
    # Make the HTTP request with authentication
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Credential $credential
   
    # Extract the specific data from the response
    $data = $response.receive.data

    # Add balance to JSON result
    $jsonResult.prtg.result += @{
        channel = "Name"
        value = [INT]$data
        unit = "Custom"  
    }

} catch {
    $jsonResult.prtg.error = 1
    $jsonResult.prtg.text = "Failed to retrieve data: $($_.Exception.Message)"
}

# Output the JSON result
$jsonOutput = $jsonResult | ConvertTo-Json -Depth 100
Write-Output $jsonOutput
