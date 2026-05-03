_pixibin="$HOME/.pixi/bin"
if [ -d "$_pixibin" ] && [ "${PATH#*"$_pixibin"}" = "$PATH" ]; then
  export PATH="$_pixibin:$PATH"
fi
