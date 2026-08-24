# Shared proxy defaults for POSIX shells.
proxy_on() {
  export HTTP_PROXY="http://127.0.0.1:1082"
  export HTTPS_PROXY="$HTTP_PROXY"
  export ALL_PROXY="socks5h://127.0.0.1:1082"
  export NO_PROXY="localhost,127.0.0.1,::1,.local"
  export http_proxy="$HTTP_PROXY"
  export https_proxy="$HTTPS_PROXY"
  export all_proxy="$ALL_PROXY"
  export no_proxy="$NO_PROXY"
}

proxy_off() {
  unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
  unset http_proxy https_proxy all_proxy no_proxy
}

proxy_status() {
  if [[ -n "${HTTP_PROXY:-}" ]]; then
    printf 'proxy on: %s (SOCKS: %s)\n' "$HTTP_PROXY" "${ALL_PROXY:-unset}"
  else
    printf 'proxy off\n'
  fi
}

proxy_on
