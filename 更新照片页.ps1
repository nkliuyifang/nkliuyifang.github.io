param([string]$SiteRoot = $PSScriptRoot)
$photosRoot = Join-Path $SiteRoot '照片_files'
$outputPath = Join-Path $photosRoot 'photo-data.js'
$events = @(
    Get-ChildItem -LiteralPath $photosRoot -Directory | ForEach-Object {
        if ($_.Name -match '^(?<year>\d{4})-(?<month>\d{2})-(?<slug>.+)$') {
            $year = $Matches['year']
            $month = $Matches['month']
            $slug = $Matches['slug']
            switch ($slug) {
                'sam3d-discussion' { $title = 'SAM3D 交流讨论' }
                'new-year-dinner' { $title = '元旦聚餐' }
                'cvpr-conference' { $title = "CVPR ${year} 会议" }
                'icra-conference' { $title = "ICRA ${year} 会议" }
                'eccv-conference' { $title = "ECCV ${year} 会议" }
                'aaai-conference' { $title = "AAAI ${year} 会议" }
                'iccv-conference' { $title = "ICCV ${year} 会议" }
                'acmmm-conference' { $title = "ACM MM ${year} 会议" }
                default { $title = $slug }
            }
            $images = @(
                Get-ChildItem -LiteralPath $_.FullName -File |
                    Where-Object { $_.Extension -match '^\.(jpg|jpeg|png|webp)$' } |
                    Sort-Object Name |
                    ForEach-Object {
                        [PSCustomObject]@{
                            src = './照片_files/' + $_.Directory.Name + '/' + $_.Name
                            alt = $title
                        }
                    }
            )
            if ($images.Count -gt 0) {
                [PSCustomObject]@{
                    sortKey = "$year-$month"
                    title = $title
                    date = "${year}年$([int]$month)月"
                    images = $images
                }
            }
        }
    } | Sort-Object sortKey -Descending
)
$json = $events | ConvertTo-Json -Depth 6 -Compress
[IO.File]::WriteAllText($outputPath, "window.photoEvents = $json;`n", (New-Object Text.UTF8Encoding($false)))
$total = ($events | ForEach-Object { $_.images.Count } | Measure-Object -Sum).Sum
Write-Output "已生成 photo-data.js，共 $($events.Count) 个活动、$total 张照片。"
