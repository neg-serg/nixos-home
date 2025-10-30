# Aliae integration for PowerShell (pwsh)
try {
  $cfg = if ($env:XDG_CONFIG_HOME) { Join-Path $env:XDG_CONFIG_HOME 'aliae/config.yaml' } else { Join-Path $HOME '.config/aliae/config.yaml' }
  if (Get-Command aliae -ErrorAction SilentlyContinue) {
    # Print init script and invoke it so aliases/functions load
    $init = aliae init pwsh --config $cfg --print | Out-String
    if ($init) { Invoke-Expression $init }
  }
} catch {}

# Fallback aliases/functions to ensure parity with other shells
# Helpers to define forwarding functions only if the command exists
function Set-IfCmd([string]$cmd, [scriptblock]$body) {
  if (Get-Command $cmd -ErrorAction SilentlyContinue) { & $body }
}

# eza-based listing
Set-IfCmd 'eza' { function l { eza --icons=auto --hyperlink @args } }
Set-IfCmd 'eza' { function ll { eza --icons=auto --hyperlink -l @args } }
Set-IfCmd 'eza' { function lsd { eza --icons=auto --hyperlink -alD --sort=created --color=always @args } }

# git shortcuts
function gs { git status -sb @args }

# open helper via handlr
Set-IfCmd 'handlr' { function e { handlr open @args } }

# cat via bat
Set-IfCmd 'bat' { function cat { bat -pp @args } }

# grep family via ugrep (ug)
Set-IfCmd 'ug' {
  function grep  { ug -G @args }
  function egrep { ug -E @args }
  function epgrep { ug -P @args }
  function fgrep { ug -F @args }
  function xgrep { ug -W @args }
  function zgrep { ug -zG @args }
  function zegrep { ug -zE @args }
  function zfgrep { ug -zF @args }
  function zpgrep { ug -zP @args }
  function zxgrep { ug -zW @args }
}

# tree
Set-IfCmd 'erd' { function tree { erd @args } }

# compression/locate
Set-IfCmd 'pigz'   { function gzip  { pigz @args } }
Set-IfCmd 'pbzip2' { function bzip2 { pbzip2 @args } }
Set-IfCmd 'plocate'{ function locate { plocate @args } }

# network/disk helpers
Set-IfCmd 'prettyping' { function ping { prettyping @args } }

# threads
Set-IfCmd 'xz'   { function xz   { & xz --threads=0 @args } }
Set-IfCmd 'zstd' { function zstd { & zstd --threads=0 @args } }

# mpv controller
Set-IfCmd 'mpvc' {
  $xdg = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME '.config' }
  function mpvc { mpvc -S (Join-Path $xdg 'mpv/socket') @args }
}

# wget2 HSTS path
Set-IfCmd 'wget2' {
  $xdata = if ($env:XDG_DATA_HOME) { $env:XDG_DATA_HOME } else { Join-Path $HOME '.local/share' }
  function wget { wget2 --hsts-file (Join-Path $xdata 'wget-hsts') @args }
}

