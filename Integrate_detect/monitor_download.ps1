# Monitor BITS download and notify when complete
Write-Host "Monitoring Mistral 7B download..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop monitoring`n" -ForegroundColor Yellow

$jobName = "Mistral 7B Model"
$lastPercent = 0

while ($true) {
    try {
        $job = Get-BitsTransfer -Name $jobName -ErrorAction SilentlyContinue
        
        if (-not $job) {
            Write-Host "`n[ERROR] BITS job not found. It may have been removed or completed manually." -ForegroundColor Red
            break
        }
        
        $percent = if ($job.BytesTotal -gt 0) {
            [math]::Round(($job.BytesTransferred / $job.BytesTotal) * 100, 2)
        } else { 0 }
        
        $downloadedGB = [math]::Round($job.BytesTransferred / 1GB, 2)
        $totalGB = [math]::Round($job.BytesTotal / 1GB, 2)
        
        # Show progress update every 5%
        if ($percent -ge $lastPercent + 5) {
            Write-Host "[$([DateTime]::Now.ToString('HH:mm:ss'))] Progress: $percent% ($downloadedGB GB / $totalGB GB)" -ForegroundColor Green
            $lastPercent = $percent
        }
        
        # Check if complete
        if ($job.JobState -eq "Transferred") {
            Write-Host "`n========================================" -ForegroundColor Green
            Write-Host "✅ DOWNLOAD COMPLETE!" -ForegroundColor Green
            Write-Host "========================================`n" -ForegroundColor Green
            
            # Complete the job
            Complete-BitsTransfer -BitsJob $job
            
            Write-Host "File saved to: $($job.FileList[0].LocalName)" -ForegroundColor Cyan
            Write-Host "File size: $totalGB GB`n" -ForegroundColor Cyan
            
            # Verify file
            $filePath = $job.FileList[0].LocalName
            if (Test-Path $filePath) {
                $fileSize = (Get-Item $filePath).Length
                $fileSizeGB = [math]::Round($fileSize / 1GB, 2)
                Write-Host "✅ File verified: $fileSizeGB GB`n" -ForegroundColor Green
                
                Write-Host "========================================" -ForegroundColor Yellow
                Write-Host "NEXT STEPS:" -ForegroundColor Yellow
                Write-Host "========================================" -ForegroundColor Yellow
                Write-Host "1. Restart the backend server:" -ForegroundColor White
                Write-Host "   cd c:\Users\aryan\Desktop\snakebite_ai_assistant\Integrate_detect" -ForegroundColor Gray
                Write-Host "   python -m uvicorn app:app --host 0.0.0.0 --port 8000`n" -ForegroundColor Gray
                
                Write-Host "2. Look for this in the logs:" -ForegroundColor White
                Write-Host "   INFO:app:LLM model loaded with context size: 4096`n" -ForegroundColor Gray
                
                Write-Host "3. Test the chat endpoint or run the Flutter app!`n" -ForegroundColor White
                
                # Play notification sound
                [Console]::Beep(800, 300)
                [Console]::Beep(1000, 300)
                [Console]::Beep(1200, 500)
            } else {
                Write-Host "⚠️  Warning: File not found at expected location" -ForegroundColor Yellow
            }
            
            break
        }
        
        # Check for errors
        if ($job.JobState -eq "TransientError" -or $job.JobState -eq "Error") {
            Write-Host "`n[ERROR] Download failed: $($job.ErrorDescription)" -ForegroundColor Red
            Write-Host "Job will auto-retry. Continuing to monitor..." -ForegroundColor Yellow
        }
        
        # Wait before next check
        Start-Sleep -Seconds 10
        
    } catch {
        Write-Host "`n[ERROR] $($_.Exception.Message)" -ForegroundColor Red
        Start-Sleep -Seconds 10
    }
}

Write-Host "`nMonitoring stopped." -ForegroundColor Cyan
