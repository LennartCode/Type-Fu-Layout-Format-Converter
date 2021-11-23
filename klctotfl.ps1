[CmdletBinding()]
param (
    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Enter the path to the .klc file:'
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $klcFilePath,

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Path to the to-be-created .tfl file:'
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $tflFilePath
)


# Test the path to the .klc file
if (-not ($klcFile -like '*.klc' -and (Test-Path -Path $klcFilePath -PathType Leaf -IsValid))) {
    throw "'$klcFile' is not a path to a .klc file!"
}

[String[]]$fileContents = Get-Content -Path $klcFile


# Test the path to the .tfl file
if (-not (Test-Path -Path $tflFilePath -PathType Leaf -IsValid)) {
    throw "'$tflFilePath' is not a path to a .tfl file!"
}

function Get-TFLKeyEncodingFromSC {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Enter the scancode of the key you want to get the tfl encoding for. See https://en.wikipedia.org/wiki/Scancode'
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $scancode
    )

    # Prefix a 0 if necessary
    if ($scancode.Length -lt 3) {
        $scancode = '0' + $scancode
    }

    $table = @{
        # Order on ISO QWERTZ

        # Numbers row
        '029'   = 'Backquote'
        '002'   = 'Digit1'
        '003'   = 'Digit2'
        '004'   = 'Digit3'
        '005'   = 'Digit4'
        '006'   = 'Digit5'
        '007'   = 'Digit6'
        '008'   = 'Digit7'
        '009'   = 'Digit8'
        '00a'   = 'Digit9'
        '00b'   = 'Digit0'
        '00c'   = 'Minus'
        '00d'   = 'Equal'
        '00e'   = 'BACKSPACE' # Unused

        # QWERTZ row
        '00f'   = 'TAB' # Unused
        '010'   = 'KeyQ'
        '011'   = 'KeyW'
        '012'   = 'KeyE'
        '013'   = 'KeyR'
        '014'   = 'KeyT'
        '015'   = 'KeyY'
        '016'   = 'KeyU'
        '017'   = 'KeyI'
        '018'   = 'KeyO'
        '019'   = 'KeyP'
        '01a'   = 'BracketLeft'
        '01b'   = 'BracketRight'
        '01c'   = 'ENTER' # Unused

        # ASDFGH row
        '03a'   = 'CAPS' # Unused
        '01e'   = 'KeyA'
        '01f'   = 'KeyS'
        '020'   = 'KeyD'
        '021'   = 'KeyF'
        '022'   = 'KeyG'
        '023'   = 'KeyH'
        '024'   = 'KeyJ'
        '025'   = 'KeyK'
        '026'   = 'KeyL'
        '027'   = 'Semicolon'
        '028'   = 'Quote'
        '02b'   = 'Backslash'

        #YXCVBN row
        '02a'   = 'LSHIFT' # Unused
        '056'   = 'IntlBackslash'
        '02c'   = 'KeyZ'
        '02d'   = 'KeyX'
        '02e'   = 'KeyC'
        '02f'   = 'KeyV'
        '030'   = 'KeyB'
        '031'   = 'KeyN'
        '032'   = 'KeyM'
        '033'   = 'Comma'
        '034'   = 'Period'
        '035'   = 'Slash'
        '136'   = 'RSHIFT' # Unused

        # Control row
        '01D'   = 'LCONTROL' # Unused
        '15B'   = 'LWIN' # Unused
        '038'   = 'LALT' # Unused
        '039'   = 'Space'
        # ALT GR is LCONTROL(down) RALT(down) LCONTROL(up) RALT(up) # Unused
        '138'   = 'RALT' # Unused
        '15C'   = 'RWIN' # Unused
        '15D'   = 'APPSKEY' # Rightclick-Key # Unused
        '11D'   = 'RCONTROL' # Unused

        # Function Keys row
        '001'   = 'Escape' # Unused
        '03b'   = 'F1' # Unused
        '03c'   = 'F2' # Unused
        '03d'   = 'F3' # Unused
        '03e'   = 'F4' # Unused
        '03f'   = 'F5' # Unused
        '040'   = 'F6' # Unused
        '041'   = 'F7' # Unused
        '042'   = 'F8' # Unused
        '043'   = 'F9' # Unused
        '044'   = 'F10' # Unused
        '057'   = 'F11' # Unused
        '058'   = 'F12' # Unused

        # Navigation column
        '137'   = 'PRINTSCREEN' # Unused
        '046'   = 'SCROLLLOCK' # Unused
        '045'   = 'PAUSE' # Unused
        '152'   = 'INSERT' # Unused
        '147'   = 'HOME' # POS1 # Unused
        '149'   = 'PAGEUP' # Unused
        '153'   = 'DELETE' # Unused
        '14f'   = 'END' # Unused
        '151'   = 'PAGEDOWN' # Unused
        '14B'   = 'LEFT' # Unused
        '148'   = 'UP' # Unused
        '150'   = 'DOWN' # Unused
        '14d'   = 'RIGHT' # Unused
        
        # Num block
        '145'   = 'NUMLOCK' # Unused
        '135'   = 'NUMPADDIVIDE' # Unused
        '037'   = 'NUMPADMULTIPLY' # Unused
        '04a'   = 'NUMPADSUBSTRACT' # Unused
        '047'   = 'NUMPAD7' # Unused
        '048'   = 'NUMPAD8' # Unused
        '049'   = 'NUMPAD9' # Unused
        '04e'   = 'NUMPADADD' # Unused
        '04b'   = 'NUMPAD4' # Unused
        '04c'   = 'NUMPAD5' # Unused
        '04d'   = 'NUMPAD6' # Unused
        '04f'   = 'NUMPAD1' # Unused
        '050'   = 'NUMPAD2' # Unused
        '051'   = 'NUMPAD3' # Unused
        '11c'   = 'NUMPADENTER' # Unused
        '052'   = 'NUMPAD0' # Unused
        '053'   = 'NUMPADDOT' # Unused

        # Cherry function keys
        '121 a' = 'Launch_App2' # Unused
        '16C a' = 'Launch_Mail' # Unused
        '132 a' = 'Browser_Home' # Unused
    }

    if ($null -eq $table.$scancode) {
        throw "The scancode '$scancode' is not in the table! Please make sure, that Type Fu supports this special key."
    }


    return $table.$scancode    
}








