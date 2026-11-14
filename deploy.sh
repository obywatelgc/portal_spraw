#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

cd -- "$(dirname -- "$(readlink -f -- "$0")")"
exec 9>.git/deploy.lock
flock -n 9 || { echo 'Inne wdrożenie jest w toku.' >&2; exit 1; }

[[ $(git branch --show-current) == main ]] || { echo 'Wymagana gałąź main.' >&2; exit 1; }
[[ -z $(git status --porcelain) ]] || { echo 'Zapisz lokalne zmiany przed wdrożeniem.' >&2; exit 1; }
test -f .env
git fetch origin main
target=$(git rev-parse origin/main)
git merge-base --is-ancestor HEAD "$target"

backup_root="${HOME}/wz-portal-backups"
mkdir -p "$backup_root"
chmod 700 "$backup_root"
backup_dir=$(mktemp -d "$backup_root/deploy-$(date +%Y%m%d-%H%M%S)-XXXXXX")
git rev-parse HEAD > "$backup_dir/previous-commit"
printf '%s\n' "$target" > "$backup_dir/target-commit"
cp .env "$backup_dir/env"
git archive HEAD | gzip > "$backup_dir/source.tar.gz"
docker compose -p wz-portal exec -T db sh -c \
  'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc' > "$backup_dir/database.dump"
test -s "$backup_dir/database.dump"
echo "Kopia przed wdrożeniem: $backup_dir"

trap 'echo "Wdrożenie przerwane. Sprawdź logi i stan kontenerów. Kopia: $backup_dir" >&2' ERR
git merge --ff-only "$target"
docker compose -p wz-portal config --quiet
docker compose -p wz-portal build web
docker compose -p wz-portal run --rm --no-deps web python manage.py check
docker compose -p wz-portal run --rm --no-deps web python manage.py migrate --noinput
docker compose -p wz-portal run --rm --no-deps web python manage.py collectstatic --noinput
docker compose -p wz-portal up -d --wait --no-deps web caddy
docker compose -p wz-portal exec -T web python manage.py migrate --check
docker compose -p wz-portal exec -T web python - <<'PY'
import os
import time
import urllib.request

host = os.environ['DJANGO_ALLOWED_HOSTS'].split(',')[0].strip()
for attempt in range(10):
    try:
        for path in ('/', '/admin/login/', '/static/admin/css/base.css'):
            request = urllib.request.Request('http://caddy' + path, headers={'Host': host})
            with urllib.request.urlopen(request, timeout=5) as response:
                assert response.status == 200
        break
    except Exception:
        if attempt == 9:
            raise
        time.sleep(2)
print('Test HTTP strony, panelu i zasobów statycznych: OK')
PY
printf '%s\n' "$target" > .git/deployed-commit
docker compose -p wz-portal ps
echo "Wdrożono commit $target"
