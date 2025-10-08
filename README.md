# n8n Custom Docker mit ImageMagick für AWS EC2

Custom n8n Docker Image mit ImageMagick-Unterstützung, optimiert für AWS EC2 ARM64 (Graviton).

## 🚀 Schnellstart

Dieses Repository enthält alles, was Sie benötigen, um n8n mit ImageMagick auf AWS EC2 zu deployen:

- ✅ **Dockerfile** - Custom n8n Image mit ImageMagick
- ✅ **GitHub Actions** - Automatischer Multi-Arch Build (ARM64 + x86_64)
- ✅ **Docker Compose** - Komplettes Setup mit PostgreSQL
- ✅ **Setup Script** - Ein-Klick Installation für Amazon Linux 2023
- ✅ **Komplette Anleitung** - Schritt-für-Schritt AWS Deployment Guide

## 📋 Voraussetzungen

- AWS EC2 Instanz (t4g.medium empfohlen für ARM64)
- GitHub Account
- SSH Zugang zu Ihrer EC2 Instanz

## 🎯 Features

- **ImageMagick 7.x** - Vollständige PDF/Bild-Verarbeitung
- **PostgreSQL** - Bessere Performance als SQLite
- **Multi-Architektur** - Läuft auf ARM64 und x86_64
- **Automatische Updates** - Via GitHub Actions
- **HTTPS-Ready** - Anleitung für Let's Encrypt inkludiert
- **Persistente Daten** - Docker Volumes für Workflows und Daten

## 🏃 Deployment in 15 Minuten

### 1. Repository zu GitHub pushen

```bash
git add .
git commit -m "Setup n8n for AWS EC2"
git push origin main
```

### 2. GitHub Actions Build abwarten

- Gehen Sie zu: [Actions Tab](https://github.com/AlphaAmirzh/n8n-custom-docker/actions)
- Warten Sie auf grünen Haken ✅ (3-5 Minuten)
- Package auf "Public" setzen

### 3. AWS Security Group konfigurieren

Port 5678 für n8n öffnen:
- AWS Console → EC2 → Security Groups
- Inbound Rule: TCP Port 5678, Source: 0.0.0.0/0

### 4. SSH zu EC2 und Setup ausführen

```bash
ssh -i /pfad/zu/key.pem ec2-user@IHRE_IP
curl -O https://raw.githubusercontent.com/AlphaAmirzh/n8n-custom-docker/main/amazon-linux-setup.sh
bash amazon-linux-setup.sh
```

### 5. n8n öffnen

```
http://IHRE_IP:5678
```

## 📖 Vollständige Dokumentation

**Detaillierte Schritt-für-Schritt Anleitung:**
👉 [AWS-DEPLOYMENT.md](./AWS-DEPLOYMENT.md)

Enthält:
- Komplette AWS EC2 Setup-Anleitung
- HTTPS Konfiguration mit Let's Encrypt
- Backup & Restore Strategien
- Performance Tuning
- Troubleshooting Guide
- Kosten-Übersicht

## 🔧 Nützliche Befehle

```bash
# Container Status
docker-compose ps

# Logs anzeigen
docker-compose logs -f n8n

# Neustart
docker-compose restart

# Updates
docker-compose pull && docker-compose up -d
```

## 🐳 Lokales Testen (Optional)

```bash
# .env Datei erstellen
cp .env.example .env
# Passwörter in .env anpassen

# Starten
docker-compose up -d

# Öffnen
open http://localhost:5678
```

## 🏗️ Architektur

```
┌─────────────────────────────────────┐
│         GitHub Actions              │
│  (Baut Multi-Arch Docker Image)     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   GitHub Container Registry         │
│   ghcr.io/.../n8n-custom-docker     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│         AWS EC2 Instance            │
│                                     │
│  ┌────────────┐  ┌──────────────┐  │
│  │    n8n     │  │  PostgreSQL  │  │
│  │ +ImageMgck │◄─┤   Database   │  │
│  └────────────┘  └──────────────┘  │
│       ▲                             │
│       │                             │
└───────┼─────────────────────────────┘
        │
        ▼
   Port 5678
  (Web Interface)
```

## 📦 Enthaltene Dateien

- `Dockerfile` - Custom n8n Image mit ImageMagick
- `.github/workflows/docker-build.yml` - GitHub Actions Workflow
- `docker-compose.yml` - Docker Compose Konfiguration
- `amazon-linux-setup.sh` - Automatisches Setup Script
- `.env.example` - Umgebungsvariablen Template
- `AWS-DEPLOYMENT.md` - Vollständige Deployment-Anleitung

## 🔒 Sicherheit

- Basic Auth standardmäßig aktiviert
- Zufällige Passwörter bei Installation
- HTTPS Setup-Anleitung inkludiert
- Security Group Konfiguration dokumentiert

## 💰 Kosten

**Geschätzte monatliche AWS Kosten:**
- t4g.medium (2 vCPUs, 4GB RAM): ~30€/Monat
- t4g.small (1 vCPU, 2GB RAM): ~15€/Monat
- EBS Storage (8GB): ~0,80€/Monat

Details: [Kosten-Übersicht in AWS-DEPLOYMENT.md](./AWS-DEPLOYMENT.md#-kosten-übersicht)

## 🆘 Support

Bei Problemen:
1. Prüfen Sie [Troubleshooting Guide](./AWS-DEPLOYMENT.md#-troubleshooting)
2. Prüfen Sie Logs: `docker-compose logs -f n8n`
3. Erstellen Sie ein GitHub Issue

## 📚 Ressourcen

- [n8n Dokumentation](https://docs.n8n.io)
- [ImageMagick Dokumentation](https://imagemagick.org)
- [Docker Dokumentation](https://docs.docker.com)
- [AWS EC2 Dokumentation](https://docs.aws.amazon.com/ec2)

## 📝 Lizenz

Dieses Projekt verwendet:
- n8n (Fair-Code License)
- ImageMagick (Apache 2.0)
- PostgreSQL (PostgreSQL License)

## 🎉 Viel Erfolg!

Falls Sie Fragen haben oder Hilfe benötigen, schauen Sie in die [AWS-DEPLOYMENT.md](./AWS-DEPLOYMENT.md) - dort finden Sie detaillierte Anleitungen für jeden Schritt.
