# ĐỀ THI SỐ 02 (MÃ ĐỀ: 3) - ĐỀ KIỂM TRA THƯỜNG XUYÊN 2

> **Học phần:** Quản trị hệ thống trên nền tảng Linux (FE6092) - HaUI  
> **Hình thức:** Thực hành trên máy ảo (10 điểm)

---

## 1. ĐỀ BÀI CHI TIẾT

Quản trị lớp học MMT và TTDL của Trường ĐHCNHN dựa trên HĐH Linux với đặc điểm và yêu cầu như sau:

### Phần 1: Client tham gia miền và Quản trị tài khoản người dùng/nhóm trong miền (4 điểm)
1. Cấu hình giao diện mạng cho Linux Client và đưa Client này tham gia miền của máy chủ điều khiển miền (3 điểm).
2. Tạo nhóm giảng viên (`gv`) và sinh viên (`sv`) được chứa các tài khoản trong miền (1 điểm):
   * `gv1` – `Giangvien1`; `gv2` – `Giangvien2`
   * `sv1` – `Sinhvien1`; `sv2` – `Sinhvien2`

### Phần 2: Dịch vụ DNS (3 điểm)
1. Tạo vùng tra cứu chuyển tiếp cho vùng DNS: `googlehaui.com`, `youtubehaui.com`, `facebookhaui.com` (2 điểm); Bản ghi loại A cho đối với từng vùng DNS: `www` $\rightarrow$ `10.0.0.2`.
2. Tạo vùng tra cứu ngược cho các vùng DNS nói trên (1 điểm).

### Phần 3: Máy chủ Web (3 điểm)
1. Máy chủ cung cấp dịch vụ Web trên cổng dịch vụ 80 với các tên miền sau:
   * `googlehaui.com` (Bí danh: `www.googlehaui.com`)
   * `youtubehaui.com` (Bí danh: `www.youtubehaui.com`)
2. Tạo các mã nguồn ví dụ đối với từng trang Web. Tạo 2 thư mục con `en` và `vn` trong đường dẫn của mã nguồn Web và tạo thêm các mã nguồn trong 2 thư mục con này. Trình duyệt Web của Client hiển thị tất cả các mã nguồn Web.

---

## 2. CÁC LỆNH THỰC THI (HƯỚNG DẪN TỪNG BƯỚC)

---

### BƯỚC 1: QUẢN TRỊ TÀI KHOẢN MIỀN TRÊN MÁY CHỦ DC01 (1 Điểm)
*Thực hiện trên máy chủ DC01 dưới quyền root:*
```bash
# 1. Tạo 4 tài khoản người dùng trong miền
sudo samba-tool user create gv1 Giangvien1
sudo samba-tool user create gv2 Giangvien2
sudo samba-tool user create sv1 Sinhvien1
sudo samba-tool user create sv2 Sinhvien2

# 2. Tạo 2 nhóm trên miền: gv và sv
sudo samba-tool group add gv
sudo samba-tool group add sv

# 3. Gán thành viên vào nhóm
sudo samba-tool group addmembers gv gv1,gv2
sudo samba-tool group addmembers sv sv1,sv2

# 4. Lệnh kiểm tra cho giáo viên chấm:
sudo samba-tool group listmembers gv
sudo samba-tool group listmembers sv
```

---

### BƯỚC 2: CẤU HÌNH MẠNG & CHO LINUX CLIENT THAM GIA MIỀN (3 Điểm)
*Thực hiện trên máy trạm Linux Client (Client2 - Ubuntu Desktop):*

```bash
# 1. Kiểm tra DNS trỏ về 10.0.0.2 và ping thông miền:
ping -c 2 dhcnhn.com

# 2. Cài đặt các gói công cụ gia nhập miền
sudo apt update
sudo apt install -y sssd sssd-tools realmd adcli

# 3. Bật PAM tự động tạo thư mục home khi đăng nhập lần đầu
echo "session optional pam_mkhomedir.so skel=/etc/skel umask=0077" | sudo tee -a /etc/pam.d/common-session

# 4. Cho phép người dùng miền đăng nhập
echo "* ; * ; * ; Al0000-2400 ; domain users" | sudo tee -a /etc/security/group.conf

# 5. Thực hiện tham gia miền (Mật khẩu: Dhcnhn1)
sudo realm -v join dhcnhn.com -U administrator

# 6. Kiểm tra lấy điểm:
realm list
id gv1@dhcnhn.com
```

---

### BƯỚC 3: DỊCH VỤ DNS BẰNG `samba-tool dns` TRÊN DC01 (3 Điểm)
*Thực hiện trên máy chủ DC01:*

