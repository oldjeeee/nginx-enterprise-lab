# Nginx Enterprise Runbooks (Auto-Generated)
_Last update: 2026-06-01 10:03:45 UTC | Commit: no-git_

## Architecture
- **Input ports:** 80:80,443:443,443:443/udp,4318:4318
- **TLS-protocols:** TLSv1.3
- **Security Headers:** Content-Security-Policy,Content-Type,Permissions-Policy,Referrer-Policy,Strict-Transport-Security,X-Content-Type-Options,X-Frame_options,X-XSS-Protection
- **Observability:** OpenTelemetry Collector (gRPC 4317), JSON access logs
- **Security Baseline:** CIS Nginx Benchmark 2026

## Deployment
```bash
docker compose up -d --build
docker compose logs -f nginx
```

## Checking compliance
```bash
opa eval -d policies/ -i parsed_config.json "data.nginx.compliance.deny"
```

## Collapsing
```bash
./scripts/teardown.sh
```
