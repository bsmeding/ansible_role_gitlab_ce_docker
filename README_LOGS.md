# Viewing GitLab Container Logs

GitLab CE containers write logs to **files inside the container**, not to stdout/stderr. This means `docker logs gitlab` will appear mostly empty.

## Where are the logs?

GitLab logs are stored in:
- **Inside container**: `/var/log/gitlab/`
- **On host**: `{{ gitlab__home }}/logs/` (default: `/opt/gitlab/logs/`)

## Viewing logs

### Option 1: View log files directly (Recommended)

```bash
# View GitLab Rails logs
tail -f /opt/gitlab/logs/gitlab-rails/production.log

# View GitLab Sidekiq logs
tail -f /opt/gitlab/logs/sidekiq/current

# View GitLab Nginx logs
tail -f /opt/gitlab/logs/nginx/access.log
tail -f /opt/gitlab/logs/nginx/error.log

# View GitLab reconfigure logs
tail -f /opt/gitlab/logs/reconfigure/reconfigure.log

# View all GitLab logs
tail -f /opt/gitlab/logs/**/*.log
```

### Option 2: Use docker exec to view logs inside container

```bash
# View Rails logs
docker exec gitlab tail -f /var/log/gitlab/gitlab-rails/production.log

# View all recent logs
docker exec gitlab find /var/log/gitlab -name "*.log" -type f -exec tail -20 {} \;
```

### Option 3: Change log driver (if you want Docker logs)

If you want to see some output in `docker logs`, you can change the log driver in your playbook vars:

```yaml
gitlab__log_driver: local
gitlab__log_options:
  max-size: '10M'
  max-file: '5'
```

However, this still won't show GitLab application logs - only container startup/error messages.

## Common log locations

- **Rails application**: `/opt/gitlab/logs/gitlab-rails/production.log`
- **Sidekiq (background jobs)**: `/opt/gitlab/logs/sidekiq/current`
- **Nginx**: `/opt/gitlab/logs/nginx/access.log` and `error.log`
- **PostgreSQL**: `/opt/gitlab/logs/postgresql/current`
- **Redis**: `/opt/gitlab/logs/redis/current`
- **Reconfigure**: `/opt/gitlab/logs/reconfigure/reconfigure.log`

## Troubleshooting

If logs directory is empty:
1. Check container is running: `docker ps | grep gitlab`
2. Check volume mount: `docker inspect gitlab | grep -A 5 Mounts`
3. Check permissions: `ls -la /opt/gitlab/logs/`
4. GitLab may still be initializing (can take 5-10 minutes on first start)

