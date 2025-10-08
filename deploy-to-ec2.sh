#!/bin/bash

# Schnelles Deployment-Script für AWS EC2
# Führt alle Schritte automatisch aus

set -e

echo "================================================"
echo "n8n Deployment auf AWS EC2 - Automatisch"
echo "================================================"
echo ""

# Konfiguration
EC2_IP="16.62.4.35"
SSH_KEY_PATH="$HOME/.ssh/Joben_SSR.pem"
GITHUB_REPO="https://github.com/AlphaAmirzh/n8n-custom-docker"

# Prüfen ob SSH Key existiert
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "❌ SSH Key nicht gefunden: $SSH_KEY_PATH"
    echo ""
    echo "Bitte geben Sie den Pfad zu Ihrem SSH Key ein:"
    read -p "SSH Key Pfad: " SSH_KEY_PATH
    
    if [ ! -f "$SSH_KEY_PATH" ]; then
        echo "❌ SSH Key immer noch nicht gefunden. Abbruch."
        exit 1
    fi
fi

# Key Permissions prüfen/setzen
chmod 400 "$SSH_KEY_PATH"
echo "✅ SSH Key gefunden: $SSH_KEY_PATH"
echo ""

# SSH Connection testen
echo "🔌 Teste SSH Verbindung zu $EC2_IP..."
if ! ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@$EC2_IP "echo 'SSH OK'" 2>/dev/null; then
    echo "❌ SSH Verbindung fehlgeschlagen!"
    echo "Prüfen Sie:"
    echo "  1. Ist die EC2 Instanz online?"
    echo "  2. Ist Port 22 in der Security Group geöffnet?"
    echo "  3. Ist der SSH Key korrekt?"
    exit 1
fi
echo "✅ SSH Verbindung erfolgreich"
echo ""

# GitHub Actions Build Status prüfen
echo "📦 Prüfe GitHub Actions Build Status..."
echo "Öffnen Sie https://github.com/AlphaAmirzh/n8n-custom-docker/actions"
echo ""
read -p "Ist der GitHub Actions Build erfolgreich (grüner Haken)? (ja/nein): " BUILD_STATUS

if [ "$BUILD_STATUS" != "ja" ]; then
    echo "⏳ Bitte warten Sie, bis der Build erfolgreich ist, dann führen Sie dieses Script erneut aus."
    exit 0
fi
echo "✅ GitHub Actions Build erfolgreich"
echo ""

# Package auf Public prüfen
echo "🔓 Wichtig: Docker Package muss public sein!"
echo "Öffnen Sie https://github.com/AlphaAmirzh?tab=packages"
echo "Klicken Sie auf 'n8n-custom-docker' → Settings → Change visibility → Public"
echo ""
read -p "Ist das Package auf 'Public' gesetzt? (ja/nein): " PACKAGE_PUBLIC

if [ "$PACKAGE_PUBLIC" != "ja" ]; then
    echo "⏳ Bitte setzen Sie das Package auf 'Public', dann führen Sie dieses Script erneut aus."
    exit 0
fi
echo "✅ Package ist public"
echo ""

# Deployment auf EC2
echo "🚀 Starte Deployment auf EC2..."
echo ""

# Setup Script auf EC2 kopieren und ausführen
ssh -i "$SSH_KEY_PATH" ec2-user@$EC2_IP << 'ENDSSH'
set -e

echo "📥 Lade Setup Script herunter..."
curl -sO https://raw.githubusercontent.com/AlphaAmirzh/n8n-custom-docker/main/amazon-linux-setup.sh

echo "🔧 Führe Setup aus..."
bash amazon-linux-setup.sh

# Prüfen ob Docker Gruppe Neustart nötig
if ! groups | grep -q docker; then
    echo ""
    echo "⚠️  Docker-Gruppe wurde hinzugefügt."
    echo "Script wird nach Neuanmeldung fortgesetzt..."
    exit 99
fi

echo ""
echo "✅ Deployment abgeschlossen!"
ENDSSH

EXIT_CODE=$?

if [ $EXIT_CODE -eq 99 ]; then
    echo ""
    echo "🔄 Docker-Gruppe wurde hinzugefügt. Starte Container..."
    sleep 2
    
    # Neu verbinden und Container starten
    ssh -i "$SSH_KEY_PATH" ec2-user@$EC2_IP << 'ENDSSH2'
    cd n8n-custom-docker
    docker-compose up -d
    
    echo ""
    echo "📊 Container Status:"
    docker-compose ps
    
    echo ""
    echo "📋 Login-Daten:"
    echo "════════════════════════════════════════"
    cat .env
    echo "════════════════════════════════════════"
ENDSSH2
fi

echo ""
echo "================================================"
echo "✅ Deployment erfolgreich abgeschlossen!"
echo "================================================"
echo ""
echo "🌐 n8n ist erreichbar unter:"
echo "   http://$EC2_IP:5678"
echo ""
echo "📋 Weitere Befehle (auf EC2):"
echo "   ssh -i $SSH_KEY_PATH ec2-user@$EC2_IP"
echo "   cd n8n-custom-docker"
echo "   docker-compose ps          # Status"
echo "   docker-compose logs -f n8n # Logs"
echo ""
echo "🔒 WICHTIG: Öffnen Sie Port 5678 in der Security Group!"
echo "   AWS Console → EC2 → Security Groups → Inbound Rules"
echo "   Add Rule: TCP Port 5678, Source: 0.0.0.0/0"
echo ""
echo "🎉 Viel Erfolg!"
