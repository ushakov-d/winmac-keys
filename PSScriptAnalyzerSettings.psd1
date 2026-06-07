@{
    # install.ps1 / uninstall.ps1 are user-facing installer scripts whose whole
    # job is to print colored progress to the console. Write-Host is the right
    # tool for that here, so we deliberately silence PSAvoidUsingWriteHost.
    ExcludeRules = @(
        'PSAvoidUsingWriteHost'
    )
}
