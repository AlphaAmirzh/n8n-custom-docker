# n8n Deployment auf AWS EC2 ARM64 - Komplette Anleitung

Diese Anleitung führt Sie Schritt-für-Schritt durch das Deployment von n8n mit ImageMagick auf Ihrer AWS EC2 Instanz.

## 📋 Ihre EC2 Instanz - Übersicht

```
Instance ID:       i-06acacbf0aae45c27
Instance Type:     t4g.medium (ARM64 Graviton2)
AMI:               Amazon Linux 2023 ARM64
Region:            eu-central-2 (Zürich)
Public IP:         16.62.4.35
Public DNS:        ec2-16-62-4-35.eu-central-2.compute.amazonaws.com
SSH Key:           Joben_SSR
```

## 🚀 Schnellstart (15 Minuten)

### Schritt 1: Repository zu GitHub pushen (5 Min)

```bash
# Lokales Terminal (in diesem Verzeichnis)
git add .
git commit -m "Add n8n Docker setup for AWS EC2"
git push origin main
```

**Was passiert jetzt:**
- GitHub Actions startet automatisch
- Baut Docker Image für ARM64 + x86_64
- Pusht zu GitHub Container Registry
- Dauert ca. 3-5 Minuten

**Build Status prüfen:**
1. Gehen Sie zu: https://github.com/AlphaAmirzh/n8n-custom-docker/actions
2. Warten Sie auf grünen Haken ✅
3. Falls fehlgeschlagen: Siehe Troubleshooting unten

### Schritt 2: Package auf Public setzen (2 Min)

Nach erfolgreichem Build:
1. Gehen Sie zu: https://github.com/AlphaAmirzh?tab=packages
2. Klicken Sie auf `n8n-custom-docker`
3. Rechts oben: "Package settings" (Zahnrad-Icon)
4. Ganz unten: "Change visibility"
5. Wählen Sie: "Public"
6. Bestätigen Sie

**Wichtig:** Das Package muss public sein, damit EC2 es pullen kann!

### Schritt 3: Security Group konfigurieren (3 Min)

**Port 5678 für n8n öffnen:**

1. AWS Console → EC2 → Instances
2. Wählen Sie Ihre Instanz: `i-06acacbf0aae45c27`
3. Tab "Security" → Security Groups klicken
4. "Inbound rules" → "Edit inbound rules"
5. "Add rule":
   ```
   Type:        Custom TCP
   Port range:  5678
   Source:      0.0.0.0/0 (oder Ihre spezifische IP für mehr Sicherheit)
   Description: n8n Web Interface
   ```
6. "Save rules"

**Optional: Port 443 für HTTPS (später):**
```
Type:        HTTPS
Port range:  443
Source:      0.0.0.0/0
Description: HTTPS for n8n
```

### Schritt 4: SSH Verbindung (1 Min)

```bash
# Von Ihrem lokalen Terminal
ssh -i /pfad/zu/Joben_SSR.pem ec2-user@16.62.4.35
```

**Typische SSH Key Locations:**
- macOS/Linux: `~/.ssh/Joben_SSR.pem`
- Windows: `C:\Users\YourName\.ssh\Joben_SSR.pem`

**Falls Permission denied:**
```bash
chmod 400 /pfad/zu/Joben_SSR.pem
```

### Schritt 5: Setup Script ausführen (4 Min)

```bash
# Auf der EC2 Instanz
curl -O https://raw.githubusercontent.com/AlphaAmirzh/n8n-custom-docker/main/amazon-linux-setup.sh
bash amazon-linux-setup.sh
```

**Das Script macht automatisch:**
1. ✅ System Update
2. ✅ Docker Installation
3. ✅ Docker Compose Installation
4. ✅ Git Installation
5. ✅ Repository klonen
6. ✅ .env Datei mit zufälligen Passwörtern erstellen
7. ✅ n8n starten

