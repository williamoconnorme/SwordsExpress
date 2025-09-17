param(
  [Parameter(Mandatory=$false)]
  [string]$TimetablesFolder = (Split-Path -Parent $MyInvocation.MyCommand.Path),
  [string]$OutputJsonPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Path)/timetables.json"
)

if (-not (Test-Path $TimetablesFolder)) {
  throw "Folder not found: $TimetablesFolder"
}

Add-Type -AssemblyName Microsoft.VisualBasic

function Parse-TimetableCsv {
  param(
    [Parameter(Mandatory=$true)][string]$Path
  )

  $parser = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($Path)
  $parser.SetDelimiters(',')
  $parser.HasFieldsEnclosedInQuotes = $true

  $headerFields = $parser.ReadFields()
  if (-not $headerFields) {
    $parser.Close()
    throw "CSV appears empty: $Path"
  }

  $routes = $headerFields[1..($headerFields.Length-1)]
  $stops = [ordered]@{}

  while (-not $parser.EndOfData) {
    $row = $parser.ReadFields()
    if (-not $row) { continue }
    $stopName = $row[0].Trim()
    if ([string]::IsNullOrWhiteSpace($stopName)) { continue }

    $key = ($stopName.ToLower() -replace "'", '' -replace ' ', '-')
    $times = @()

    for ($i = 1; $i -lt $row.Length; $i++) {
      $timeVal = $row[$i].Trim()
      if ([string]::IsNullOrWhiteSpace($timeVal)) { continue }
      $routeName = $routes[$i - 1]
      $times += [pscustomobject]@{
        route = $routeName
        time  = $timeVal
      }
    }

    $stops[$key] = [pscustomobject]@{
      name  = $stopName
      times = $times
    }
  }

  $parser.Close()
  return $stops
}

# Master structure
$data = [ordered]@{
  toCity   = [ordered]@{
    weekday  = @{}
    saturday = @{}
    sunday   = @{}
  }
  toSwords = [ordered]@{
    weekday  = @{}
    saturday = @{}
    sunday   = @{}
  }
}

$pattern = '^timetable-(?<direction>toCity|toSwords)-(?<day>weekday|saturday|sunday)\.csv$'

Get-ChildItem -Path $TimetablesFolder -File -Filter 'timetable-*.csv' | ForEach-Object {
  $m = [regex]::Match($_.Name, $pattern, 'IgnoreCase')
  if (-not $m.Success) {
    Write-Warning "Skipping unrecognized file name pattern: $($_.Name)"
    return
  }
  $direction = $m.Groups['direction'].Value
  $day = $m.Groups['day'].Value

  Write-Host "Processing $($_.Name) -> $direction / $day"
  $parsed = Parse-TimetableCsv -Path $_.FullName
  $data[$direction][$day] = $parsed
}

# Remove empty buckets (in case some missing)
foreach ($dirKey in @('toCity','toSwords')) {
  foreach ($dayKey in @('weekday','saturday','sunday')) {
    if (-not $data[$dirKey][$dayKey].Keys.Count) {
      $data[$dirKey].Remove($dayKey) | Out-Null
    }
  }
}

# Output JSON
($data | ConvertTo-Json -Depth 8) | Set-Content -Encoding UTF8 -Path $OutputJsonPath
Write-Host "Combined timetable JSON written to $OutputJsonPath"