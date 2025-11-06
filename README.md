# 🚀 Gensyn CodeAssist - Ubuntu Desktop Kurulum Rehberi

**CodeAssist**, Gensyn tarafından geliştirilen tamamen **yerel** ve **özel** bir yapay zeka kod asistanıdır. Bu rehber, Ubuntu 22.04 Desktop ortamında hızlı ve kolay kurulum için hazırlanmıştır.

![CodeAssist](https://img.shields.io/badge/AI-Code%20Assistant-blue?style=for-the-badge)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-orange?style=for-the-badge&logo=ubuntu)
![Privacy](https://img.shields.io/badge/Privacy-First-green?style=for-the-badge)

---

## 📋 İçindekiler
- [Özellikler](#-özellikler)
- [Sistem Gereksinimleri](#-sistem-gereksinimleri)
- [Otomatik Kurulum](#-otomatik-kurulum)
- [Manuel Kurulum](#-manuel-kurulum)
- [Kullanım Kılavuzu](#-kullanım-kılavuzu)
- [Performans İpuçları](#-performans-i̇puçları)
- [Sorun Giderme](#-sorun-giderme)
- [Güncellemeler](#-güncellemeler)

---

## ✨ Özellikler

- 🔒 **%100 Yerel ve Özel:** Tüm verileriniz bilgisayarınızda kalır
- 🧠 **Öğrenen AI:** Kodlama tarzınıza göre kendini geliştirir
- 🎯 **Akıllı Kod Tamamlama:** Bağlama duyarlı öneriler
- 🚀 **Hızlı Entegrasyon:** Tarayıcı tabanlı, kolay kullanım
- 📊 **Zorluk Seviyeleri:** Easy, Medium, Hard problemler
- 💾 **Model Eğitimi:** Kendi davranışlarınızdan öğrenir

---

## 💻 Sistem Gereksinimleri

### Minimum
- **İşlemci:** 4 CPU çekirdeği
- **RAM:** 8 GB
- **Disk:** 20 GB boş alan (SSD önerilir)
- **İşletim Sistemi:** Ubuntu 22.04 LTS Desktop

### Önerilen
- **İşlemci:** 8+ CPU çekirdeği
- **RAM:** 16 GB
- **Disk:** 50 GB boş alan (SSD)
- **GPU:** CUDA destekli (opsiyonel, hızlandırma için)

---

## ⚡ Otomatik Kurulum

Terminal açın (Ctrl+Alt+T) ve aşağıdaki komutları çalıştırın:

```bash
# 1. Kurulum scriptini indirin
wget https://raw.githubusercontent.com/Edsny1/Gensyn-CodeAssist---Ubuntu-Desktop-Kurulum-Rehberi/refs/heads/Edsny/install.sh

# 2. Scripti çalıştırılabilir yapın
chmod +x install.sh

# 3. Kurulumu başlatın
./install.sh
```

Script otomatik olarak:
- ✅ Sistem güncellemelerini yapar
- ✅ Gerekli paketleri kurar
- ✅ Docker'ı yapılandırır
- ✅ UV paket yöneticisini kurar
- ✅ CodeAssist'i indirir ve yapılandırır

> **Not:** Kurulum sırasında şifreniz istenecektir (sudo yetkisi için).

---

## 🔧 Manuel Kurulum

Adım adım manuel kurulum için:

### 1️⃣ Sistem Hazırlığı

```bash
# Sistemi güncelleyin
sudo apt update && sudo apt upgrade -y

# Gerekli paketleri kurun
sudo apt install -y git curl wget build-essential python3 python3-pip python3-venv
```

### 2️⃣ Docker Kurulumu

```bash
# Docker kurulum
sudo apt install -y docker.io docker-compose

# Docker'ı başlatın
sudo systemctl enable docker
sudo systemctl start docker

# Kullanıcınızı docker grubuna ekleyin
sudo usermod -aG docker $USER

# Grup değişikliğini uygulayın
newgrp docker

# Docker test
docker --version
```

### 3️⃣ UV Paket Yöneticisi

```bash
# UV'yi kurun
curl -LsSf https://astral.sh/uv/install.sh | sh

# PATH'e ekleyin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Kontrol
uv --version
```

### 4️⃣ CodeAssist İndirme

```bash
# Ana dizine gidin
cd ~

# Repoyu klonlayın
git clone https://github.com/gensyn-ai/codeassist.git

# Klasöre girin
cd codeassist
```

### 5️⃣ Hugging Face Token

1. https://huggingface.co adresine gidin
2. Hesap oluşturun veya giriş yapın
3. Settings → Access Tokens
4. **New Token** → **Write** yetkili token oluşturun
5. Token'i kopyalayın (güvenli bir yere kaydedin)

### 6️⃣ İlk Çalıştırma

```bash
# CodeAssist klasöründeyken
cd ~/codeassist

# Uygulamayı başlatın
uv run run.py
```

Tarayıcınızda otomatik olarak `http://localhost:3000` açılacaktır.

---

## 📖 Kullanım Kılavuzu

### İlk Giriş

1. **Tarayıcı:** http://localhost:3000 adresine gidin
2. **Kimlik Doğrulama:** E-posta veya Google ile giriş yapın
3. **Token Girişi:** Hugging Face token'inizi girin
4. **Zorluk Seçimi:** Easy, Medium veya Hard seçin

### Kod Yazma

- Kod editöründe yazmaya başlayın
- AI otomatik olarak öneriler sunacak
- **Tab:** Öneriyi kabul et
- **Esc:** Öneriyi reddet
- **Shift+Space:** Asistanı geçici durdur

### Eğitim Döngüsü

```bash
# 1. Terminal'de CodeAssist çalışırken
# Kod yazın, düzeltin, silin (etkileşimler kaydedilir)

# 2. Bölümü tamamladığınızda
# Terminal'de Ctrl+C tuşlayın

# 3. Eğitim otomatik başlar
# Model, etkileşimlerinizden öğrenir

# 4. Eğitim bitince yeniden başlatın
cd ~/codeassist
uv run run.py
```

### Masaüstü Kısayolu (Opsiyonel)

```bash
# Desktop dosyası oluşturun
cat > ~/.local/share/applications/codeassist.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=CodeAssist
Comment=Gensyn AI Code Assistant
Exec=gnome-terminal -- bash -c "cd ~/codeassist && uv run run.py"
Icon=utilities-terminal
Terminal=false
Categories=Development;
EOF

# Dosyayı çalıştırılabilir yapın
chmod +x ~/.local/share/applications/codeassist.desktop
```

---

## 🎯 Performans İpuçları

### SSD Optimizasyonu

```bash
# TRIM desteğini etkinleştirin
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer
```

### Bellek Yönetimi

```bash
# Swap ayarlarını optimize edin
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Docker Optimizasyonu

```bash
# Docker için kaynak limitleri ayarlayın
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
```

---

## 🔍 Sorun Giderme

### Port Çakışması (3000)

```bash
# Port kullanan işlemi bulun
sudo lsof -i :3000

# İşlemi sonlandırın
sudo kill -9 [PID]
```

### Docker Sorunları

```bash
# Docker durumunu kontrol edin
sudo systemctl status docker

# Container'ları listeleyin
docker ps -a

# Logları görüntüleyin
docker logs [CONTAINER_ID]

# Docker'ı yeniden başlatın
sudo systemctl restart docker
```

### UV Komut Bulunamıyor

```bash
# PATH'i güncelleyin
export PATH="$HOME/.local/bin:$PATH"
source ~/.bashrc

# UV'yi yeniden kurun
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Model Eğitim Hataları

```bash
# Disk alanını kontrol edin
df -h

# Eski model dosyalarını temizleyin
cd ~/codeassist/persistent-data/trainer/models
ls -lh

# Gereksiz dosyaları silin (dikkatli olun!)
# rm -rf [eski_model_dizini]
```

### Hugging Face Bağlantı Sorunu

```bash
# Token'i kontrol edin
cat ~/codeassist/persistent-data/auth/userKeyMap.json

# İnternet bağlantısını test edin
ping -c 4 huggingface.co

# Firewall ayarlarını kontrol edin
sudo ufw status
```

---

## 🔄 Güncellemeler

### CodeAssist Güncelleme

```bash
# CodeAssist dizinine gidin
cd ~/codeassist

# Değişiklikleri kaydedin (varsa)
git stash

# Güncellemeleri çekin
git pull origin main

# Kaydedilen değişiklikleri geri yükleyin
git stash pop

# Yeniden başlatın
uv run run.py
```

### Sistem Güncelleme

```bash
# Sistem paketlerini güncelleyin
sudo apt update && sudo apt upgrade -y

# Docker güncelleme
sudo apt install --only-upgrade docker.io

# UV güncelleme
curl -LsSf https://astral.sh/uv/install.sh | sh
```

---

## 📂 Dizin Yapısı

```
~/codeassist/
├── persistent-data/
│   ├── auth/              # Kimlik bilgileri
│   ├── trainer/           # Eğitim verileri
│   │   └── models/        # Eğitilmiş modeller
│   └── sessions/          # Oturum kayıtları
├── src/                   # Kaynak kodlar
├── requirements.txt       # Python bağımlılıkları
└── run.py                 # Ana çalıştırma scripti
```

---

## 🛡️ Güvenlik Notları

- ⚠️ Hugging Face token'inizi **asla** paylaşmayın
- ⚠️ `persistent-data/auth/` dizinini **yedekleyin**
- ⚠️ Token dosyalarını **Git'e eklemeyin**
- ✅ Düzenli olarak sistem güncellemesi yapın
- ✅ Güçlü şifreler kullanın

---

## 🤝 Katkıda Bulunma

1. Bu repoyu fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/yenilik`)
3. Değişikliklerinizi commit edin (`git commit -am 'Yeni özellik'`)
4. Branch'inizi push edin (`git push origin feature/yenilik`)
5. Pull Request açın

---

## 📞 Destek

- 🐛 **Sorun bildirimi:** [GitHub Issues](https://github.com/Edsny1/gensyn-codeassist-ubuntu/issues)
- 💬 **Tartışmalar:** [GitHub Discussions](https://github.com/Edsny1/gensyn-codeassist-ubuntu/discussions)
- 📧 **E-posta:** [email@example.com]

---

## 📜 Lisans

Bu proje orijinal [Gensyn CodeAssist](https://github.com/gensyn-ai/codeassist) projesinin Ubuntu Desktop için özelleştirilmiş bir kurulum rehberidir.

---

## 🙏 Teşekkürler

- [Gensyn AI](https://github.com/gensyn-ai) - Orijinal CodeAssist projesi
- Ubuntu Community
- Tüm katkıda bulunanlara

---

**⭐ Bu projeyi faydalı bulduysanız yıldız vermeyi unutmayın!**

---

*Son güncelleme: 2025*
