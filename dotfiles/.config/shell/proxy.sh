# Shared proxy helpers for POSIX shells. The proxy is intentionally off until
# `proxy [port]` is called in the current shell (default port 7897).
proxy() {
  local port="${1:-7897}"
  export HTTP_PROXY="http://127.0.0.1:$port"
  export HTTPS_PROXY="$HTTP_PROXY"
  export ALL_PROXY="socks5h://127.0.0.1:$port"
  export NO_PROXY="localhost,127.0.0.1,::1,.local"
  export http_proxy="$HTTP_PROXY"
  export https_proxy="$HTTPS_PROXY"
  export all_proxy="$ALL_PROXY"
  export no_proxy="$NO_PROXY"
}

unproxy() {
  unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
  unset http_proxy https_proxy all_proxy no_proxy
}