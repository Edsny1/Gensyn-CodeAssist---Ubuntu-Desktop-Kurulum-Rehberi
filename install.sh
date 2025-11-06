#!/bin/bash
#
# Gensyn CodeAssist - Ubuntu 22.04 Desktop Otomatik Kurulum
# Bu script tüm gerekli bileşenleri otomatik olarak kurar
#

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logo
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════╗
║                                               ║
║     Gensyn CodeAssist Kurulum Sihirbazı      ║
║          Ubuntu 22.04 Desktop                 ║
║                                               ║
╚═══════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Fonksiyonlar
print_step() {
    echo -e "${BLUE}[ADIM]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

check_ubuntu_version() {
    print_step "Ubuntu sürümü kontrol ediliyor..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$VERSION_ID" == "22.04" ]]; then
            print_success "Ubuntu 22.04 tespit edildi"
        else
            print_warning "Bu script Ubuntu 22.04 için optimize edilmiştir. Mevcut sürüm: $VERSION_ID"
            read -p "Devam etmek istiyor musunuz? (e/h): " choice
            if [[ "$choice" != "e" ]]; then
                print_error "Kurulum iptal edildi"
                exit 1
            fi
        fi
    fi
}

check_resources() {
    print_step "Sistem kaynakları kontrol ediliyor..."
    
    # CPU kontrolü
    cpu_cores=$(nproc)
    if [ "$cpu_cores" -lt 4 ]; then
        print_warning "Minimum 4 CPU çekirdeği önerilir. Mevcut: $cpu_cores"
    else
        print_success "CPU: $cpu_cores çekirdek"
    fi
    
    # RAM kontrolü
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$total_ram" -lt 8 ]; then
        print_warning "Minimum 8 GB RAM önerilir. Mevcut: ${total_ram}GB"
    else
        print_success "RAM: ${total_ram}GB"
    fi
    
    # Disk kontrolü
    free_space=$(df -BG ~ | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$free_space" -lt 20 ]; then
        print_error "Minimum 20 GB boş alan gerekli. Mevcut: ${free_space}GB"
        exit 1
    else
        print_success "Disk: ${free_space}GB boş alan"
    fi
}

install_system_packages() {
    print_step "Sistem paketleri kuruluyor..."
    
    sudo apt update -qq
    sudo apt install -y -qq \
        git \
        curl \
        wget \
        build-essential \
        python3 \
        python3-pip \
        python3-venv \
        ca-certificates \
        gnupg \
        lsb-release
    
    print_success "Sistem paketleri kuruldu"
}

install_docker() {
    print_step "Docker kuruluyor..."
    
    if command -v docker &> /dev/null; then
        print_success "Docker zaten kurulu: $(docker --version)"
        return
    fi
    
    # Docker kurulumu
    sudo apt install -y docker.io docker-compose
    
    # Docker servisini başlat
    sudo systemctl enable docker
    sudo systemctl start docker
    
    # Kullanıcıyı docker grubuna ekle
    sudo usermod -aG docker $USER
    
    print_success "Docker kuruldu"
    print_warning "Docker grup değişikliği için oturumu kapatıp açmanız gerekebilir"
}

install_uv() {
    print_step "UV paket yöneticisi kuruluyor..."
    
    if command -v uv &> /dev/null; then
        print_success "UV zaten kurulu: $(uv --version)"
        return
    fi
    
    # UV kurulumu
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # PATH'e ekle
    export PATH="$HOME/.local/bin:$PATH"
    
    # .bashrc'ye ekle
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    
    print_success "UV kuruldu"
}

clone_codeassist() {
    print_step "CodeAssist indiriliyor..."
    
    cd ~
    
    if [ -d "codeassist" ]; then
        print_warning "CodeAssist dizini zaten mevcut"
        read -p "Yeniden klonlamak istiyor musunuz? (e/h): " choice
        if [[ "$choice" == "e" ]]; then
            rm -rf codeassist
        else
            return
        fi
    fi
    
    git clone https://github.com/gensyn-ai/codeassist.git
    
    print_success "CodeAssist indirildi: ~/codeassist"
}

create_desktop_shortcut() {
    print_step "Masaüstü kısayolu oluşturuluyor..."
    
    mkdir -p ~/.local/share/applications
    
    cat > ~/.local/share/applications/codeassist.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=CodeAssist
Comment=Gensyn AI Code Assistant
Exec=gnome-terminal -- bash -c "cd ~/codeassist && uv run run.py; exec bash"
Icon=utilities-terminal
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF
    
    chmod +x ~/.local/share/applications/codeassist.desktop
    
    print_success "Masaüstü kısayolu oluşturuldu"
}

setup_firewall() {
    print_step "Güvenlik duvarı yapılandırılıyor..."
    
    if command -v ufw &> /dev/null; then
        sudo ufw allow 3000/tcp comment "CodeAssist Web Interface"
        print_success "Port 3000 açıldı"
    else
        print_warning "UFW bulunamadı, güvenlik duvarı yapılandırması atlandı"
    fi
}

optimize_system() {
    print_step "Sistem optimizasyonları yapılıyor..."
    
    # Swap ayarı
    if ! grep -q "vm.swappiness=10" /etc/sysctl.conf; then
        echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        print_success "Swap optimizasyonu yapıldı"
    fi
    
    # Docker log ayarları
    sudo mkdir -p /etc/docker
    if [ ! -f /etc/docker/daemon.json ]; then
        sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
        sudo systemctl restart docker
        print_success "Docker logging yapılandırıldı"
    fi
}

create_launcher_script() {
    print_step "Başlatıcı script oluşturuluyor..."
    
    cat > ~/codeassist/start.sh <<'EOF'
#!/bin/bash
cd ~/codeassist
export PATH="$HOME/.local/bin:$PATH"
uv run run.py
EOF
    
    chmod +x ~/codeassist/start.sh
    
    print_success "Başlatıcı script: ~/codeassist/start.sh"
}

show_next_steps() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Kurulum Başarıyla Tamamlandı!        ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Sonraki Adımlar:${NC}"
    echo ""
    echo "1️⃣  Hugging Face hesabı oluşturun:"
    echo "   → https://huggingface.co"
    echo "   → Settings → Access Tokens → New Token"
    echo "   → Write yetkisi ile token oluşturun"
    echo ""
    echo "2️⃣  Oturumu yenileyin (Docker grup değişikliği için):"
    echo "   $ logout"
    echo "   Veya bilgisayarı yeniden başlatın"
    echo ""
    echo "3️⃣  CodeAssist'i başlatın:"
    echo "   $ cd ~/codeassist"
    echo "   $ uv run run.py"
    echo ""
    echo "4️⃣  Tarayıcıda açın:"
    echo "   → http://localhost:3000"
    echo ""
    echo -e "${BLUE}İpuçları:${NC}"
    echo "  • Masaüstü kısayolu oluşturuldu (Uygulamalar menüsünde)"
    echo "  • Sorunlar için: ~/codeassist/README.md"
    echo "  • Güncellemeler: cd ~/codeassist && git pull"
    echo ""
    echo -e "${GREEN}İyi kodlamalar! 🚀${NC}"
    echo ""
}

# Ana kurulum
main() {
    clear
    
    check_ubuntu_version
    check_resources
    
    echo ""
    read -p "Kuruluma devam etmek istiyor musunuz? (e/h): " confirm
    if [[ "$confirm" != "e" ]]; then
        print_error "Kurulum iptal edildi"
        exit 0
    fi
    
    echo ""
    install_system_packages
    install_docker
    install_uv
    clone_codeassist
    create_launcher_script
    create_desktop_shortcut
    setup_firewall
    optimize_system
    
    echo ""
    show_next_steps
}

# Scripti çalıştır
main