```bash
# 1. Tạo 3 vùng tra cứu chuyển tiếp (Forward Zones):
sudo samba-tool dns zonecreate dc01.dhcnhn.com googlehaui.com -U administrator
sudo samba-tool dns zonecreate dc01.dhcnhn.com youtubehaui.com -U administrator
sudo samba-tool dns zonecreate dc01.dhcnhn.com facebookhaui.com -U administrator

# 2. Tạo bản ghi loại A: www -> 10.0.0.2 cho từng vùng:
sudo samba-tool dns add dc01.dhcnhn.com googlehaui.com www A 10.0.0.2 -U administrator
sudo samba-tool dns add dc01.dhcnhn.com youtubehaui.com www A 10.0.0.2 -U administrator
sudo samba-tool dns add dc01.dhcnhn.com facebookhaui.com www A 10.0.0.2 -U administrator

# 3. Tạo vùng tra cứu ngược (Reverse Zone) cho dải 10.0.0.0/8:
sudo samba-tool dns zonecreate dc01.dhcnhn.com 10.in-addr.arpa -U administrator

# 4. Tạo bản ghi ngược PTR cho địa chỉ 10.0.0.2 (2.0.0):
sudo samba-tool dns add dc01.dhcnhn.com 10.in-addr.arpa 2.0.0 PTR www.googlehaui.com -U administrator

# 5. Lệnh truy vấn kiểm tra cho giáo viên chấm:
sudo samba-tool dns query dc01.dhcnhn.com googlehaui.com @ ALL -U administrator
sudo samba-tool dns query dc01.dhcnhn.com youtubehaui.com @ ALL -U administrator
sudo samba-tool dns query dc01.dhcnhn.com facebookhaui.com @ ALL -U administrator
sudo samba-tool dns query dc01.dhcnhn.com 10.in-addr.arpa @ ALL -U administrator
```

---

### BƯỚC 4: TRIỂN KHAI MÁY CHỦ WEB APACHE2 VỚI THƯ MỤC EN VÀ VN (3 Điểm)
*Thực hiện trên máy chủ DC01:*

```bash
# 1. Cài đặt Apache2 nếu chưa cài
sudo apt install -y apache2

# 2. Tạo cấu trúc thư mục gồm mã nguồn gốc và 2 thư mục con en, vn cho cả 2 trang:
for site in googlehaui youtubehaui; do
    # Tạo thư mục gốc và thư mục con en, vn
    sudo mkdir -p /var/www/${site}.com/{en,vn}
    
    # Tạo trang chủ gốc
    echo "<h1>Trang chu ${site}.com</h1>" | sudo tee /var/www/${site}.com/index.html
    
    # Tạo trang con tiếng Anh (en)
    echo "<h1>English Version of ${site}.com</h1>" | sudo tee /var/www/${site}.com/en/index.html
    
    # Tạo trang con tiếng Việt (vn)
    echo "<h1>Phien ban Tieng Viet cua ${site}.com</h1>" | sudo tee /var/www/${site}.com/vn/index.html
    
    # Phân quyền www-data
    sudo chown -R www-data:www-data /var/www/${site}.com
    sudo chmod -R 755 /var/www/${site}.com
done

# 3. Soạn thảo cấu hình Virtual Host cho googlehaui.com:
sudo tee /etc/apache2/sites-available/googlehaui.com.conf << 'EOF'
<VirtualHost *:80>
    ServerName googlehaui.com
    ServerAlias www.googlehaui.com
    DocumentRoot /var/www/googlehaui.com
    ErrorLog ${APACHE_LOG_DIR}/googlehaui_error.log
    CustomLog ${APACHE_LOG_DIR}/googlehaui_access.log combined
</VirtualHost>
EOF

# 4. Soạn thảo cấu hình Virtual Host cho youtubehaui.com:
sudo tee /etc/apache2/sites-available/youtubehaui.com.conf << 'EOF'
<VirtualHost *:80>
    ServerName youtubehaui.com
    ServerAlias www.youtubehaui.com
    DocumentRoot /var/www/youtubehaui.com
    ErrorLog ${APACHE_LOG_DIR}/youtubehaui_error.log
    CustomLog ${APACHE_LOG_DIR}/youtubehaui_access.log combined
</VirtualHost>
EOF

# 5. Kích hoạt Virtual Hosts và nạp lại Apache:
sudo a2ensite googlehaui.com.conf youtubehaui.com.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
```

---

## 3. KIỂM THỬ TRÊN TRÌNH DUYỆT WEB CỦA CLIENT (YÊU CẦU ĐỀ)

Từ máy trạm Client (Windows hoặc Linux):
1. Mở trình duyệt Web (Firefox/Chrome/Edge).
2. Kiểm tra truy cập lần lượt các đường dẫn:
   * `http://www.googlehaui.com` $\rightarrow$ Hiển thị trang chủ `googlehaui.com`
   * `http://www.googlehaui.com/en` $\rightarrow$ Hiển thị trang tiếng Anh (`en`)
   * `http://www.googlehaui.com/vn` $\rightarrow$ Hiển thị trang tiếng Việt (`vn`)
   * `http://www.youtubehaui.com` $\rightarrow$ Hiển thị trang chủ `youtubehaui.com`
   * `http://www.youtubehaui.com/en` $\rightarrow$ Hiển thị trang tiếng Anh (`en`)
   * `http://www.youtubehaui.com/vn` $\rightarrow$ Hiển thị trang tiếng Việt (`vn`)

---

## 4. LƯU Ý KỸ THUẬT QUAN TRỌNG

1. **Thư mục con `en` và `vn`:** Apache tự động ánh xạ thư mục con trong `DocumentRoot`. Khi truy cập `http://www.googlehaui.com/en`, Apache sẽ tự tìm file `/var/www/googlehaui.com/en/index.html`. Không cần cấu hình thêm `Alias` trong Apache!
2. **DNS trên Client:** Để máy Client gõ được tên miền `www.googlehaui.com` trên trình duyệt, máy Client **bắt buộc phải trỏ DNS về `10.0.0.2`** (nơi vừa tạo bản ghi A ở Bước 3).
