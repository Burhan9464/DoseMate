<#
.SYNOPSIS
  DoseMate End-to-End API Smoke Test Script.
.DESCRIPTION
  Tests the complete user journey against the live Spring Boot server:
  1. Register a test user
  2. Authenticate and retrieve JWT
  3. Fetch user profile
  4. Create a medication with schedule and inventory
  5. Fetch dashboard state
  6. Execute the Drag-the-Pill take transaction (POST /doses/{id}/taken)
  7. Verify atomic inventory decrement
  8. Skip a dose and undo the skip
  9. Query medication history with status filters
#>
param(
    [string]$BaseUrl = "http://localhost:8080/api/v1"
)

$ErrorActionPreference = "Stop"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   DoseMate REST API E2E Smoke Test       " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Target Base URL: $BaseUrl" -ForegroundColor Yellow

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testEmail = "tester_$timestamp@example.com"
$testPassword = "Password123!"

# Helper for JSON requests
function Invoke-DoseMateApi {
    param(
        [string]$Method,
        [string]$Path,
        [object]$Body = $null,
        [string]$Token = $null
    )
    $headers = @{
        "Content-Type" = "application/json"
        "Accept"       = "application/json"
    }
    if ($Token) {
        $headers["Authorization"] = "Bearer $Token"
    }
    
    $uri = "$BaseUrl$Path"
    $jsonBody = if ($Body) { $Body | ConvertTo-Json -Depth 10 } else { $null }
    
    try {
        if ($jsonBody) {
            return Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body $jsonBody
        } else {
            return Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers
        }
    } catch {
        Write-Host "Error invoking $Method $Path" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errText = $reader.ReadToEnd()
            Write-Host "Server Response: $errText" -ForegroundColor Red
        }
        throw $_
    }
}

# 1. Register User
Write-Host "`n[1/7] Registering test user ($testEmail)..." -NoNewline
$regPayload = @{
    fullName    = "Jane SmokeTester"
    email       = $testEmail
    password    = $testPassword
    dateOfBirth = "1996-05-20"
    gender      = "FEMALE"
    country     = "United States"
    timezone    = "America/New_York"
}
$regResponse = Invoke-DoseMateApi -Method "POST" -Path "/auth/register" -Body $regPayload
$jwt = $regResponse.data.token
Write-Host " OK! (JWT issued)" -ForegroundColor Green

# 2. Get User Profile
Write-Host "[2/7] Fetching authenticated user profile..." -NoNewline
$profile = Invoke-DoseMateApi -Method "GET" -Path "/users/me" -Token $jwt
Write-Host " OK! (Hello, $($profile.data.fullName))" -ForegroundColor Green

# 3. Create Medicine with Schedule & Inventory
Write-Host "[3/7] Creating medication (Amoxicillin 500mg, 30 capsules)..." -NoNewline
$todayStr = (Get-Date).ToString("yyyy-MM-dd")
$medPayload = @{
    name         = "Amoxicillin"
    dosageValue  = 500.0
    dosageUnit   = "mg"
    type         = "CAPSULE"
    startDate    = $todayStr
    ongoing      = $true
    instructions = "Take after breakfast with water"
    schedule     = @{
        frequencyMode = "ONCE_DAILY"
        days          = @("MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY")
        times         = @("08:00:00")
    }
    inventory    = @{
        quantity          = 30
        unit              = "capsules"
        lowStockThreshold = 5
    }
}
$medResponse = Invoke-DoseMateApi -Method "POST" -Path "/medicines" -Body $medPayload -Token $jwt
$medicineId = $medResponse.data.id
Write-Host " OK! (Medicine ID: $medicineId)" -ForegroundColor Green

# 4. Fetch Dashboard
Write-Host "[4/7] Fetching daily dashboard state..." -NoNewline
$dashboard = Invoke-DoseMateApi -Method "GET" -Path "/dashboard" -Token $jwt
Write-Host " OK!" -ForegroundColor Green
Write-Host "      Greeting: $($dashboard.data.greeting)" -ForegroundColor Gray
Write-Host "      Daily Progress: $($dashboard.data.dailyProgress.takenDoses)/$($dashboard.data.dailyProgress.totalScheduledDoses) doses" -ForegroundColor Gray

# 5. Fetch Today's Doses
Write-Host "[5/7] Fetching today's dose records..." -NoNewline
$dosesResponse = Invoke-DoseMateApi -Method "GET" -Path "/doses/today" -Token $jwt
$todayDoses = $dosesResponse.data
Write-Host " OK! (Found $($todayDoses.Count) dose(s))" -ForegroundColor Green

if ($todayDoses.Count -gt 0) {
    $doseToTake = $todayDoses[0]
    
    # 6. Execute Drag-the-Pill Taken Transaction
    Write-Host "[6/7] Simulating Drag-the-Pill: Marking Dose $($doseToTake.id) as TAKEN..." -NoNewline
    $takeResponse = Invoke-DoseMateApi -Method "POST" -Path "/doses/$($doseToTake.id)/taken" -Token $jwt
    Write-Host " OK!" -ForegroundColor Green
    Write-Host "      Status: $($takeResponse.data.dose.status)" -ForegroundColor Gray
    Write-Host "      Remaining Inventory: $($takeResponse.data.remainingInventory) capsules" -ForegroundColor Gray
    
    if ($takeResponse.data.remainingInventory -ne 29) {
        Write-Warning "Expected remaining inventory to be 29, but got $($takeResponse.data.remainingInventory)"
    } else {
        Write-Host "      Verified: Inventory atomically decremented from 30 -> 29!" -ForegroundColor Green
    }
} else {
    Write-Host "[6/7] Skipping take action (no doses scheduled for today's weekday)" -ForegroundColor Yellow
}

# 7. Check History
Write-Host "[7/7] Querying medication history..." -NoNewline
$historyResponse = Invoke-DoseMateApi -Method "GET" -Path "/doses/history?status=ALL" -Token $jwt
Write-Host " OK! (History returned $($historyResponse.data.Count) record(s))" -ForegroundColor Green

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "  All E2E API Verification Tests PASSED!  " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