# Get layout metadata
[String]$layoutName = ($fileContents | Where-Object { $_ -like 'KBD*' }).Split("`t")[1]
[String]$layoutDescription = ($fileContents | Where-Object { $_ -like 'KBD*' }).Split("`t")[2].Replace('"', '')
[String]$layoutVersion = ($fileContents | Where-Object { $_ -like 'VERSION*' }).Split("`t")[1]

# Unused features of the .klc file
# [String]$layoutCopyright = ($fileContents | Where-Object { $_ -like 'COPYRIGHT*' }).Split("`t")[1].Replace('"', '')
# [String]$layoutCompany = ($fileContents | Where-Object { $_ -like 'COMPANY*' }).Split("`t")[1].Replace('"', '')
# [String]$layoutLocaleName = ($fileContents | Where-Object { $_ -like 'LOCALENAME*' }).Split("`t")[1].Replace('"', '')
# [String]$layoutLocaleID = ($fileContents | Where-Object { $_ -like 'LOCALEID*' }).Split("`t")[1].Replace('"', '')



# Get the KeyMapTable

# Count indices
[Int]$kmpStart = 0
[Int]$kmpEnd = 0

for ($i = 0; $i -lt $fileContents.Count; $i++) {
    if ($fileContents[$i] -like '//SC*') {
        $kmpStart = $i + 3
    } elseif ($fileContents[$i] -like 'KEYNAME') {
        $kmpEnd = $i - 3
    }
}

[String[]]$keyMapTableString = $fileContents[$kmpStart..$kmpEnd]

