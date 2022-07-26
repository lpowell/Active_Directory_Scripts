# Enum to html 
# Report info parameters
# Please include: Name, Device name, Competition level 
Param($Name, $Device, $Comp)

# Global def
$global:Break = '<br />'

# Try to create Site dir if it doesn't exist
try{
    mkdir Site
}catch{
}


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
$Header = $Style + $Date + $Nav + $Author

# Send header to index.html
echo $Header >> Site/Index.html

# General information
# Compatability with servers and workstations
# Gets service and process information

# Process information
    echo $Header >> Site/Processes.html
    echo "<h1>PROCESSES</h1> " >> Site/Processes.html
    Get-CimInstance Win32_Process | Select-Object ProcessName, Path, CreationDate, CommandLine | ConvertTo-HTML -Fragment -As Table >> Site/Processes.html
    # $break >> Enum.html

# Service Information
    echo $Header >> Site/Services.html
    echo "<h1> SERVICES </h1>" >> Site/Services.html
    Get-CimInstance Win32_Service | Select-Object Name, PathName, Caption, Description, State | ConvertTo-HTML -Fragment -As Table >> Site/Services.html
    # $break >> Enum.html

# Local User information
    $Header >> Site/Local.html
    echo "<h1> LOCAL USERS </h1>" >> Site/Local.html
    Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordRequired, Description, SID | ConvertTo-HTML -Fragment >> Site/Local.html
    echo "<h1> LOCAL GROUPS </h1>" >> Site/Local.html
    Get-LocalGroup | Select-Object Name, Description, SID | ConvertTo-HTML -Fragment >> Site/Local.html
    # $break >> Enum.html

# Task Information
    echo $Header >> Site/Tasks.html
    echo "<h1> SCHEDULED TASKS </h1>" >> Site/Tasks.html
    Get-ScheduledTask |Select-Object TaskName, Author, State, Description, TaskPath | ConvertTo-HTML -Fragment -As Table >> Site/Tasks.html





# Active Directory Enumeration
try{
    if((Get-WindowsFeature | ? DisplayName -match 'Active Directory Domain Services' | Select-Object -Property InstallState) -eq 'Installed'){

        echo "<h1> ACTIVE DIRECTORY SERVER INFORMATION </h1>" >> Site/AD.html
        echo "<br />" >> Site/AD.html


        # Get Domain info
        echo "<h1> DOMAIN INFORMATION </h1>" >> Site/AD.html
        get-addomain | ConvertTo-HTML -Fragment -As Table >> Site/AD.html

        # Grab Users
        echo "<h1> AD USERS </h1>" >> Site/AD.html
        get-aduser -Filter * | ConvertTo-HTML -Fragment -As Table >> Site/AD.html
        
        # Grab comps
        echo "<h1> AD COMPUTERS </h1>" >> Site/AD.html
        get-adcomputer -Filter * | ConvertTo-HTML -Fragment -As Table >> Site/AD.html

        # Grab Groups
        echo "<h1> AD GROUPS </h1>" >> Site/AD.html
        get-adgroup -Filter * | ConvertTo-HTML -Fragment -As Table >> Site/AD.html

        # Get all GPOs
        echo "<h1> AD GROUP POLICY </h1>" >> Site/AD.html
        get-GPO -Filter * | ConvertTo-HTML -Fragment -As Table >> Site/AD.html

        }else{
            return
        }
}catch{
    echo $header >> Site/AD.html
    echo "<h1> ACTIVE DIRECTORY DOMAIN SERVICES NOT INSTALLED ON THIS DEVICE </h1>" >> Site/AD.html
    $break >> Site/AD.html
}



# Summary of report
# Track page creation/features and generate a summary for the idex page
echo "<div class=`"Summary`"><h1> Summary </h1>
<p> Summary will go here when the code is finished. It will provide brief summaries of each generated page. </p>
<p> Possibly excerpts as well.</p></div>" >> Site/Index.html