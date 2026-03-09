# Default Apps List: https://learn.microsoft.com/en-us/windows/application-management/overview-windows-apps

function removeApp {
    Param ([string]$appName)
    Write-Output "Trying to remove $appName"
    Get-AppxPackage $appName -AllUsers | Remove-AppxPackage
    Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like $appName | Remove-AppxProvisionedPackage -Online
}

$applicationList = @(
    # Windows 11 built-in apps
    "Clipchamp.Clipchamp"
    "Microsoft.549981C3F5F10"            # Cortana
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.GamingApp"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"               # Tips
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.People"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.Todos"
    "Microsoft.Windows.DevHome"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.XboxApp"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftTeams"
    "*Solitaire*"
    # Third-party bloatware
    "*Autodesk*"
    "*BubbleWitch*"
    "*Dell*"
    "*Facebook*"
    "*Keeper*"
    "*Minecraft*"
    "*Netflix*"
    "*Twitter*"
    "*Plex*"
    "*.Duolingo-LearnLanguagesforFree"
    "*.EclipseManager"
    "ActiproSoftwareLLC.562882FEEB491"   # Code Writer
    "*.AdobePhotoshopExpress"
    "G5*"
    "king.com*"
);

foreach ($app in $applicationList) {
    removeApp $app
}