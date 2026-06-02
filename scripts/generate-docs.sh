#!/bin/bash
set -e                                           # 2. Остановка при любой ошибке
DOCS_FILE="RUNBOOK.md"                           # 3. Имя итогового файла документации
COMPOSE_FILE="docker-compose.yml"                # 4. Путь к docker-compose.yml
NGINX_CONF="ansible/roles/nginx/templates/nginx.conf.j2" # 5. Путь к шаблону nginx.conf

# 6. Проверка наличия исходных файлов для парсинга
if [[ ! -f "$COMPOSE_FILE" || ! -f "$NGINX_CONF" ]]; then
        echo "❌ Files not found. Documentation was not generated." # 7. Сообщение об ошибке
        exit 1                                   # 8. Выход с кодом ошибки
fi

# 9. Парсинг портов: ищем строки вида - "80:80", извлекаем значение, заменяем переносы на запятые
PORTS=$(grep -E '^\s*- "[0-9]+:' "$COMPOSE_FILE" | sed 's/.*"\(.*\)".*/\1/' | paste -sd ',' -)

# 10. Парсинг TLS-протоколов: ищем ssl_protocols, извлекаем значения до точки с запятой
# Используем совместимый синтаксис без -P (PCRE) для максимальной портативности
TLS=$(grep 'ssl_protocols' "$NGINX_CONF" | sed 's/.*ssl_protocols\s*//' | sed 's/;.*//' | tr -d ' ' | tr '\n' ',' | sed 's/,$//')

# 11. Парсинг заголовков безопасности: извлекаем имя заголовка после add_header
# Сортируем уникальные, форматируем в строку через запятую
HEADERS=$(grep 'add_header' "$NGINX_CONF" | awk '{print $2}' | sort -u | paste -sd ',' -)

# 12. Получение хеша коммита: если не в git-репо, пишем "no-git"
# Используем ${VAR}_ для безопасного разделения переменной и текста
GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "no-git")

# 13. Получение текущей даты в формате ISO8601 UTC
DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

# 14. Генерация Markdown-файла через heredoc
cat > "$DOCS_FILE" <<EOF
# Nginx Enterprise Runbooks (Auto-Generated)
_Last update: ${DATE} | Commit: ${GIT_HASH}_

## Architecture
- **Input ports:** ${PORTS}
- **TLS-protocols:** ${TLS}
- **Security Headers:** ${HEADERS}
- **Observability:** OpenTelemetry Collector (gRPC 4317), JSON access logs
- **Security Baseline:** CIS Nginx Benchmark 2026

## Deployment
\`\`\`bash
docker compose up -d --build
docker compose logs -f nginx
\`\`\`

## Checking compliance
\`\`\`bash
opa eval -d policies/ -i parsed_config.json "data.nginx.compliance.deny"
\`\`\`

## Collapsing
\`\`\`bash
./scripts/teardown.sh
\`\`\`
EOF

# 15. Сообщение об успешной генерации
echo "✅ $DOCS_FILE generated (Commit: ${GIT_HASH})."
