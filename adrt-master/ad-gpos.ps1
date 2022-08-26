#################################################################################################################
#                              Criador: Diogo De Santana Jacome                                                 #
#                              Empresa:  Solo Network                                                           #
#                              Modifcado por: Diogo De Santana Jacome                                           #
#                                                                                                               #
#                                                                                                               #
#                                          Versão: 1.0                                                          #
#                                                                                                               #
#                                                                                                               #
#################################################################################################################


$report = $null
$table = $null
$date = Get-Date -format "yyyy-MM-dd"
$directorypath = (Get-Item -Path ".\").FullName
$path = "ad-reports\ad-gpos"
#$html = "$path\ad-gpos-$date.html"
#$csv = "ad-reports\ad-gpos\ad-gpos-$date.csv"
#$zip = "$path\gpos-html-$date.zip"
#new-item -type directory -path "$path\gpos-html-$date" -Force
#$gpos_html = "$path\gpos-html-$date\"
$html = "$path\ad-gpos.html"
$csv = "ad-reports\ad-gpos\ad-gpos.csv"
$zip = "$path\gpos-html.zip"
new-item -type directory -path "$path\gpos-html" -Force
$gpos_html = "$path\gpos-html\"

#-- All GPOs
$t_gpos = (Get-GPO -All).count 
$domain = (Get-ADDomain).Forest

# Config
$config = Get-Content (JOIN-PATH $directorypath "config\config.txt")
$company = $config[7]
$owner = $config[9]

#-- Import Module
Import-Module ActiveDirectory

#-- Show Total
$table += "<center><h3><b>Total GPOs: <font color=red>$t_gpos</font></b></h3></center>"

#-- Filter
$gpos = @(Get-GPO -All | Select-Object DisplayName, Owner, CreationTime, ModificationTime)

#Get-GPO -All | Select DisplayName, Owner, CreationTime, ModificationTime | % {$_.GenerateReport('html') | Out-File html\"$($_.DisplayName).htm"}
Get-GPO -All | % {$_.GenerateReport('html') | Out-File $gpos_html\"$($_.DisplayName).htm"}


$result = @($gpos | Select-Object DisplayName, Owner, CreationTime, ModificationTime)

#-- Order by (A-Z)
$result = $result | Sort-Object "DisplayName"

#-- Display result on screen
#$result | ft -auto 

$table += $result | ConvertTo-Html -Fragment
 
$format=
		"
		<html>
		<body>
		<title>$company</title>
		<style>
		BODY{font-family: Calibri; font-size: 12pt;}
		TABLE{border: 1px solid black; border-collapse: collapse; font-size: 12pt; text-align:center;margin-left:auto;margin-right:auto; width='1000px';}
		TH{border: 1px solid black; background: #F9F9F9; padding: 5px;}
		TD{border: 1px solid black; padding: 5px;}
		H3{font-family: Calibri; font-size: 12pt;}
		</style> 
		"
$title=
		"
		<table width='100%' border='0' cellpadding='0' cellspacing='0'>
		<tr>
		<td bgcolor='#F9F9F9'>
		<font face='Calibri' size='5px'><b>Active Directory - All GPOs</b></font>
		<H3 align='center'>Company: <font color=red>$company</font> - Domain: <font color=red>$domain</font> - Date: <font color=red>$date</font> - Owner: <font color=red>$owner</font></H3>
		</td>
		</tr>
		</table>
		</body>
		</html>
		"
$footer=
		"
		<br><br>
		<center><a href='gpos-html' target='_blank'>View GPOs</a></center>
		<br><br>
		<table width='100%' border='0' cellpadding='0' cellspacing='0'>
		<tr>
		<td bgcolor='#F9F9F9'>
		<font face='Calibri' size='2px'>Assesment inicial - ADDS</font>
		</td>
		</tr>
		</table>
		"	
$message = "</table><style>"
$message = $message + "BODY{font-family: Calibri;font-size:16;font-color: #000000}"
$message = $message + "TABLE{margin-left:auto;margin-right:auto;width: 800px;border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$message = $message + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color: #F9F9F9;text-align:center;}"
$message = $message + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;text-align:center;}"
$message = $message + "</style>"
$message = $message + "<table width='300px' heigth='500px' align='center'>"
$message = $message + "<tr><td colspan='2' bgcolor='#DDEBF7' height='40'><b>Active Directory</b></td></tr>"
$message = $message + "<tr><td bgcolor='#F9F9F9' height='40'>Description</td><td bgcolor='#F9F9F9' height='40'>Total</td></tr>"
$message = $message + "<tr><td height='40'>Total GPOs</td><td>$t_gpos</td></tr>"
$message = $message + "<tr><td colspan='2' bgcolor='#DDEBF7' height='40'><b>Information Security</b></td></tr>"
$message = $message + "</table>"

$report = $format + $title + $table + $footer

#-- Generate HTML file
$report | Out-File $html -Encoding Utf8

#-- Compact GOPs (ad-gpos-$date.zip)
Compress-Archive -Path $gpos_html -DestinationPath $zip -Force

#-- Export to CSV
$result | Sort-Object Company | Export-Csv $csv -NoTypeInformation -Encoding Utf8


Clear-Host