[PSCustomObject[]]$keyMapTable = @()
foreach ($entry in $keyMapTableString) {
    [String[]]$row = $entry.Split("`t")
    if ($null -ne $row[10]) {
        $commentArr = $row[10].Replace('// ', '') -Split (', ')
        $comments = [PSCustomObject]@{
            Base            = $commentArr[0]
            Shift           = $commentArr[1]
            Control         = $commentArr[2]
            ControlAlt      = $commentArr[3]
            ShiftControlAlt = $commentArr[4]
        }
    } else {
        $comments = $null
    }
    

    $keyMapTable += [PSCustomObject]@{
        Scancode        = $row[0]
        VirtualKeyCode  = $row[1]
        Cap             = $row[3]
        Base            = $row[4]
        Shift           = $row[5]
        Control         = $row[6]
        ControlAlt      = $row[7]
        ShiftControlAlt = $row[8]
        Comments        = $comments
    }
}






# Generate new objects to be exported to JSON
$keys = New-Object -TypeName PSObject

foreach ($keymapTableEntry in $keyMapTable) {
    $key = New-Object -TypeName PSObject

    # One instance of a KeyProfile
    $defaultkeyProfile = New-Object -TypeName PSCustomObject

    if ($null -ne $keymapTableEntry.Base -and $keymapTableEntry.Base -ne '' -and $keymapTableEntry.Base -ne -1) {
        if ($keymapTableEntry.Base.Length -gt 1) {
            [String]$symbol = [Char][Int]"0x$($keymapTableEntry.Base)"
        } else {
            [String]$symbol = $keymapTableEntry.Base
        }
        $defaultkeyProfile | Add-Member -NotePropertyMembers @{'base' = $symbol }
    }

    if ($null -ne $keymapTableEntry.Shift -and $keymapTableEntry.Shift -ne '' -and $keymapTableEntry.Shift -ne -1) {
        if ($keymapTableEntry.Shift.Length -gt 1) {
            [String]$symbol = [Char][Int]"0x$($keymapTableEntry.Shift)"
        } else {
            [String]$symbol = $keymapTableEntry.Shift
        }
        $defaultkeyProfile | Add-Member -NotePropertyMembers @{'shift' = $symbol }
    }

    if ($null -ne $keymapTableEntry.ControlAlt -and $keymapTableEntry.ControlAlt -ne '' -and $keymapTableEntry.ControlAlt -ne -1) {
        if ($keymapTableEntry.ControlAlt.Length -gt 1) {
            [String]$symbol = [Char][Int]"0x$($keymapTableEntry.ControlAlt)"
        } else {
            [String]$symbol = $keymapTableEntry.ControlAlt
        }
        $defaultkeyProfile | Add-Member -NotePropertyMembers @{'alt' = $symbol }
    }

    if ($null -ne $keymapTableEntry.ShiftControlAlt -and $keymapTableEntry.ShiftControlAlt -ne '' -and $keymapTableEntry.ShiftControlAlt -ne -1) {
        if ($keymapTableEntry.ShiftControlAlt.Length -gt 1) {
            [String]$symbol = [Char][Int]"0x$($keymapTableEntry.ShiftControlAlt)"
        } else {
            [String]$symbol = $keymapTableEntry.ShiftControlAlt
        }
        $defaultkeyProfile | Add-Member -NotePropertyMembers @{'altShift' = $symbol }
    }
    
    [System.Collections.IDictionary]$keyProfiles = [ordered]@{default = $defaultkeyProfile }
    # add different profiles using
    # ; ^ = â; ´ = á

    
    $key | Add-Member -NotePropertyMembers $keyProfiles
    $tflEncoding = Get-TFLKeyEncodingFromSC -scancode $keymapTableEntry.Scancode
    $keys | Add-Member -NotePropertyMembers ([ordered]@{ $tflEncoding = $key })
}





$jsonOutput = [PSCustomObject][ordered]@{
    id          = "$layoutName-v$layoutVersion"
    name        = $layoutName
    description = $layoutDescription
    version     = [Int]$layoutVersion.Split('.')[0]
    keys        = $keys
}


$jsonOutputUnescaped = $jsonOutput | ConvertTo-Json -Depth 10 | ForEach-Object { if ($_ -notlike '\' -or $_ -notlike '"') { [System.Text.RegularExpressions.Regex]::Unescape($_) } else { $_ } }
$jsonOutputEscaped = $jsonOutputUnescaped.Replace('\', '\\').Replace('"""', '"\""')
$jsonOutputEscaped | Out-File -FilePath $tflFilePath -Force
