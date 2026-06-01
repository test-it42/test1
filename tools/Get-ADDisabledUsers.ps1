#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
    GUI tool to query and display all disabled Active Directory user accounts.
.DESCRIPTION
    Connects using current user credentials, retrieves disabled AD accounts,
    and presents them in a searchable DataGridView with CSV export.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Get-DisabledUsers {
    param([string]$SearchBase)
    $props = @(
        'DisplayName', 'SamAccountName', 'UserPrincipalName',
        'DistinguishedName', 'Department', 'Manager',
        'LastLogonDate', 'PasswordLastSet', 'Description',
        'whenChanged', 'Enabled'
    )
    $params = @{
        Filter     = { Enabled -eq $false }
        Properties = $props
    }
    if ($SearchBase) { $params.SearchBase = $SearchBase }

    Get-ADUser @params | Select-Object `
        @{N='DisplayName';       E={$_.DisplayName}},
        @{N='SamAccountName';    E={$_.SamAccountName}},
        @{N='UPN';               E={$_.UserPrincipalName}},
        @{N='DistinguishedName'; E={$_.DistinguishedName}},
        @{N='Department';        E={$_.Department}},
        @{N='Manager';           E={
            if ($_.Manager) {
                try { (Get-ADUser $_.Manager -ErrorAction Stop).DisplayName }
                catch { $_.Manager }
            } else { '' }
        }},
        @{N='LastLogonDate';     E={if ($_.LastLogonDate) { $_.LastLogonDate.ToString('yyyy-MM-dd HH:mm') } else { 'Never' }}},
        @{N='DisabledDate';      E={if ($_.whenChanged)   { $_.whenChanged.ToString('yyyy-MM-dd HH:mm') }   else { '' }}},
        @{N='Description';       E={$_.Description}}
}

function Populate-Grid {
    param($Grid, $Data, [string]$Filter)
    $Grid.Rows.Clear()
    foreach ($u in $Data) {
        if ($Filter -and -not (
            $u.DisplayName    -match $Filter -or
            $u.SamAccountName -match $Filter -or
            $u.UPN            -match $Filter -or
            $u.Department     -match $Filter -or
            $u.Description    -match $Filter
        )) { continue }
        [void]$Grid.Rows.Add(
            $u.DisplayName, $u.SamAccountName, $u.UPN,
            $u.DistinguishedName, $u.Department, $u.Manager,
            $u.LastLogonDate, $u.DisabledDate, $u.Description
        )
    }
}

# ---------------------------------------------------------------------------
# Build form
# ---------------------------------------------------------------------------

$form = New-Object System.Windows.Forms.Form
$form.Text          = 'AD Disabled Users'
$form.Size          = New-Object System.Drawing.Size(1200, 700)
$form.StartPosition = 'CenterScreen'
$form.MinimumSize   = New-Object System.Drawing.Size(900, 500)

# Toolbar panel
$toolbar = New-Object System.Windows.Forms.Panel
$toolbar.Dock   = 'Top'
$toolbar.Height = 40
$toolbar.Padding = New-Object System.Windows.Forms.Padding(5, 5, 5, 5)
$form.Controls.Add($toolbar)

$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text     = 'Refresh'
$btnRefresh.Width    = 80
$btnRefresh.Location = New-Object System.Drawing.Point(5, 7)
$toolbar.Controls.Add($btnRefresh)

$lblSearch = New-Object System.Windows.Forms.Label
$lblSearch.Text     = 'Search:'
$lblSearch.AutoSize = $true
$lblSearch.Location = New-Object System.Drawing.Point(95, 11)
$toolbar.Controls.Add($lblSearch)

$txtSearch = New-Object System.Windows.Forms.TextBox
$txtSearch.Width    = 220
$txtSearch.Location = New-Object System.Drawing.Point(145, 8)
$toolbar.Controls.Add($txtSearch)

$lblOU = New-Object System.Windows.Forms.Label
$lblOU.Text     = 'OU filter:'
$lblOU.AutoSize = $true
$lblOU.Location = New-Object System.Drawing.Point(380, 11)
$toolbar.Controls.Add($lblOU)

$txtOU = New-Object System.Windows.Forms.TextBox
$txtOU.Width    = 300
$txtOU.Location = New-Object System.Drawing.Point(448, 8)
$toolbar.Controls.Add($txtOU)

$btnExport = New-Object System.Windows.Forms.Button
$btnExport.Text     = 'Export CSV'
$btnExport.Width    = 90
$btnExport.Location = New-Object System.Drawing.Point(760, 7)
$toolbar.Controls.Add($btnExport)

# DataGridView
$grid = New-Object System.Windows.Forms.DataGridView
$grid.Dock                  = 'Fill'
$grid.ReadOnly              = $true
$grid.AllowUserToAddRows    = $false
$grid.AutoSizeColumnsMode   = 'None'
$grid.SelectionMode         = 'FullRowSelect'
$grid.ColumnHeadersHeightSizeMode = 'AutoSize'
$grid.BackgroundColor       = [System.Drawing.Color]::White

$columns = @(
    @{N='DisplayName';       W=160},
    @{N='SamAccountName';    W=120},
    @{N='UPN';               W=200},
    @{N='DistinguishedName'; W=300},
    @{N='Department';        W=130},
    @{N='Manager';           W=140},
    @{N='LastLogonDate';     W=130},
    @{N='DisabledDate';      W=130},
    @{N='Description';       W=200}
)
foreach ($col in $columns) {
    $c = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $c.HeaderText = $col.N
    $c.Name       = $col.N
    $c.Width      = $col.W
    [void]$grid.Columns.Add($c)
}
$form.Controls.Add($grid)

# Status strip
$status = New-Object System.Windows.Forms.StatusStrip
$lblCount  = New-Object System.Windows.Forms.ToolStripStatusLabel
$lblTime   = New-Object System.Windows.Forms.ToolStripStatusLabel
$lblDomain = New-Object System.Windows.Forms.ToolStripStatusLabel
$lblCount.BorderSides  = 'Right'
$lblTime.BorderSides   = 'Right'
[void]$status.Items.AddRange(@($lblCount, $lblTime, $lblDomain))
$form.Controls.Add($status)

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

$script:allUsers = @()

function Refresh-Data {
    $btnRefresh.Enabled = $false
    $btnRefresh.Text    = 'Loading...'
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $domain           = (Get-ADDomain).DNSRoot
        $script:allUsers  = Get-DisabledUsers -SearchBase $txtOU.Text.Trim()
        $sw.Stop()

        Populate-Grid -Grid $grid -Data $script:allUsers -Filter $txtSearch.Text.Trim()

        $lblCount.Text  = "Disabled accounts: $($script:allUsers.Count)"
        $lblTime.Text   = "Query time: $([math]::Round($sw.Elapsed.TotalSeconds, 2))s"
        $lblDomain.Text = "Domain: $domain"
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Error querying Active Directory:`n$($_.Exception.Message)",
            'Error', 'OK', 'Error'
        ) | Out-Null
        $lblCount.Text = 'Error'
    }
    finally {
        $btnRefresh.Enabled = $true
        $btnRefresh.Text    = 'Refresh'
    }
}