**Wichtig:** Bei der ersten Ausführung:
- Script fügt Sie zur Docker-Gruppe hinzu
- Sie müssen sich einmal neu einloggen:
  ```bash
  exit
  ssh -i /pfad/zu/Joben_SSR.pem ec2-user@16.62.4.35
  cd n8n-custom-docker
  docker-compose up -d
  ```

### Schritt 6: n8n testen! 🎉

```
URL: http://16.62.4.35:5678
```

**Login-Daten finden:**
```bash
# Auf EC2
cd n8n-custom-docker
cat .env
```

**ImageMagick testen:**
1. n8n öffnen
2. Neuer Workflow erstellen
3. "Execute Command" Node hinzufügen
4. Command: `convert --version`
5. Execute Workflow

**Erwartete Ausgabe:**
```json
{
  "stdout": "Version: ImageMagick 7.1.x Q16 HDRI aarch64...",
  "exitCode": 0
}
```

## 🔧 Nützliche Befehle

### Container Management

```bash
# Status prüfen
docker-compose ps

# Logs anzeigen (alle Services)
docker-compose logs -f

# Nur n8n Logs
docker-compose logs -f n8n

# Container neustarten
docker-compose restart

# Container stoppen
docker-compose down

# Container stoppen + Volumes löschen (ACHTUNG: Löscht alle Daten!)
docker-compose down -v

# Neu starten (z.B. nach .env Änderungen)
docker-compose up -d

# Images aktualisieren
docker-compose pull
docker-compose up -d
```

### System Monitoring

```bash
# Disk Space prüfen
df -h

# Docker Disk Usage
docker system df

# RAM/CPU Usage
top
# Drücken Sie 'q' zum Beenden

# Alle Docker Container
docker ps -a

# Docker Logs live
docker logs -f n8n
```

### Cleanup

```bash
# Ungenutzte Docker Images entfernen
docker image prune -a

# Ungenutzte Volumes entfernen (VORSICHT!)
docker volume prune

# Komplettes Cleanup
docker system prune -a --volumes
```

## 🔒 HTTPS Setup mit Let's Encrypt (Optional)

### Voraussetzungen
- Domain (z.B. `n8n.ihre-domain.com`)
- DNS A-Record zeigt auf `16.62.4.35`

### Installation

```bash
# Auf EC2
cd n8n-custom-docker

# Nginx + Certbot installieren
sudo dnf install -y nginx certbot python3-certbot-nginx

# SSL Zertifikat erhalten
sudo certbot --nginx -d n8n.ihre-domain.com

# Nginx Konfiguration erstellen
sudo tee /etc/nginx/conf.d/n8n.conf << 'EOF'
server {
    listen 80;
    server_name n8n.ihre-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name n8n.ihre-domain.com;

    ssl_certificate /etc/letsencrypt/live/n8n.ihre-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/n8n.ihre-domain.com/privkey.pem;

    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Connection '';
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        chunked_transfer_encoding off;
        proxy_buffering off;
        proxy_cache off;
    }
}
EOF

# Nginx starten
sudo systemctl enable nginx
sudo systemctl start nginx

# .env anpassen
nano .env
# Ändern Sie:
# N8N_HOST=n8n.ihre-domain.com
# N8N_PROTOCOL=https
# WEBHOOK_URL=https://n8n.ihre-domain.com/

# n8n neu starten
docker-compose up -d
```

**Automatische Zertifikat-Erneuerung:**
```bash
# Cronjob für automatische Erneuerung
sudo crontab -e
# Fügen Sie hinzu:
0 0 * * 0 certbot renew --quiet && systemctl reload nginx
```

## 💾 Backup & Restore

### Backup erstellen

```bash
# Auf EC2
cd n8n-custom-docker

# Alle Daten sichern
mkdir -p ~/backups
docker-compose exec -T postgres pg_dump -U n8n n8n > ~/backups/n8n-backup-$(date +%Y%m%d-%H%M%S).sql
tar -czf ~/backups/n8n-data-$(date +%Y%m%d-%H%M%S).tar.gz \
  /var/lib/docker/volumes/n8n-custom-docker_n8n_data \
  /var/lib/docker/volumes/n8n-custom-docker_n8n_files

echo "Backup erstellt in ~/backups/"
```

