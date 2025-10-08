#!/bin/bash

# n8n Setup Script for Amazon Linux 2023 ARM64
# This script automates the installation of Docker, Docker Compose, and n8n

set -e

echo "================================================"
echo "n8n Setup für Amazon Linux 2023 ARM64"
echo "================================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "❌ Bitte führen Sie dieses Script NICHT als root aus!"
    echo "Führen Sie es als normaler Benutzer aus: bash amazon-linux-setup.sh"
    exit 1
fi

echo "✅ Script läuft als Benutzer: $(whoami)"
echo ""

# Update system
echo "📦 System wird aktualisiert..."
sudo dnf update -y
echo "✅ System aktualisiert"
echo ""

# Install Docker
echo "🐳 Docker wird installiert..."
if ! command -v docker &> /dev/null; then
    sudo dnf install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -a -G docker $USER
    echo "✅ Docker installiert"
else
    echo "✅ Docker ist bereits installiert"
fi
echo ""

# Install Docker Compose
echo "🔧 Docker Compose wird installiert..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installiert"
else
    echo "✅ Docker Compose ist bereits installiert"
fi
echo ""

# Install Git
echo "📥 Git wird installiert..."
if ! command -v git &> /dev/null; then
    sudo dnf install -y git
    echo "✅ Git installiert"
else
    echo "✅ Git ist bereits installiert"
fi
echo ""

# Clone repository (if not already in it)
if [ ! -f "docker-compose.yml" ]; then
    echo "📦 Repository wird geklont..."
    git clone https://github.com/AlphaAmirzh/n8n-custom-docker.git
    cd n8n-custom-docker
    echo "✅ Repository geklont"
else
    echo "✅ Bereits im Repository-Verzeichnis"
fi
echo ""

# Create .env file
if [ ! -f ".env" ]; then
    echo "⚙️  .env Datei wird erstellt..."
    cat > .env << EOF
# n8n Configuration
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 32)
N8N_HOST=16.62.4.35

# PostgreSQL Configuration
POSTGRES_USER=n8n
POSTGRES_PASSWORD=$(openssl rand -base64 32)
POSTGRES_DB=n8n
EOF
    echo "✅ .env Datei erstellt mit zufälligen Passwörtern"
    echo ""
    echo "📋 Ihre Zugangsdaten:"
    echo "════════════════════════════════════════"
    cat .env
    echo "════════════════════════════════════════"
    echo ""
    echo "⚠️  WICHTIG: Speichern Sie diese Zugangsdaten!"
else
    echo "✅ .env Datei existiert bereits"
fi
echo ""

# Check if user is in docker group
if ! groups | grep -q docker; then
    echo "⚠️  Wichtiger Hinweis zur Docker-Gruppe:"
    echo "════════════════════════════════════════"
    echo "Sie wurden zur Docker-Gruppe hinzugefügt, aber die Änderung"
    echo "wird erst nach einem Neustart der SSH-Session aktiv."
    echo ""
    echo "Führen Sie EINEN der folgenden Befehle aus:"
    echo ""
    echo "Option 1 (Empfohlen):"
    echo "  exit"
    echo "  # Dann neu einloggen und das Script nochmal ausführen"
    echo ""
    echo "Option 2 (Ohne Neuanmeldung):"
    echo "  newgrp docker"
    echo "  bash amazon-linux-setup.sh"
    echo ""
    echo "Option 3 (Nur für dieses eine Mal):"
    echo "  sudo docker-compose up -d"
    echo "════════════════════════════════════════"
    exit 0
fi

# Start n8n
echo "🚀 n8n wird gestartet..."
docker-compose up -d

echo ""
echo "════════════════════════════════════════"
echo "✅ Installation erfolgreich abgeschlossen!"
echo "════════════════════════════════════════"
echo ""
echo "🌐 n8n läuft jetzt unter:"
echo "   http://16.62.4.35:5678"
echo ""
echo "📊 Container-Status prüfen:"
echo "   docker-compose ps"
echo ""
echo "📋 Logs anzeigen:"
echo "   docker-compose logs -f n8n"
echo ""
echo "🛑 n8n stoppen:"
echo "   docker-compose down"
echo ""
echo "🔄 n8n neustarten:"
echo "   docker-compose restart"
echo ""
echo "🔒 WICHTIG: Öffnen Sie Port 5678 in Ihrer Security Group!"
echo "════════════════════════════════════════"
