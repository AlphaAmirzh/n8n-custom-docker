#!/bin/bash
echo "=== Docker Container Status ==="
sudo docker ps
echo ""
echo "=== Alle Container (inkl. gestoppte) ==="
sudo docker ps -a
echo ""
echo "=== Port 5678 Status ==="
sudo netstat -tulpn | grep 5678
echo ""
echo "=== Verfügbare Images ==="
sudo docker images
echo ""
echo "=== n8n Container Logs (falls vorhanden) ==="
sudo docker logs n8n 2>&1 | tail -20 || echo "Kein Container mit Namen 'n8n' gefunden"
echo ""
echo "=== Container auf Port 5678 Logs ==="
CONTAINER_ID=$(sudo docker ps -q -f "publish=5678" 2>/dev/null)
if [ ! -z "$CONTAINER_ID" ]; then
    echo "Container ID: $CONTAINER_ID"
    sudo docker logs $CONTAINER_ID 2>&1 | tail -20
else
    echo "Kein Container auf Port 5678 gefunden"
fi
