# Explorer config registry key
$explorerConfigRegistryKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
$explorerAdvancedConfigRegistryKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

# ============ Explorer ===========

# Show hidden files
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name Hidden -Value 1

# Show file extensions
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name HideFileExt -Value 0

# Hide protected OS files
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name ShowSuperHidden -Value 0

# Opens PC to This PC, not quick access
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name LaunchTo -Value 1

# Disable Quick Access: Recent Files
Set-ItemProperty -Path $explorerConfigRegistryKey -Name ShowRecent -Type DWord -Value 0

# Disable Quick Access: Frequent Folders
Set-ItemProperty -Path $explorerConfigRegistryKey -Name ShowFrequent -Type DWord -Value 0

# Show all folders in Explorer including Recycle Bin, Desktop, Control Panel
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name NavPaneShowAllFolders -Value 1

# Don't show notifications/adverts (OneDrive & new feature alerts) in Windows Explorer
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name ShowSyncProviderNotifications -Value 0

# ============ Taskbar ============

# Hide TaskView button from taskbar
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name ShowTaskViewButton -Value 0

# Don't combine taskbar buttons (requires Win11 23H2+): Always: 0, When full: 1, Never: 2
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name TaskbarGlomLevel -Value 2

# Show taskbar buttons on all taskbars
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name MMTaskbarMode -Value 0

# Hide Copilot button (replaces Cortana in Win11)
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name ShowCopilotButton -Value 0

# Hide search from taskbar: Hidden: 0, Icon: 1, Box: 2
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -Value 0

# Hide Widgets button from taskbar (Win11)
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name TaskbarDa -Value 0

# Hide Chat button from taskbar (Win11)
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name TaskbarMn -Value 0

# ============ System tray ============

# Show all icons
Set-ItemProperty -Path $explorerConfigRegistryKey -Name EnableAutoTray -Type DWord -Value 1

# ============ Start menu ============

# Hide recently opened programs from Start Menu /Start Run
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name Start_TrackProgs -Value 0

# Hide recently opened Documents from the Start menu /Start Run
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name Start_TrackDocs -Value 0

# Don't slow down search by including all public folders
Set-ItemProperty -Path $explorerAdvancedConfigRegistryKey -Name Start_SearchFiles -Value 1

# ============ Settings ============

# Enable developer mode on the system
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

# Dont prompt to 'Look for an app in the Store'
Set-ItemProperty -Path $explorerConfigRegistryKey -Name NoUseStoreOpenWith -Type DWord -Value 1

# Configure Windows to use UTC and not localtime
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation -Name RealTimeIsUniversal -Value 1

# Restart explorer
Stop-Process -processname explorer