# ---------------------------------------------------------------------------
# Event handlers
# ---------------------------------------------------------------------------

$btnRefresh.Add_Click({ Refresh-Data })

$txtSearch.Add_TextChanged({
    Populate-Grid -Grid $grid -Data $script:allUsers -Filter $txtSearch.Text.Trim()
    $lblCount.Text = "Showing: $($grid.Rows.Count) / $($script:allUsers.Count)"
})

$btnExport.Add_Click({
    $dlg = New-Object System.Windows.Forms.SaveFileDialog
    $dlg.Filter           = 'CSV files (*.csv)|*.csv'
    $dlg.FileName         = "DisabledUsers_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $dlg.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    if ($dlg.ShowDialog() -eq 'OK') {
        try {
            $script:allUsers | Export-Csv -Path $dlg.FileName -NoTypeInformation -Encoding UTF8
            [System.Windows.Forms.MessageBox]::Show(
                "Exported $($script:allUsers.Count) records to:`n$($dlg.FileName)",
                'Export complete', 'OK', 'Information'
            ) | Out-Null
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show(
                "Export failed:`n$($_.Exception.Message)",
                'Error', 'OK', 'Error'
            ) | Out-Null
        }
    }
})

$form.Add_Shown({ Refresh-Data })

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

[System.Windows.Forms.Application]::Run($form)
