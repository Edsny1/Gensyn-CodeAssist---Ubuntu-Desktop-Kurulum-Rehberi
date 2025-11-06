# 🔧 CodeAssist Sorun Giderme Rehberi

Bu rehber, Ubuntu 22.04 Desktop'ta CodeAssist kullanırken karşılaşabileceğiniz yaygın sorunları ve çözümlerini içerir.

---

## 📋 İçindekiler

- [Genel Sorunlar](#genel-sorunlar)
- [Docker Sorunları](#docker-sorunları)
- [Port ve Ağ Sorunları](#port-ve-ağ-sorunları)
- [Performans Sorunları](#performans-sorunları)
- [Eğitim Sorunları](#eğitim-sorunları)
- [Kimlik Doğrulama Sorunları](#kimlik-doğrulama-sorunları)
- [Gelişmiş Sorun Giderme](#gelişmiş-sorun-giderme)

---

## Genel Sorunlar

### ❌ "uv: command not found"

**Sebep:** UV paket yöneticisi PATH'te değil.

**Çözüm:**
```bash
# PATH'i kontrol edin
echo $PATH

# UV'yi PATH'e ekleyin
export PATH="$HOME/.local/bin:$PATH"

# Kalıcı olması için .bashrc'ye ekleyin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# UV'yi yeniden kurun (gerekirse)
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### ❌ "Permission denied" hataları

**Sebep:** Gerekli dosya/klasör izinleri yok.

**Çözüm:**
```bash
# CodeAssist dizini için izinleri düzeltin
cd ~
sudo chown -R $USER:$USER codeassist/
chmod -R 755 codeassist/

# Docker grubu için
sudo usermod -aG docker $USER
newgrp docker
```

### ❌ "Module not found" Python hataları

**Sebep:** Bağımlılıklar eksik veya bozuk.

**Çözüm:**
```bash
cd ~/codeassist

# Önbellekleri temizleyin
uv cache clean

# Bağımlılıkları yeniden yükleyin
uv sync --reinstall

# Python sürümünü kontrol edin
python3 --version  # 3.10+ olmalı
```

---

## Docker Sorunları

### ❌ "Cannot connect to Docker daemon"

**Sebep:** Docker servisi çalışmıyor veya kullanıcı yetkisi yok.

**Çözüm:**
```bash
# Docker durumunu kontrol edin
sudo systemctl status docker

# Çalışmıyorsa başlatın
sudo systemctl start docker
sudo systemctl enable docker

# Kullanıcı grubunu kontrol edin
groups | grep docker

# Yoksa ekleyin
sudo usermod -aG docker $USER
newgrp docker

# Bilgisayarı yeniden başlatın (önerilen)
sudo reboot
```

### ❌ "Container is unhealthy"

**Sebep:** Docker container'ı düzgün başlatılamadı.

**Çözüm:**
```bash
# Tüm container'ları listeleyin
docker ps -a

# Sorunlu container'ı silin
docker rm -f [CONTAINER_ID]

# Image'leri kontrol edin
docker images

# Kullanılmayan image'leri temizleyin
docker image prune -a

# Docker'ı yeniden başlatın
sudo systemctl restart docker

# CodeAssist'i yeniden başlatın
cd ~/codeassist
uv run run.py
```

### ❌ Docker disk dolması

**Sebep:** Eski container ve image'ler yer kaplıyor.

**Çözüm:**
```bash
# Docker disk kullanımını görün
docker system df

# Tüm kullanılmayan kaynakları temizleyin
docker system prune -a --volumes

# Spesifik temizlik
docker container prune  # Durmuş container'lar
docker image prune -a   # Kullanılmayan image'ler
docker volume prune     # Kullanılmayan volume'ler
```

---

## Port ve Ağ Sorunları

### ❌ "Port 3000 already in use"

**Sebep:** Başka bir uygulama 3000 portunu kullanıyor.

**Çözüm 1: Portu kullanan uygulamayı kapatın**
```bash
# Port kullanan işlemi bulun
sudo lsof -i :3000
# veya
sudo netstat -tulpn | grep :3000

# İşlemi sonlandırın
sudo kill -9 [PID]
```

**Çözüm 2: Farklı port kullanın**
```bash
# Ortam değişkeni ile port değiştirin
export PORT=3001
cd ~/codeassist
uv run run.py
```

### ❌ "localhost:3000" tarayıcıda açılmıyor

**Sebep:** Servis başlamadı veya güvenlik duvarı engelliyor.

**Çözüm:**
```bash
# Servis çalışıyor mu kontrol edin
ps aux | grep run.py

# Port dinleniyor mu kontrol edin
sudo lsof -i :3000

# Güvenlik duvarını kontrol edin
sudo ufw status

# Port 3000'i açın
sudo ufw allow 3000/tcp

# Localhost yerine 127.0.0.1 deneyin
# http://127.0.0.1:3000

# Manuel tarayıcı başlatma
xdg-open http://localhost:3000
```

### ❌ Ağ bağlantı sorunları (Hugging Face)

**Sebep:** İnternet bağlantısı veya proxy sorunu.

**Çözüm:**
```bash
# İnternet bağlantısını test edin
ping -c 4 huggingface.co
ping -c 4 8.8.8.8

# DNS sorunları için
sudo systemctl restart systemd-resolved

# Proxy kullanıyorsanız
export HTTP_PROXY="http://proxy.example.com:8080"
export HTTPS_PROXY="http://proxy.example.com:8080"

# Hosts dosyasını kontrol edin
cat /etc/hosts
```

---

## Performans Sorunları

### 🐌 Yavaş çalışma / donmalar

**Çözüm:**
```bash
# 1. Sistem kaynaklarını kontrol edin
htop  # veya: top

# 2. CPU kullanımı
ps aux --sort=-%cpu | head -10

# 3. RAM kullanımı
free -h

# 4. Disk I/O
iostat -x 1

# 5. Gereksiz servisleri kapatın
systemctl list-units --type=service --state=running

# 6. Swap kullanımını azaltın
sudo sysctl vm.swappiness=10
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
```

### 🐌 Yavaş model eğitimi

**Çözüm:**
```bash
# 1. GPU kullanımını kontrol edin (varsa)
nvidia-smi

# 2. Daha küçük bölümlerle eğitin
# Daha az satır kod ile eğitim yapın

# 3. Paralel işlem sayısını azaltın
# run.py'de config ayarlarını düzenleyin

# 4. Disk hızını optimize edin (SSD kullanın)
sudo fstrim -av

# 5. RAM disk kullanın (isteğe bağlı)
sudo mkdir -p /mnt/ramdisk
sudo mount -t tmpfs -o size=4G tmpfs /mnt/ramdisk
```

### 💾 Disk alanı dolması

**Çözüm:**
```bash
# Disk kullanımını kontrol edin
df -h
du -sh ~/codeassist/*

# Eski model dosyalarını temizleyin
cd ~/codeassist/persistent-data/trainer/models
ls -lht  # Tarihe göre sırala

# Eski modelleri silin (DİKKATLİ!)
rm -rf old_model_directory

# Log dosyalarını temizleyin
find ~/codeassist -name "*.log" -type f -mtime +7 -delete

# Docker temizliği
docker system prune -a --volumes

# Sistem cache temizliği
sudo apt clean
sudo apt autoclean
```

---

## Eğitim Sorunları

### ❌ "Training failed" hatası

**Sebep:** Yetersiz veri, bellek sorunu veya bozuk checkpoint.

**Çözüm:**
```bash
# 1. Yeterli etkileşim var mı kontrol edin
ls -la ~/codeassist/persistent-data/sessions/

# 2. Checkpoint'leri kontrol edin
cd ~/codeassist/persistent-data/trainer/
find . -name "checkpoint*"

# 3. Bozuk checkpoint'leri silin
rm -rf corrupted_checkpoint/

# 4. Eğitim loglarını inceleyin
cat ~/codeassist/persistent-data/trainer/training.log

# 5. Daha az veri ile test edin
# İlk eğitimde kısa oturumlar yapın

# 6. Bellek limitlerini artırın
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb=512
```

### ❌ Model yükleme hatası

**Sebep:** Bozuk model dosyası veya versiyon uyumsuzluğu.

**Çözüm:**
```bash
# 1. Model dosyalarını kontrol edin
cd ~/codeassist/persistent-data/trainer/models/
ls -lh

# 2. Bozuk modeli yedekleyin ve silin
mv current_model current_model.bak
rm -rf current_model

# 3. Temiz başlangıç
cd ~/codeassist
git pull  # Güncellemeleri çek
uv run run.py

# 4. Cache temizliği
rm -rf ~/.cache/huggingface/
```

---

## Kimlik Doğrulama Sorunları

### ❌ "Invalid Hugging Face token"

**Sebep:** Token yanlış, süresi dolmuş veya yetki eksik.

**Çözüm:**
```bash
# 1. Token'i kontrol edin
cat ~/codeassist/persistent-data/auth/userKeyMap.json

# 2. Yeni token oluşturun
# https://huggingface.co/settings/tokens
# Write yetkisi olduğundan emin olun

# 3. Eski token'i silin
rm ~/codeassist/persistent-data/auth/userKeyMap.json

# 4. CodeAssist'i yeniden başlatın ve giriş yapın
cd ~/codeassist
uv run run.py
```

### ❌ Google giriş çalışmıyor

**Sebep:** Tarayıcı cookie/cache sorunu.

**Çözüm:**
```bash
# 1. Tarayıcı cache'ini temizleyin
# Chrome/Firefox: Ctrl+Shift+Del

# 2. Gizli pencerede deneyin
# Chrome: Ctrl+Shift+N
# Firefox: Ctrl+Shift+P

# 3. E-posta girişi kullanın
# Google yerine e-posta seçeneğini deneyin

# 4. Farklı tarayıcı deneyin
firefox http://localhost:3000
google-chrome http://localhost:3000
```

---

## Gelişmiş Sorun Giderme

### 🔍 Detaylı log toplama

```bash
# Sistem logları
journalctl -xe > ~/codeassist_system.log

# Docker logları
docker logs $(docker ps -q) > ~/codeassist_docker.log

# CodeAssist logları
cd ~/codeassist
cat persistent-data/trainer/*.log > ~/codeassist_training.log

# Tüm logları paketleyin
tar -czf ~/codeassist_logs_$(date +%Y%m%d).tar.gz \
    ~/codeassist_system.log \
    ~/codeassist_docker.log \
    ~/codeassist_training.log
```

### 🔍 Sistem bilgisi toplama

```bash
# Donanım bilgisi
lscpu > ~/system_info.txt
free -h >> ~/system_info.txt
df -h >> ~/system_info.txt
lspci | grep VGA >> ~/system_info.txt

# Yazılım sürümleri
echo "Python: $(python3 --version)" >> ~/system_info.txt
echo "Docker: $(docker --version)" >> ~/system_info.txt
echo "UV: $(uv --version)" >> ~/system_info.txt
echo "Git: $(git --version)" >> ~/system_info.txt

cat ~/system_info.txt
```

### 🔄 Temiz yükleme (Factory Reset)

```bash
# UYARI: Tüm veriler silinecek!

# 1. CodeAssist'i durdurun
pkill -f "run.py"

# 2. Docker container'larını silin
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# 3. Verileri yedekleyin (isteğe bağlı)
cp -r ~/codeassist/persistent-data ~/codeassist_backup

# 4. CodeAssist'i silin
rm -rf ~/codeassist

# 5. Yeniden klonlayın
cd ~
git clone https://github.com/gensyn-ai/codeassist.git
cd codeassist

# 6. Başlatın
uv run run.py
```

---

## 📞 Hala Sorun mu Yaşıyorsunuz?

1. **GitHub Issues:** Sorun bildirin
2. **Logları paylaşın:** Yukarıdaki komutlarla toplanan logları ekleyin
3. **Sistem bilgisi:** Donanım ve yazılım sürümlerini belirtin
4. **Tekrar üretilebilirlik:** Sorunu nasıl tekrar oluşturabileceğinizi açıklayın

---

## 💡 Faydalı Kaynaklar

- [Resmi Dokümantasyon](https://github.com/gensyn-ai/codeassist)
- [Ubuntu Yardım](https://help.ubuntu.com/)
- [Docker Dokümantasyon](https://docs.docker.com/)
- [Hugging Face Rehberi](https://huggingface.co/docs)

---

*Son güncelleme: 2025*