### Backup herunterladen (auf lokalem PC)

```bash
# Von Ihrem lokalen Terminal
scp -i /pfad/zu/Joben_SSR.pem ec2-user@16.62.4.35:~/backups/* ./local-backup/
```

### Restore durchführen

```bash
# Auf EC2
cd n8n-custom-docker

# Container stoppen
docker-compose down

# Datenbank wiederherstellen
docker-compose up -d postgres
sleep 10
cat ~/backups/n8n-backup-TIMESTAMP.sql | docker-compose exec -T postgres psql -U n8n n8n

# Daten wiederherstellen
sudo tar -xzf ~/backups/n8n-data-TIMESTAMP.tar.gz -C /

# Alles neu starten
docker-compose up -d
```

## 🔄 Updates

### n8n auf neue Version aktualisieren

```bash
# Auf EC2
cd n8n-custom-docker

# WICHTIG: Erst Backup erstellen!
docker-compose exec -T postgres pg_dump -U n8n n8n > ~/n8n-backup-before-update.sql

# Update durchführen
docker-compose pull
docker-compose up -d

# Logs prüfen
docker-compose logs -f n8n
```

### Docker Image neu bauen

Änderungen am Dockerfile in GitHub pushen:
```bash
# Lokal
git add Dockerfile
git commit -m "Update Dockerfile"
git push origin main
```

Nach erfolgreichem GitHub Actions Build (3-5 Min):
```bash
# Auf EC2
cd n8n-custom-docker
docker-compose pull
docker-compose up -d
```

## 🐛 Troubleshooting

### Problem: n8n startet nicht

**Lösung 1: Logs prüfen**
```bash
docker-compose logs n8n
docker-compose logs postgres
```

**Lösung 2: Ports prüfen**
```bash
sudo netstat -tulpn | grep 5678
# Sollte Docker Process zeigen
```

**Lösung 3: .env Datei prüfen**
```bash
cat .env
# Alle Variablen gesetzt?
```

### Problem: ImageMagick "not found"

**Lösung: Image Version prüfen**
```bash
docker-compose exec n8n convert --version
# Sollte ImageMagick Version zeigen

# Falls nicht, neues Image pullen:
docker-compose pull
docker-compose up -d --force-recreate
```

### Problem: "Cannot connect to database"

**Lösung: PostgreSQL Status**
```bash
docker-compose ps
# postgres sollte "healthy" sein

docker-compose exec postgres pg_isready -U n8n
# Sollte "accepting connections" zeigen

# Neustart:
docker-compose restart postgres
sleep 10
docker-compose restart n8n
```

### Problem: GitHub Actions Build fehlgeschlagen

**Häufigste Ursachen:**

1. **Package nicht public:**
   - GitHub → Packages → n8n-custom-docker → Settings → Public

2. **Dockerfile Syntax Error:**
   - Prüfen Sie die Build-Logs in GitHub Actions
   - Jede Zeile im Dockerfile korrekt?

3. **Workflow File falsch:**
   - Muss in `.github/workflows/docker-build.yml` sein
   - Exakt mit Punkt am Anfang!

### Problem: "Permission denied" beim docker-compose

**Lösung:**
```bash
# Option 1: Neu einloggen
exit
ssh -i /pfad/zu/Joben_SSR.pem ec2-user@16.62.4.35

# Option 2: Gruppe neu laden
newgrp docker

# Option 3: Mit sudo (nicht empfohlen)
sudo docker-compose up -d
```

### Problem: Disk Space voll

**Lösung:**
```bash
# Ungenutzte Docker Daten entfernen
docker system prune -a
docker volume prune

# Alte Logs löschen
sudo journalctl --vacuum-time=7d
```

