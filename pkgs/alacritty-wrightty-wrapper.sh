#!@shell@
if [ "${WRIGHTTY_DISABLE:-0}" = "1" ]; then
  exec -a alacritty @alacritty@ "$@"
fi

for arg in "$@"; do
  case "$arg" in
    --wrightty|--wrightty=*) exec -a alacritty @alacritty@ "$@" ;;
  esac
done

port=9420
while [ "$port" -le 9500 ]; do
  if [ -z "$(@ss@ -H -ltn "sport = :$port" 2>/dev/null)" ]; then
    WRIGHTTY_PORT="$port"
    WRIGHTTY_SOCKET="ws://127.0.0.1:$port"
    export WRIGHTTY_PORT WRIGHTTY_SOCKET
    exec -a alacritty @alacritty@ --wrightty="$port" "$@"
  fi
  port=$((port + 1))
done

exec -a alacritty @alacritty@ --wrightty=9420 "$@"
