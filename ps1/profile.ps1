# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Remove-Item Alias:gc -Force
# Set-Alias -Name gc -Value Get-Clipboard
Set-Alias -Name gc -Value gc.cmd
Remove-Item Alias:sc -Force
Set-Alias -Name sc -Value sc.cmd
Set-Alias -Name ll -Value dir
Set-Alias -Name touch -Value New-Item

function symlink {
  param (
    [string]$target
    , [string]$link_path
  )
  # Does not work in 5.1 // windows - Symlinks cannot be created in Powershell 5.1 but can be created by Powershell 7 and Command Prompt - Stack Overflow https://stackoverflow.com/questions/66609154/symlinks-cannot-be-created-in-powershell-5-1-but-can-be-created-by-powershell-7   
  #New-Item -ItemType SymbolicLink -Path $link_path -Target $target
  cmd.exe /c mklink "$link_path" "$target"
}
