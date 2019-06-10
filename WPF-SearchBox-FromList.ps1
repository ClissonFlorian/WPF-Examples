###############################################################################################################
#Description  :  Powershell WPF - Add/Remove Items From List
#Author : Florian Clisson
###############################################################################################################

#Xamal Loader section has been wrote by stephen owen :
#https://github.com/1RedOne/PowerShell_XAML/

#ERASE ALL THIS AND PUT XAML BELOW between the @" "@
$inputXML = @"
<Window x:Class="WpfApplication2.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication2"
        mc:Ignorable="d"
     Title="Demo - Search ComboxBox" Height="619.963" Width="625.926">
    <Grid Margin="0,0,0,-1">
        <Grid.RowDefinitions>
            <RowDefinition Height="11*"/>
            <RowDefinition Height="23*"/>
        </Grid.RowDefinitions>
        <TabControl HorizontalAlignment="Left" Height="570" Margin="10,10,10,10" VerticalAlignment="Top" Width="601" Grid.RowSpan="2">
            <TabItem Header="Search ComboBox">
                <Grid Background="#FFE5E5E5">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="115*"/>
                        <ColumnDefinition Width="476*"/>
                    </Grid.ColumnDefinitions>
                    <Grid Background="#FFE5E5E5" Grid.ColumnSpan="2">
                        <ComboBox x:Name="OutputBox" IsEditable="true" HorizontalAlignment="Left" Margin="22.667,38,0,0" VerticalAlignment="Top" Width="133"></ComboBox> 
                    </Grid>
                </Grid>
            </TabItem>
            <TabItem Header="?">
                
            </TabItem>
        </TabControl>
    </Grid>
</Window>
"@       


$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
 

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML

 
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {$Form = [Windows.Markup.XamlReader]::Load( $reader )}
catch {Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================


$xaml.SelectNodes("//*[@Name]") | Where-Object {Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}


Function Get-FormVariables {
    if ($global:ReadmeDisplay -ne $true) {Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow; $global:ReadmeDisplay = $true}
    write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
    get-variable WPF*
}

#Display WPF Variable (You can comment this function once script finished)
Get-FormVariables


#===========================================================================
# Update Data
#===========================================================================
$WPFOutputBox.IsDropDownOpen = "false"
$WPFOutputBox.StaysOpenOnEdit = "true"

$Data = (Get-Process).Name
$Data | ForEach-Object {

    $WPFOutputBox.Items.Add($_) | Out-Null
    
}

#===========================================================================
# Events
#===========================================================================
$WPFOutputBox.add_KeyDown({
    $WPFOutputBox.IsDropDownOpen = "true"
})

#Display powershell GUI
$Form.ShowDialog() | out-null
