Function Start-PowerShellGuide {
    <#
    .SYNOPSIS
    Provides a terminal interface for the PowerShell Guide
    
    .DESCRIPTION
    Provides a terminal interface for the PowerShell Guide
    
    .EXAMPLE
    Start-PowerShellGuide
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    [Alias('Start-PSGuide')]
    param()

    begin {
        $banner = @'
DDDDDD  OOOOOOO N     N ''' TTTTTTT   PPPPPP     A    N     N III  CCCCC  
D     D O     O NN    N '''    T      P     P   A A   NN    N  I  C     C 
D     D O     O N N   N  '     T      P     P  A   A  N N   N  I  C       
D     D O     O N  N  N '      T      PPPPPP  A     A N  N  N  I  C       
D     D O     O N   N N        T      P       AAAAAAA N   N N  I  C       
D     D O     O N    NN        T      P       A     A N    NN  I  C     C 
DDDDDD  OOOOOOO N     N        T      P       A     A N     N III  CCCCC  

'@
        Function Get-ArraySearch {
            [CmdletBinding()]
            param(
                [array]$Array,
                [string]$SearchTerm
            )

            $matches = $Array | ForEach-Object {
                $match = [Regex]::Match($_.ToLower(), $SearchTerm.ToLower())
                ($match.Length / $_.Length) * 100
            }
            $matches | Sort-Object | Select-Object -Last 1
        }

        Function Get-StringSearch {
            [CmdletBinding()]
            param(
                [string]$String,
                [string]$SearchTerm
            )

            $match = [Regex]::Match($String.ToLower(), $SearchTerm.ToLower())
            ($match.Length / $String.Length) * 100
        }

        Function Get-StringMatches {
            [CmdletBinding()]
            param(
                [string]$String,
                [string]$SearchTerm
            )

            ([Regex]::Matches($String.ToLower(), $SearchTerm.ToLower()) | Measure-Object).Count
        }

        Function Get-SearchRanking {
            [CmdletBinding()]
            param(
                [object]$Topic,
                [string]$SearchTerm
            )
            $alias = Get-ArraySearch $Topic.Aliases $SearchTerm
            $categories = Get-ArraySearch $Topic.RelativePath.Split('\') $SearchTerm
            $topicName = Get-StringSearch $Topic.TopicName $SearchTerm
            $content = Get-StringMatches $topic.Content $SearchTerm
            $alias + $categories + $topicName + $content
        }

        Function Get-SearchResults {
            [CmdletBinding()]
            param(
                $SearchTerm
            )
            $AllTopics = (Get-PowerShellGuide).AllTopics
            $ReturnData = [pscustomobject]@{
                Value   = $null
                Type    = 'Search'
                Related = $null
            }
            $foundTopics = $AllTopics | Where-Object { $_.TopicName -match "^$($SearchTerm)$" }

            if ($foundTopics.Count -eq 1) {
                $ReturnData.Value = $foundTopics
                $ReturnData.Type = 'Content'
                $ReturnData.Related = @($AllTopics | Where-Object { (Split-Path $_.RelativePath) -eq (Split-Path $foundTopics.RelativePath) -and 
                        $_.TopicName -ne $foundTopics.TopicName }).TopicName
            }
            else {
                $foundTopics = $AllTopics | Select-Object @{l = 'SearchRanking'; e = { Get-SearchRanking $_ $SearchTerm } }, * | 
                Sort-Object SearchRanking -Descending | Where-Object { $_.SearchRanking -gt 0 }
    
                if ($foundTopics) {
                    $ReturnData.Value = $foundTopics.TopicName
                }
                else {
                    $ReturnData.Value = "No topics found"
                }
            }
            $ReturnData
        }

        Function Get-AllTopics {
            [CmdletBinding()]
            param(
                $Topics,
                $Parent = ''
            )
            Function GetPath {
                param(
                    $RelativePath,
                    $Parent
                )
                $path = (Split-Path $RelativePath) -Replace ("^$([regex]::Escape($Parent))", '')
                if ($path.IndexOf('\') -eq 0) {
                    $path = $path.Substring(1)
                }
                $path.Split('\')[0]
            }
    
            $Spacer = ' ' * (($Parent.Split('\').Count - 1) * 2)
            $TopicGroups = $Topics | Group-Object { (GetPath $_.RelativePath $Parent) } | Sort-Object Name
            $TopicGroups | Where-Object { [string]::IsNullOrEmpty($_.Name) } | ForEach-Object {
                [pscustomobject]@{Spacer = $Spacer; Title = $($Parent.Split('\')[-1]); Type = 'Category' }
                $_.Group | ForEach-Object {
                    [pscustomobject]@{Spacer = $Spacer; Title = $_.TopicName; Type = 'Topic' }
                }
            }
            $TopicGroups | Where-Object { -not [string]::IsNullOrEmpty($_.Name) } | ForEach-Object {
                $NewParent = $_.Name
                if (-not [string]::IsNullOrEmpty($Parent)) {
                    $NewParent = $Parent + '\' + $_.Name
                }
                Get-AllTopics -Topics $_.Group -Parent $NewParent
            }
        }

        Function Write-AllTopics {
            [CmdletBinding()]
            param()
            $AllTopics = (Get-PowerShellGuide).AllTopics | Where-Object { $_.RelativePath -match '\\' }
            $ToC = Get-AllTopics -Topics $AllTopics

            $i = 1
            $menuItems = foreach ($item in $ToC) {
                if ($item.Type -eq 'Category') {
                    Write-Host "$($item.Spacer)$($item.Title)" -ForegroundColor Yellow
                }
                else {
                    Write-Host "$($item.Spacer) $($i) $($item.Title)"
                    $item
                    $i++
                }
            }

            $Selection = Read-Host -Prompt "Enter a number to select a topic"
            if (-not [string]::IsNullOrEmpty($Selection)) {
                $d = 0
                if ([int]::TryParse($Selection, [ref]$d)) {
                    if ($d -lt $i) {
                        $Selection = $menuItems[$Selection - 1].Title
                    }
                }
            }
            $Selection
        }

        Function Read-ChoicePrompt {
            [CmdletBinding()]
            param(
                [array]$array,
                [string]$Prompt
            )
            $i = 1
            $menu = ($array | ForEach-Object { "$i - $_"; $i++ }) -join ([Environment]::NewLine)
            $Selection = Read-Host "`n$($menu)`n$($Prompt)"
            if (-not [string]::IsNullOrEmpty($Selection)) {
                $d = 0
                if ([int]::TryParse($Selection, [ref]$d)) {
                    if ($d -lt $i) {
                        $Selection = @($array)[$Selection - 1]
                    }
                }
            }
            $Selection
        }


        Write-Host $banner
        $DefaultPrompt = "Enter a new topic to explore (? for Help)"
        $selection = '?'
    }

    process {
        while ($selection -ne 'Q') {
            $Prompt = $DefaultPrompt
            $SkipPrompt = $false
            if ($selection -eq 'A') {
                $selection = Write-AllTopics
                $SkipPrompt = $true
            }
            elseif ($selection -eq 'R') {
                $selection = ((Get-PowerShellGuide).AllTopics | Get-Random).TopicName
                $SkipPrompt = $true
            }
            elseif ($selection -eq 'T') {
                $selection = Read-ChoicePrompt -array $data.Related -Prompt "Select another topic in this category"
                $SkipPrompt = $true
            }
            elseif ($selection -eq '?' -or [regex]::Replace($selection, "[^0-9a-zA-Z\s]", "") -in 'h', 'help') {
                $options = @(
                    [PSCustomObject]@{Char = 'R'; Value = 'Random topic' }
                    [PSCustomObject]@{Char = 'A'; Value = 'View all topics' }
                    [PSCustomObject]@{Char = 'Q'; Value = 'Quit' }
                    [PSCustomObject]@{Char = '?'; Value = 'Help' }
                )
                $optionsMenu = ($options | ForEach-Object {
                        "$([char]0x001b)[93m[$($_.Char)]$([char]0x001b)[0m $($_.Value)"
                    } ) -join (' ' * 4)
                $Prompt = "Enter a word to search all topics or enter one of the options"
                Write-Host $optionsMenu
            }
            else {
                $data = Get-SearchResults $selection
                if ($data.Type -eq 'Content') {
                    $data.Value
                    if ($data.Related) {
                        $Prompt = "Enter a new topic or enter [T] to view related topics"
                    }
                }
                else {
                    $selection = Read-ChoicePrompt -array $data.Value -Prompt "Select topic to view"
                    $SkipPrompt = $true
                }
            }
            if (-not $SkipPrompt) {
                $selection = Read-Host -Prompt $Prompt
            }
            Clear-Host
        }
    }
}
