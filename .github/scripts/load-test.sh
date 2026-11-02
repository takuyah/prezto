#!/usr/bin/env bash
# Start a login + interactive zsh with this checkout as ~/.zprezto and the
# repo's runcoms as the dotfiles, then fail on any startup error output or
# any module listed in zpreztorc that did not load.
set -euo pipefail
repo="$(cd "$(dirname "$0")/../.." && pwd)"

home="$(mktemp -d)"
trap 'rm -rf "$home"' EXIT
ln -s "$repo" "$home/.zprezto"
for rc in zlogin zlogout zpreztorc zprofile zshenv zshrc; do
  ln -s "$home/.zprezto/runcoms/$rc" "$home/.$rc"
done

stderr="$home/stderr"
HOME="$home" TERM=xterm-256color zsh -i -l -c '
  zstyle -a ":prezto:load" pmodule wanted
  failed=0
  for m in $wanted; do
    if zstyle -t ":prezto:module:$m" loaded; then
      print "loaded: $m"
    else
      print -u2 "module failed to load: $m"
      failed=1
    fi
  done
  exit $failed
' </dev/null 2>"$stderr" || { cat "$stderr" >&2; echo "::error::zsh startup exited non-zero"; exit 1; }

if [[ -s "$stderr" ]]; then
  echo "::error::zsh startup wrote to stderr:"
  cat "$stderr" >&2
  exit 1
fi
echo "zsh startup clean"
