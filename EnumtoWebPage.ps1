# Enum to html 
# Report info parameters
# Please include: Name, Device name, Competition level 
Param($Name, $Device, $Comp)

# Global def
$global:Break = '<br />'
# $global:ErrorActionPreference = 'SilentlyContinue'

# Try to create Site dir if it doesn't exist
try{
    mkdir Site
}catch{
}

# Remove old contents
rm Site\*

# HTML Formatting 
$html = "<HTML>" 
$Body = "<body>"
$End = "</body>
</HTML>"

# Style & Header
$Style = "<style>
#Device {float: left; padding: 0px 0px;}
#Author { float: left; padding: 0px 100px; }
#Device, #Author { display: inline;}
#Content { float: center; clear:both;} 
a:link { color: #000000;}
a:visited { color: #000000;}
h1, h5, th { text-align: center; font-family: Segoe UI;}
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; max-width: 600px; text-wrap:normal; word-wrap:break-word }
tr { background: #b8d1f3; }
tr:nth-child(even){ background: #dae5f4; }
p { text-align: center;}
.Summary { margin: auto; overflow: hidden;}
iframe { margin: auto; width: 1200; height: 400; display:block; border: 0px;}
</style>"

$Nav = "<table style=`"font-color: #000000;`"><tr><th><a href=`"Index.html`">Home</a></th><th><a href=`"Processes.html`"> Processes </a></th><th><a href=`"Services.html`"> Services </a></th><th><a href=`"Local.html`"> Local Accounts </a></th>`
<th><a href=`"Tasks.html`">Tasks</a></th><th><a href=`"Network.html`"> Network </a></th><th><a href=`"AD.html`">Active Directory</a></th></tr></table>"


# Create divs
$DivDevice = "<div id=Device>"
$DivAuth = "<div id=Author>"
$DivContent = "<div id=Content>"
$DivEnd = "</div>"

# Author Information
$Author = "<h2> Author: $Name </h2>
<h2> Device: $Device </h2>
 <h2> Competition: $Comp </h2>
 <br />"

# Device information
 $Device = Get-CimInstance CIM_ComputerSystem 
 $DeviceInfo = "<h2> Device Name: "+$Device.Name+" </h2>
 <h2> Roles: "+$Device.Roles+" </h2>
 <h2> Domain: "+$Device.Domain+" </h2>
 <h2> User: "+$Device.UserName+" </h2>"

# Date & time 
$Date = "<h1> Enumeration Started $(Get-Date) </h1>"

# Compile header
$Header = $html + "<head>" + $Style + $Date + $Nav + $DivAuth + $Author + $DivEnd + $DivDevice + $DeviceInfo + $DivEnd + "</head>"

# Send header to index.html
 $Header >> Site/Index.html

# General information

# Process information
     $Header + $Body >> Site/Processes.html
     # "<div id=Processes>" >> Site/Processes.html
     $DivContent >> Site/Processes.html
     "<h1>PROCESSES</h1> " >> Site/Processes.html
     Get-CimInstance Win32_Process | Select-Object ProcessName, Path, CreationDate, CommandLine | ConvertTo-HTML -Fragment -As Table >> Site/Processes.html
     "</div>" >> Site/Processes.html
     $DivEnd >> Site/Processes.html
     $End >> Site/Processes.html

# Service Information
     $Header + $Body >> Site/Services.html
     $DivContent >> Site/Services.html
     "<h1> SERVICES </h1>" >> Site/Services.html
     Get-CimInstance Win32_Service | Select-Object Name, PathName, Caption, Description, State | ConvertTo-HTML -Fragment -As Table >> Site/Services.html
     $DivEnd >> Site/Services.html
     $End >> Site/Services.html

# Local User information
    $Header + $Body >> Site/Local.html
    $DivContent >> Site/Local.html
    "<h1> LOCAL USERS </h1>" >> Site/Local.html
    Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordRequired, Description, SID | ConvertTo-HTML -Fragment >> Site/Local.html
    "<h1> LOCAL GROUPS </h1>" >> Site/Local.html
    Get-LocalGroup | Select-Object Name, Description, SID | ConvertTo-HTML -Fragment >> Site/Local.html
    $DivEnd >> Site/Local.html
    $End >> Site/Local.html

# Task Information
    $Header + $Body >> Site/Tasks.html
    $DivContent >> Site/Tasks.html
    "<h1> SCHEDULED TASKS </h1>" >> Site/Tasks.html
    Get-ScheduledTask |Select-Object TaskName, Author, State, Description, TaskPath | ConvertTo-HTML -Fragment -As Table >> Site/Tasks.html
    $DivEnd >> Site/Tasks.html
    $End >> Site/Tasks.html

# Network information
# Not compatible w/ devices older than Win 8
    $Header + $Body >> Site/Network.html
    $DivContent >> Site/Network.html
    "<h1> NETWORK </h1>" >> Site/Network.html
    "<h1> Established Connections </h1>" >> Site/Network.html
    Get-NetTCPConnection | ? State -eq "Established" | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, CreationTime | ConvertTo-HTML -Fragment -As Table >> Site/Network.html
    $break >> Site/Network.html
    "<h1> Listening Connections </h1>" >> Site/Network.html
    Get-NetTCPConnection | ? State -eq "Listen" | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, CreationTime | ConvertTo-HTML -Fragment -As Table >> Site/Network.html
    $break >> Site/Network.html
    "<h1> Full Information </h1>" >> Site/Network.html
    Get-NetTCPConnection | Select-Object State, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, CreationTime | ConvertTo-HTML -Fragment -As Table >> Site/Network.html
    $DivEnd >> Site/Network.html
    $End >> Site/Network.html


# Active Directory Enumeration
 $header >> Site/AD.html
try{
    if((Get-WindowsFeature | ? DisplayName -match 'Active Directory Domain Services' | Select-Object -Property InstallState)){
        try{
             $DivContent >> Site/AD.html
             "<h1> ACTIVE DIRECTORY SERVER INFORMATION </h1>" >> Site/AD.html
             "<br />" >> Site/AD.html


            # Get Domain info
             "<h1> DOMAIN INFORMATION </h1>" >> Site/AD.html
            get-addomain | ConvertTo-HTML -Fragment -As Table >> Site/AD.html

            # Grab Users
             "<h1> AD USERS </h1>" >> Site/AD.html
            get-aduser -Filter * | ConvertTo-HTML -Fragment -As Table >> Site/AD.html
        
            # Grab comps
             "<h1> AD COMPUTERS </h1>" >> Site/AD.html
            get-adcomputer -Filter * | ConvertTo-HTML -Fragment -As Table >> Site/AD.html

            # Grab Groups
             "<h1> AD GROUPS </h1>" >> Site/AD.html
            get-adgroup -Filter * | ConvertTo-HTML -Fragment -As Table >> Site/AD.html

            # Get all GPOs
             "<h1> AD GROUP POLICY </h1>" >> Site/AD.html
            get-GPO -Filter * | ConvertTo-HTML -Fragment -As Table >> Site/AD.html
            }catch{
                 "<h1> Credential Error </h1>" >> Site/AD.html
            }
        }
}catch{
    $DivContent >> Site/AD.html
    "<h1> ACTIVE DIRECTORY DOMAIN SERVICES NOT INSTALLED ON THIS DEVICE </h1>" >> Site/AD.html
}
$DivEnd >> Site/AD.html
$End >> Site/AD.html


# Summary of report
# Track page creation/features and generate a summary for the idex page
 "<div id=`"Content`"><h1> Summary </h1>
<p> Summary will go here when the code is finished. It will provide brief summaries of each generated page. </p>
<p> Possibly excerpts as well.</p></div>" >> Site/Index.html
$DivEnd >> Site/Index.html
$End >> Site/Index.html

# Compress and backup Site dir
Compress-Archive -Path .\Site\ -DestinationPath .\"Enum-Backup-$(Get-Date -Format "MM-dd-yyyy_HH_mm")"

# Start index
start .\Site\Index.html