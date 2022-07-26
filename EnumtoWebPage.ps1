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

$Nav = "<table style=`"font-color: #000000;`"><tr><th><a href=`"Index.html`">Home</a></th><th><a href=`"Processes.html`"> Processes </a></th><th><a href=`"Services.html`"> Service </a></th><th><a href=`"Local.html`"> Local Accounts </a></th>`
<th><a href=`"Tasks.html`">Tasks</a></th><th><a href=`"AD.html`">Active Directory</a></th></tr></table>"


# Author Information
$Author = " <h2> Author: $Name </h2>
<h2> Device: $Device </h2>
 <h2> Competition: $Comp </h2>
 <br />"

# Date & time 
$Date = "<h1> Enumeration Started $(Get-Date) </h1>"

# Compile header
$Header = $html + "<head>" + $Style + $Date + $Nav + $Author + "</head>"

# Send header to index.html
 $Header >> Site/Index.html

# General information

# Process information
     $Header + $Body >> Site/Processes.html
     "<div id=Processes>" >> Site/Processes.html
     "<h1>PROCESSES</h1> " >> Site/Processes.html
    Get-CimInstance Win32_Process | Select-Object ProcessName, Path, CreationDate, CommandLine | ConvertTo-HTML -Fragment -As Table >> Site/Processes.html
     "</div>" >> Site/Processes.html
     $End >> Site/Processes.html

# Service Information
     $Header + $Body >> Site/Services.html
     "<h1> SERVICES </h1>" >> Site/Services.html
    Get-CimInstance Win32_Service | Select-Object Name, PathName, Caption, Description, State | ConvertTo-HTML -Fragment -As Table >> Site/Services.html
     $End >> Site/Services.html

# Local User information
    $Header + $Body >> Site/Local.html
     "<h1> LOCAL USERS </h1>" >> Site/Local.html
    Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordRequired, Description, SID | ConvertTo-HTML -Fragment >> Site/Local.html
     "<h1> LOCAL GROUPS </h1>" >> Site/Local.html
    Get-LocalGroup | Select-Object Name, Description, SID | ConvertTo-HTML -Fragment >> Site/Local.html
     $End >> Site/Local.html

# Task Information
    $Header + $Body >> Site/Tasks.html
     "<h1> SCHEDULED TASKS </h1>" >> Site/Tasks.html
    Get-ScheduledTask |Select-Object TaskName, Author, State, Description, TaskPath | ConvertTo-HTML -Fragment -As Table >> Site/Tasks.html
     $End >> Site/Tasks.html


# Active Directory Enumeration
 $header >> Site/AD.html
try{
    if((Get-WindowsFeature | ? DisplayName -match 'Active Directory Domain Services' | Select-Object -Property InstallState)){
        try{
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
     "<h1> ACTIVE DIRECTORY DOMAIN SERVICES NOT INSTALLED ON THIS DEVICE </h1>" >> Site/AD.html
}
 $End >> Site/AD.html


# Summary of report
# Track page creation/features and generate a summary for the idex page
 "<div class=`"Summary`"><h1> Summary </h1>
<p> Summary will go here when the code is finished. It will provide brief summaries of each generated page. </p>
<p> Possibly excerpts as well.</p>
<iframe src=`"Processes.html#Processes`" title=`"Processes`" scrolling=`"no`"></iframe></div>" >> Site/Index.html
 $End >> Site/Index.html

# Compress and backup Site dir
Compress-Archive -Path .\Site\ -DestinationPath .\"Enum-Backup-$(Get-Date -Format "MM-dd-yyyy_HH_mm")"

# Start index
start .\Site\Index.html