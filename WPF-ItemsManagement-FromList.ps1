###############################################################################################################
# Language     :  PowerShell
# Description  :  Powershell WPF - Add/Remove Items From List
$ScriptVersion = 1.0.0
###############################################################################################################

#Xamal loader section has been wrote by stephen owen :
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
     Title="Items List Managements" Height="619.963" Width="625.926">
    <Grid Margin="0,0,0,-1">
        <Grid.RowDefinitions>
            <RowDefinition Height="11*"/>
            <RowDefinition Height="23*"/>
        </Grid.RowDefinitions>
        <TabControl HorizontalAlignment="Left" Height="570" Margin="10,10,10,10" VerticalAlignment="Top" Width="601" Grid.RowSpan="2">
            <TabItem Header="Select Items">
                <Grid Background="#FFE5E5E5">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="115*"/>
                        <ColumnDefinition Width="476*"/>
                    </Grid.ColumnDefinitions>
                    <Grid Background="#FFE5E5E5" Grid.ColumnSpan="2">
                        <Label x:Name="Label_AvailableItems" Content="Available Item(s)  :" HorizontalAlignment="Left" Margin="22.667,38,0,0" VerticalAlignment="Top" Width="133"/>
                        <ListBox x:Name="listbox_AvailableItems" MinHeight = "50" AllowDrop="True" SelectionMode="Extended" HorizontalAlignment="Left" Height="102" Margin="22.667,64,0,0" VerticalAlignment="Top" Width="225.5"/>
                        <Button x:Name="Button_AddItems" Content="&gt;&gt;" HorizontalAlignment="Left" Margin="263,82.5,0,0" VerticalAlignment="Top" Width="75" Height="20" FontSize="10"/>
                        <Button x:Name="Button_RemoveItems" Content="&lt;&lt;" HorizontalAlignment="Left" Margin="263,107.5,0,0" VerticalAlignment="Top" Width="75" Height="20" FontSize="10"/>
                        <ListBox x:Name="listbox_SelectedItems" MinHeight = "50" AllowDrop="True" SelectionMode="Extended" HorizontalAlignment="Left" Height="102" Margin="354.5,64,0,0" VerticalAlignment="Top" Width="218.5"/>
                        <Label x:Name="Label_SelectedItems" Content="Selected Item(s)  :" HorizontalAlignment="Left" Margin="354.5,38,0,0" VerticalAlignment="Top" Width="133"/>
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

function get-ListBoxCurrentData($Output) {

    $DataListBox = @($Output.Items)

    return $DataListBox
}

Function ListBox($InputData, $Output) {
        
    foreach ($Input in $InputData) {
            
        $DataListBox = get-ListBoxCurrentData -Output $Output
    
        #Do not add the data if this one already exist
        if ($DataListBox -notcontains $Input) {
    
            $Output.Items.Add($Input) | Out-Null
        }
    }
}

function RemoveItem-FromListBox($listbox) {
        
    While ($listbox.SelectedItems.count -gt 0) {
        
        $listbox.Items.RemoveAt($listbox.SelectedIndex)
    }
}

function Sync-ListBox($RemoveFromListbox, $AddToListbox) {

    #Get items before remove it
    $SelectedItems = @($RemoveFromListbox.SelectedItems)

    #Remove items
    RemoveItem-FromListBox -listbox $RemoveFromListbox

    #Add items to choice list
    ListBox -InputData $SelectedItems -Output $AddToListbox
}
#function Get


#Add to available items list
$Values = @("Hello","World")

$Values | ForEach-Object {
    ListBox -InputData "$_" -Output $WPFlistbox_AvailableItems
}

#region Events

    #Sync-ListBox

        $WPFButton_AddItems.Add_Click( {
            
                Sync-ListBox -RemoveFromListbox $WPFlistbox_AvailableItems -AddToListbox $WPFlistbox_SelectedItems
        })

        $WPFButton_RemoveItems.Add_Click( {
                
                Sync-ListBox -RemoveFromListbox $WPFlistbox_SelectedItems -AddToListbox $WPFlistbox_AvailableItems
        })

    #endregion 

#endregion 

$Form.ShowDialog() | out-null