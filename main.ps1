function logo {
cls
write-host "
 _____ _  _     ____     _       __    ____ ____  ___
|  ___|_|| |   |    |   | |     /  \  / __||    ||   |
|  __| | | |   | ._||   | |   ./ () \/ (   | ._||| O /
| |  | | | |__ | ___|   | |__ \     /\  \_ |  __||   \
|_|  |_| |____||___|    |____| \___/  \___||____||_/\_\

" -ForegroundColor Yellow
}

while ($true)
{
    function dec ($bb)
    {
        
        if ($bb.Length -gt 32)
        {
            $mac = $bb[-20..-1]
            $bb = $bb[0..($bb.length - 21)]
            $hmac = New-Object System.Security.Cryptography.HMACSHA1
            $hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($key)
            $exp = $hmac.ComputeHash($bb)
            if (@(Compare-Object $mac $exp -Sync 0).Length -ne 0)
            {
                return
            }
                
            $iv = $bb[0..15]
            $enc = New-Object System.Security.Cryptography.AesCryptoServiceProvider
            $enc.Mode = "CBC"
            $enc.Key = [System.Text.Encoding]::utf8.GetBytes($key)
            $enc.IV = $iv
            $byteee = ($enc.CreateDecryptor()).TransformFinalBlock(($bb[16..$bb.length]), 0, $bb.length-16)
            
            [System.Text.Encoding]::UTF8.GetString($byteee)
        }
    }
    function enc ($b)
    {
        $b = [System.Text.Encoding]::UTF8.GetBytes($b)
        $iv = [byte] 0..255 |Get-Random -Count 16
        $enc = New-Object System.Security.Cryptography.AesCryptoServiceProvider;
        $enc.Mode = "CBC";
        $enc.Key = [System.Text.Encoding]::UTF8.GetBytes($key);
        $enc.IV = $iv;
        $txt = $iv + ($enc.CreateEncryptor()).TransformFinalBlock($b, 0, $b.Length);
        $mac = New-Object System.Security.Cryptography.HMACSHA1;
        $mac.Key = [System.Text.Encoding]::utf8.GetBytes($key);
        $txt + $mac.ComputeHash($txt);
    }
    logo
    "

    (1) Lock
    (2) Unlock
    "
    $ch = Read-Host
    if ($ch -eq 1)
    {
        logo
        "Select file to encrypt"
        sleep 1
        Add-Type -AssemblyName system.windows.forms -ErrorAction SilentlyContinue|Out-Null
        $obj = New-Object System.Windows.Forms.OpenFileDialog
        $nil = $obj.ShowDialog()
        if (!([string]::IsNullOrEmpty($obj.FileName)))
        {
            if (Test-Path $obj.FileName)
            {
                $pass = Read-Host "Password"
                if (($pass -ne $null) -and ($pass.Length -ge 16))
                {
                    logo 
                    "===Encrypting===

                    "
                    Write-Host "[+] Reading file" -ForegroundColor Cyan
                    [byte[]] $cont = cat $obj.FileName -Encoding Byte
                    $key = $pass
                    Write-Host "[+] Encrypting content" -ForegroundColor Cyan
                    $enc = enc -b $cont
                    Write-Host "[+] Writing file" -ForegroundColor Cyan
                    $tmp = $enc -join (' ')
                    $tmp >"$($obj.FileName).locked"
                    Write-Host "[+] done" -ForegroundColor Green
			# ri "$($obj.filename)"
                    pause
                    
                } else {
                    Write-Host "[-] password too short" -ForegroundColor White -BackgroundColor Red
                    pause   
                }
            } else {
                Write-Host "[-] File not found" -ForegroundColor White -BackgroundColor Red
                pause   
            }
        } else {
            Write-Host "[-] nothing selected" -ForegroundColor White -BackgroundColor Red
            pause
        }
    } elseif ($ch -eq 2) 
    {
        Add-Type -AssemblyName system.windows.forms -ErrorAction SilentlyContinue|Out-Null
        logo
        "Select the file"
        sleep 1
        $obj = New-Object System.Windows.Forms.OpenFileDialog
        $nil = $obj.ShowDialog()
        if (!([string]::IsNullOrEmpty($obj.FileName)))
        {
            if (Test-Path $obj.FileName)
            {
                $pass = Read-Host "Password"
                if (($pass -ne $null) -and ($pass.Length -ge 16))
                {
                    logo
                    "===Decrypting===
                    "
                    Write-Host "[+] Reading file" -ForegroundColor Cyan
                    $cont = cat $obj.FileName -Encoding String
                    $key = $pass
                    Write-Host "[+] Decrypting Content" -ForegroundColor Cyan
                    $tmp = $cont -split (' ')
                    $dec = dec -bb $tmp
                    Write-Host "[+] Writing file" -ForegroundColor Cyan
                    $orginal = $obj.FileName.Split('.')
                    $count = $orginal.Count
                    $orginal = $orginal.Replace($orginal[$count-1],'')
                    $orginall = $null
                    $i=0
                    foreach ($tmp in $orginal)
                    {
                        if ($i -eq 0)
                        {
                            $orginall+="$tmp"
                        } else {
                            $orginal+=".$tmp"
                        }
                        $i++
                    }
                    [string]$bb = $dec
                    [byte[]]$b = $bb -split ' '
					[system.io.file]::writeallbytes($orginal, $b)
                    Write-Host "[+] Done" -ForegroundColor Green
                    pause
                } else {
                    Write-Host "[-] password too short" -ForegroundColor White -BackgroundColor Red
                    pause   
                }
            } else {
                Write-Host "[-] File not found" -ForegroundColor White -BackgroundColor Red
                pause   
            }
        } else {
            Write-Host "[-] nothing selected" -ForegroundColor White -BackgroundColor Red
            pause
        }
    }
}

