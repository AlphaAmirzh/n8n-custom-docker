# 🚀 n8n Quick Start - Finale Anleitung

## Status Check
- ✅ Alle Dateien erstellt und auf GitHub
- ✅ GitHub Actions läuft (Docker Image Build)
- ✅ Security Group Port 5678 muss geöffnet sein

## Problem das wir hatten
Die `.env` Datei konnte im AWS Session Manager nicht erstellt werden (blieb leer). Daher verwenden wir `docker-compose-fixed.yml` mit hardcoded Werten.

---

## 🎯 Finale Lösung - 3 einfache Schritte

### Schritt 1: GitHub Actions Build Status prüfen (1 Min)

Öffnen Sie in einem Browser:
```
https://github.com/AlphaAmirzh/n8n-custom-docker/actions
```

**Warten Sie bis der Build GRÜN ist (✅)**

Falls der Build fehlschlägt, warten Sie 5 Minuten und prüfen Sie erneut.

### Schritt 2: Im AWS Session Manager (5 Min)

Öffnen Sie AWS Session Manager für Ihre EC2 Instanz und führen Sie aus:

```bash
# Zum User wechseln
sudo su - ec2-user

# Alte Container stoppen (falls vorhanden)
docker stop $(docker ps -aq) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null

# Ins Verzeichnis
cd /home/ec2-user

# Repository klonen (falls nicht vorhanden)
if [ ! -d "n8n-custom-docker" ]; then
    git clone https://github.com/AlphaAmirzh/n8n-custom-docker.git
fi

cd n8n-custom-docker

# Neueste Version pullen
git pull

# Mit fixed Datei starten (enthält alle Werte direkt)
sudo docker-compose -f docker-compose-fixed.yml up -d

# 20 Sekunden warten
sleep 20

# Status prüfen
sudo docker ps
```

**Erwartete Ausgabe:**
```
CONTAINER ID   IMAGE                    STATUS         PORTS
xxxxxxxxxx     ghcr.io/alphaamirzh...   Up X seconds   0.0.0.0:5678->5678/tcp
yyyyyyyyyy     postgres:15-alpine       Up X seconds   5432/tcp
```

### Schritt 3: Browser öffnen (1 Min)

```
http://16.62.4.35:5678
```

**Login-Daten:**
- Username: `admin`
- Password: `LogBat52Kp4`

---

## 🐛 Falls es nicht funktioniert

### Diagnose Script ausführen:

```bash
cd /home/ec2-user/n8n-custom-docker
curl -O https://raw.githubusercontent.com/AlphaAmirzh/n8n-custom-docker/main/diagnose.sh
chmod +x diagnose.sh
./diagnose.sh
```

### Häufigste Probleme:

**Problem 1: "No such image" oder Container crasht sofort**
```bash
# Prüfen ob Package public ist
# https://github.com/AlphaAmirzh?tab=packages
# Klick auf n8n-custom-docker → Settings → Change visibility → Public

# Image manuell pullen
sudo docker pull ghcr.io/alphaamirzh/n8n-custom-docker:latest

# Neu starten
sudo docker-compose -f docker-compose-fixed.yml up -d
```

**Problem 2: Port 5678 nicht erreichbar**
```bash
# AWS Console → EC2 → Instances → i-06acacbf0aae45c27
# Tab "Security" → Security Groups
# Inbound rules → Edit inbound rules → Add rule:
#   Type: Custom TCP
#   Port: 5678
#   Source: 0.0.0.0/0
```

**Problem 3: Container zeigt keine Logs**
```bash
# Komplett neu aufsetzen
sudo docker-compose -f docker-compose-fixed.yml down -v
sudo docker system prune -a -f
sudo docker-compose -f docker-compose-fixed.yml pull
sudo docker-compose -f docker-compose-fixed.yml up -d

# Logs live verfolgen
sudo docker logs -f n8n
```

---

## ✅ ImageMagick testen

Nach erfolgreichem Login in n8n:

1. Neuer Workflow erstellen
2. **Execute Command** Node hinzufügen
3. **Command:** `convert --version`
4. **Execute** klicken

**Erwartete Ausgabe:**
```json
{
  "stdout": "Version: ImageMagick 7.1.x Q16 HDRI aarch64..."
}
```

---

## 📋 Zugangsdaten

Speichern Sie diese sicher:

```
n8n URL: http://16.62.4.35:5678
Username: admin
Password: LogBat52Kp4

PostgreSQL (intern):
User: n8n
Password: SecurePostgresPassword456
Database: n8n
```

---

## 🔄 Updates

### n8n auf neue Version aktualisieren:

```bash
cd /home/ec2-user/n8n-custom-docker
sudo docker-compose -f docker-compose-fixed.yml pull
sudo docker-compose -f docker-compose-fixed.yml up -d
```

### Dockerfile ändern:

1. Änderungen auf GitHub pushen
2. Warten bis GitHub Actions fertig ist (grüner Haken)
3. Auf EC2: `sudo docker-compose -f docker-compose-fixed.yml pull && sudo docker-compose -f docker-compose-fixed.yml up -d`

---

## 📞 Support

Bei Problemen:
1. Führen Sie `diagnose.sh` aus
2. Prüfen Sie Logs: `sudo docker logs n8n`
3. Prüfen Sie Security Group Port 5678
4. Prüfen Sie GitHub Package ist Public

**Viel Erfolg! 🎉**
