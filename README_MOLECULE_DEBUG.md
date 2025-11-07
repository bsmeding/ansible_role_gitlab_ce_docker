# Debugging GitLab in Molecule Tests

When running Molecule tests, you need to access the GitLab container from **inside** the Molecule instance container (Docker-in-Docker setup).

## Quick Access to Instance Container

```bash
# Find the Molecule instance container name
docker ps | grep instance

# Access the instance container shell
docker exec -it <instance-container-name> bash

# Or if you know it's the default scenario:
docker exec -it $(docker ps --filter "name=instance" --format "{{.Names}}" | head -1) bash
```

## From Inside Instance Container

Once inside the instance container, you can:

```bash
# Check if GitLab container is running
docker ps | grep gitlab

# View GitLab container logs
docker logs -f gitlab

# Check GitLab service status
docker exec gitlab /opt/gitlab/bin/gitlab-ctl status

# Check if GitLab is responding
curl http://127.0.0.1:8080/-/health

# Check reconfigure log (when it appears)
tail -f /opt/gitlab/logs/reconfigure/reconfigure.log

# List log files (once GitLab initializes)
ls -la /opt/gitlab/logs/
```

## From Host Machine

You can also check from your host machine:

```bash
# Find Molecule instance
MOLECULE_INSTANCE=$(docker ps --filter "name=instance" --format "{{.Names}}" | head -1)

# Check GitLab container status
docker exec $MOLECULE_INSTANCE docker ps | grep gitlab

# View GitLab logs
docker exec $MOLECULE_INSTANCE docker logs -f gitlab

# Check GitLab service status
docker exec $MOLECULE_INSTANCE docker exec gitlab /opt/gitlab/bin/gitlab-ctl status

# Check logs directory
docker exec $MOLECULE_INSTANCE ls -la /opt/gitlab/logs/
```

## Using the Helper Script

```bash
# From host machine
./check_gitlab_status.sh

# Or copy script to instance and run there
docker exec -it <instance> bash -c "bash < /path/to/check_gitlab_status.sh --molecule"
```

## Common Issues

### Empty logs directory
- **Normal**: GitLab takes 5-10 minutes to fully initialize
- **Check**: `docker exec gitlab /opt/gitlab/bin/gitlab-ctl status` to see which services are running

### Container not starting
- **Check**: `docker logs gitlab` for errors
- **Check**: `docker exec gitlab /opt/gitlab/bin/gitlab-ctl tail` for service logs

### Can't access from host
- Remember: GitLab runs **inside** the Molecule instance container
- Port mapping: `8080:80` means access from host at `http://localhost:8080`
- From instance container: access at `http://127.0.0.1:8080` or `http://gitlab:80`

