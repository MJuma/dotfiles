Enable-WindowsOptionalFeature -Online -All -NoRestart -WarningAction SilentlyContinue -FeatureName "Microsoft-Windows-Subsystem-Linux"
Enable-WindowsOptionalFeature -Online -All -NoRestart -WarningAction SilentlyContinue -FeatureName "VirtualMachinePlatform"
Enable-WindowsOptionalFeature -Online -All -NoRestart -WarningAction SilentlyContinue -FeatureName "Microsoft-Hyper-V-All"
Enable-WindowsOptionalFeature -Online -All -NoRestart -WarningAction SilentlyContinue -FeatureName "Containers"
