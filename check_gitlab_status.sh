#!/bin/bash
# Quick script to check GitLab container status and initialization progress
# 
# Usage:
#   From HOST (local machine): ./check_gitlab_status.sh
#   From MOLECULE instance container: ./check_gitlab_status.sh --molecule
#   Or manually: docker exec -it <molecule-instance> bash, then run commands below

if [ "$1" == "--molecule" ]; then
    # Running from inside Molecule instance container
    echo "=== Running from inside Molecule instance container ==="
    echo ""
    
    echo "=== GitLab Container Status ==="
    docker ps --filter "name=gitlab" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo -e "\n=== Recent GitLab Container Logs (last 20 lines) ==="
    docker logs --tail 20 gitlab 2>&1 | tail -20
    
    echo -e "\n=== Check GitLab service status (inside GitLab container) ==="
    docker exec gitlab /opt/gitlab/bin/gitlab-ctl status 2>/dev/null || echo "Services still starting..."
    
    echo -e "\n=== Check if GitLab is responding ==="
    timeout 5 curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://127.0.0.1:8080/ || echo "Not responding yet (still initializing)"
    
    echo -e "\n=== Check GitLab reconfigure log ==="
    if [ -f /opt/gitlab/logs/reconfigure/reconfigure.log ]; then
        echo "Last 10 lines of reconfigure log:"
        tail -10 /opt/gitlab/logs/reconfigure/reconfigure.log
    else
        echo "Reconfigure log not found yet (GitLab still initializing)"
        echo "Logs directory contents:"
        ls -la /opt/gitlab/logs/ 2>/dev/null || echo "Logs directory doesn't exist yet"
    fi
else
    # Running from host machine
    echo "=== Running from HOST machine ==="
    echo ""
    
    # Try to find Molecule instance container
    MOLECULE_INSTANCE=$(docker ps --filter "name=instance" --format "{{.Names}}" | head -1)
    
    if [ -z "$MOLECULE_INSTANCE" ]; then
        echo "ERROR: No Molecule instance container found."
        echo "Make sure Molecule test is running: molecule converge"
        echo ""
        echo "Available containers:"
        docker ps --format "table {{.Names}}\t{{.Status}}"
        exit 1
    fi
    
    echo "Found Molecule instance: $MOLECULE_INSTANCE"
    echo ""
    
    echo "=== GitLab Container Status (from instance) ==="
    docker exec $MOLECULE_INSTANCE docker ps --filter "name=gitlab" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "GitLab container not found"
    
    echo -e "\n=== Recent GitLab Container Logs ==="
    docker exec $MOLECULE_INSTANCE docker logs --tail 20 gitlab 2>&1 | tail -20
    
    echo -e "\n=== Check GitLab service status ==="
    docker exec $MOLECULE_INSTANCE docker exec gitlab /opt/gitlab/bin/gitlab-ctl status 2>/dev/null || echo "Services still starting..."
    
    echo -e "\n=== Check GitLab reconfigure log ==="
    docker exec $MOLECULE_INSTANCE test -f /opt/gitlab/logs/reconfigure/reconfigure.log && \
        docker exec $MOLECULE_INSTANCE tail -10 /opt/gitlab/logs/reconfigure/reconfigure.log || \
        echo "Reconfigure log not found yet (GitLab still initializing)"
    
    echo -e "\n=== To run commands inside instance container: ==="
    echo "  docker exec -it $MOLECULE_INSTANCE bash"
    echo "  Then run: docker ps, docker logs gitlab, etc."
fi

