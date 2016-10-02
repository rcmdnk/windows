# PATH

## Vim
$prog_dir = @(${ENV:ProgramFiles}, ${ENV:ProgramFiles(x86)})
foreach($d in $prog_dir){
  $vim_dir = $d + '\vim\vim74'
  if(Test-Path ($vim_dir + '\vim.exe')){
    $path = [regex]::escape($vim_dir)
    if(-not ($ENV:PATH -match $path)){
      $ENV:PATH += ";" + $vim_dir
    }
  }
}

## WinPkgMgr
$winpkgmgr_dir = $HOME + '\Documents\WinPkgMgr\bin'
if(Test-Path ($winpkgmgr_dir + '\PkgMgr.ps1')){
  $path = [regex]::escape($winpkgmgr_dir)
  if(-not ($ENV:PATH -match $path)){
    $ENV:PATH += ";" + $winpkgmgr_dir
  }
}

# Alias
Set-Alias uniq Get-Unique
Set-Alias vi vim

# Functions

function tail([string] $file, [int] $n=10, [switch] $f){
  if($f){
    Get-Content -Wait -Tail $n $file
  } else {
    Get-Content -Tail $n $file
  }
}
