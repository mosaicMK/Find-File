<#
.SYNOPSIS
Looks to see if a file path exists on a list of target computers.

.DESCRIPTION
The script will look for a text file that has computer names in the file and will look on each computer 
for the file path you specify. the script will write the computer name to a succes.txt file if the computer can be found

.PARAMETER FileToFind
use this to sepcify the path to the full file path to what you want to look for

.PARAMETER ComputerList
Use this to specify the list of computers to want to look for the file on

.EXAMPLE
Find-Files.ps1 -FileToFind C:\windows\notepad.exe -ComputerList Computers.txt

.NOTES
Created by: Kris Gross
Email: Contact@mosaicMK.com
Twitter: @kmgamd

.LINK
http://www.mosaicMK.com

#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$FileToFind,
    [Parameter(Mandatory=$true)]
    [string]$ComputerList,
    [Parameter(Mandatory=$true)]
    [string]$ResultsFile
    
    )

    #Looks for the computer list file
    If (Test-Path $ComputerList)
    {   
        if (!($ResultsFile)) {$ResultsFile = "Results.csv"}
        #Gets the content of the computer list file
        $Computers = Get-Content $ComputerList
        $ComputerCount = $Computers.Count
        $NumCount = 0
        #Replaces C:\ with c$\ so the script can reach the target computers
        $FilePath = $FileToFind.Replace("C:\","c$\")
        #Runs a set of actions for each computer in the computer list file
        Add-Content $ResultsFile "File to Find:, $FiletoFind"
        Add-Content $ResultsFile ""
        Add-Content $ResultsFile "Computer Name, File Status, Pingable"
        foreach ($Computer in $Computers)
        {
            $NumCount++
            Write-Progress "Looking for $FileToFind on $Computer" -Status "$NumCount of $ComputerCount"
            if ((Get-WmiObject Win32_PingStatus -Filter "Address='$Computer'").StatusCode -eq 0 ) 
            { 
                $PingStatus = "True"
                #If the script can find the file path will write the computer to a success.txt file
                If (Test-Path \\$Computer\c$\"Windows") {If (Test-Path \\$Computer\$FilePath) {$TestPath = "Found"} if (!(Test-Path \\$Computer\$FilePath)) {$TestPath = "Not Found"}}
                
                #If the script cannot find the file path will write the computer to a failed.txt file
                Add-Content $ResultsFile "$Computer, $TestPath, $PingStatus"
            }
            else
            {
                $PingStatus = "False"
                $TestPath = "Null"
                Add-Content $ResultsFile "$Computer, $TestPath, $PingStatus"
            }
        }
        Write-Output "Complete:"
        Write-Output "The script results can be found at $ResultsFile"
    }
    #If the computer list file is not found will write this error
    if (!(Test-Path $ComputerList)) {Write-Error "ERROR: Cannont find $ComputerList"}
