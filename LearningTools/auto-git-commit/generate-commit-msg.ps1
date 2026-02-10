# コミットメッセージ生成スクリプト
# git statusを基に詳細なコミットメッセージを生成

param(
    [string]$RepoPath = "."
)

# リポジトリパスに移動
Push-Location $RepoPath

try {
    # git statusを取得
    $statusOutput = git status --porcelain 2>&1
    $statusFull = git status 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git statusの実行に失敗しました: $statusOutput"
        return $null
    }
    
    # 変更がない場合
    if (-not $statusOutput -or $statusOutput -eq "") {
        return $null
    }
    
    # 変更ファイルを分類
    $addedFiles = @()
    $modifiedFiles = @()
    $deletedFiles = @()
    $renamedFiles = @()
    
    foreach ($line in $statusOutput -split "`n") {
        if ($line -match '^\s*([AMDR])\s+(.+)$') {
            $status = $matches[1]
            $file = $matches[2]
            
            switch ($status) {
                'A' { $addedFiles += $file }
                'M' { $modifiedFiles += $file }
                'D' { $deletedFiles += $file }
                'R' { $renamedFiles += $file }
            }
        }
        elseif ($line -match '^\s*([AMDR])\s+(.+?)\s+->\s+(.+)$') {
            # リネームの場合
            $oldFile = $matches[2]
            $newFile = $matches[3]
            $renamedFiles += "$oldFile -> $newFile"
        }
    }
    
    # 現在の日時を取得
    $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # コミットメッセージを生成
    $commitMessage = "Auto commit: $currentDateTime`n`n"
    
    # 変更内容のサマリー
    $commitMessage += "変更内容:`n"
    
    if ($addedFiles.Count -gt 0) {
        $commitMessage += "- 追加: $($addedFiles.Count)ファイル`n"
        if ($addedFiles.Count -le 10) {
            $commitMessage += "  " + ($addedFiles -join ", ") + "`n"
        } else {
            $commitMessage += "  " + ($addedFiles[0..9] -join ", ") + " ... 他$($addedFiles.Count - 10)ファイル`n"
        }
    }
    
    if ($modifiedFiles.Count -gt 0) {
        $commitMessage += "- 変更: $($modifiedFiles.Count)ファイル`n"
        if ($modifiedFiles.Count -le 10) {
            $commitMessage += "  " + ($modifiedFiles -join ", ") + "`n"
        } else {
            $commitMessage += "  " + ($modifiedFiles[0..9] -join ", ") + " ... 他$($modifiedFiles.Count - 10)ファイル`n"
        }
    }
    
    if ($deletedFiles.Count -gt 0) {
        $commitMessage += "- 削除: $($deletedFiles.Count)ファイル`n"
        if ($deletedFiles.Count -le 10) {
            $commitMessage += "  " + ($deletedFiles -join ", ") + "`n"
        } else {
            $commitMessage += "  " + ($deletedFiles[0..9] -join ", ") + " ... 他$($deletedFiles.Count - 10)ファイル`n"
        }
    }
    
    if ($renamedFiles.Count -gt 0) {
        $commitMessage += "- リネーム: $($renamedFiles.Count)ファイル`n"
        if ($renamedFiles.Count -le 10) {
            $commitMessage += "  " + ($renamedFiles -join ", ") + "`n"
        } else {
            $commitMessage += "  " + ($renamedFiles[0..9] -join ", ") + " ... 他$($renamedFiles.Count - 10)ファイル`n"
        }
    }
    
    $commitMessage += "`n詳細:`n"
    $commitMessage += $statusFull
    
    return $commitMessage
}
finally {
    Pop-Location
}
