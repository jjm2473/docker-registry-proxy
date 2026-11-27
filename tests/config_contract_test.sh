#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
caddy_config="$repo_dir/caddy/registry.istoreos.com.caddy"
nginx_config="$repo_dir/nginx/registry-backend.nginx"

test -f "$caddy_config"
test -f "$nginx_config"

grep -Fq 'reverse_proxy 127.0.0.1:9080' "$caddy_config"
grep -Fq 'output file /var/log/caddy/registry.istoreos.com.log' "$caddy_config"

grep -Fq 'listen 127.0.0.1:9080;' "$nginx_config"
grep -Fq 'proxy_pass http://127.0.0.1:5000;' "$nginx_config"
grep -Fq 'proxy_pass http://127.0.0.1:8082/split/;' "$nginx_config"
grep -Fq 'proxy_cache_use_stale error timeout updating http_429' "$nginx_config"

if command -v caddy >/dev/null 2>&1; then
	caddy adapt --config "$caddy_config" --adapter caddyfile >/dev/null
fi

echo 'config contract: ok'
