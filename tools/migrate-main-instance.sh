#!/bin/bash

configfile="$1"
instancefile="$2"

if ! grep '^arkSingleInstance=' <"$configfile" >/dev/null 2>&1 && grep "^arkserverroot=" <"$configfile" >/dev/null 2>&1 && [ ! -f "$instancefile" ]; then
  sed -n '/^#*\(ark\(\|flag\|opt\)_[^=]*\|arkserverroot\|serverMap\(\|ModId\)\)=/p' <"$configfile" >"$instancefile"
  sed -i '/^ark\(serverroot\|_\(RCONPort\|Port\|QueryPort\)\)=/d' "$configfile"
  echo 'defaultinstance="main"' >>"$configfile"
fi