## 💰 Kosten-Übersicht

### Ihre aktuelle Konfiguration

**EC2 t4g.medium (ARM64):**
- 2 vCPUs, 4 GB RAM
- On-Demand: ~0,0416€/Stunde
- **Monatlich: ~30€** (24/7 laufend)

**Weitere Kosten:**
- EBS Storage (Standard 8 GB): ~0,10€/GB/Monat = ~0,80€
- Datenübertragung: Erste 100 GB/Monat kostenlos
- **Total: ~31€/Monat**

### Kosten sparen

**Option 1: Instance nur bei Bedarf laufen lassen**
```bash
# EC2 Console → Instance → Actions → Stop Instance
# Keine laufenden Kosten, nur Storage (~0,80€/Monat)
```

**Option 2: Kleinere Instance (für Tests)**
```
t4g.small: 1 vCPU, 2 GB RAM = ~15€/Monat
t4g.micro: 1 vCPU, 1 GB RAM = ~7,50€/Monat (nur für Tests!)
```

**Option 3: Reserved Instance (1-3 Jahre)**
- 30-60% Ersparnis
- Nur bei langfristiger Nutzung sinnvoll

## 📊 Performance Tuning

### n8n für Production optimieren

**.env Anpassungen:**
```bash
# Mehr Worker Threads
EXECUTIONS_PROCESS=main
N8N_CONCURRENCY_PRODUCTION_LIMIT=10

# Execution Timeout erhöhen
EXECUTIONS_TIMEOUT=300
EXECUTIONS_TIMEOUT_MAX=3600

# Mehr Memory für Node.js
NODE_OPTIONS=--max-old-space-size=2048
```

### PostgreSQL optimieren

**docker-compose.yml anpassen:**
```yaml
postgres:
  # ... existing config ...
  command: postgres -c 'max_connections=100' -c 'shared_buffers=256MB'
```

### Monitoring einrichten

```bash
# htop für besseres Monitoring
sudo dnf install -y htop
htop

# Docker Stats
docker stats
```

## 🎯 Nächste Schritte

Nach erfolgreicher Installation:

1. ✅ **Backup-Strategie einrichten**
   - Automatische tägliche Backups
   - Backups lokal herunterladen

2. ✅ **HTTPS aktivieren**
   - Domain einrichten
   - Let's Encrypt Zertifikat

3. ✅ **Workflows importieren**
   - Ihre bestehenden Workflows importieren
   - Mit ImageMagick testen

4. ✅ **Monitoring**
   - CloudWatch Alarme einrichten
   - Disk Space Monitoring

5. ✅ **Security hardening**
   - Security Group: Nur spezifische IPs
   - AWS IAM Rollen prüfen
   - SSH Key Security

## 📞 Support & Ressourcen

**n8n Dokumentation:**
- https://docs.n8n.io

**ImageMagick Dokumentation:**
- https://imagemagick.org/script/command-line-options.php

**Docker Dokumentation:**
- https://docs.docker.com

**AWS EC2 Dokumentation:**
- https://docs.aws.amazon.com/ec2

## ✅ Abschluss-Checkliste

Stellen Sie sicher, dass alles funktioniert:

- [ ] GitHub Actions Build erfolgreich (grüner Haken)
- [ ] Package ist public
- [ ] Security Group Port 5678 geöffnet
- [ ] SSH Verbindung funktioniert
- [ ] Docker & Docker Compose installiert
- [ ] n8n läuft (docker-compose ps zeigt "Up")
- [ ] n8n Web Interface erreichbar (http://16.62.4.35:5678)
- [ ] Login funktioniert
- [ ] ImageMagick verfügbar (convert --version)
- [ ] PostgreSQL läuft (healthy)
- [ ] Backup erstellt
- [ ] Zugangsdaten sicher gespeichert

**🎉 Herzlichen Glückwunsch! Ihre n8n Instanz ist produktionsbereit!**
