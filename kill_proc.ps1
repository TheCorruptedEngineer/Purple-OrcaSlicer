$procs = Get-Process -Name "orca-slicer" -ErrorAction SilentlyContinue
if ($procs) {
    $procs | Stop-Process -Force
}
Start-Sleep -Seconds 2
Write-Host "Done"