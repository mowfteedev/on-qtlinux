# 06. Triển Khai Máy Chủ Web Ảo (Apache2 Virtual Hosts)

Tài liệu chi tiết theo nguyên mẫu giáo trình trang 15 và 17 về cấu hình máy chủ Web Apache và Virtual Hosts.

---

## 1. Cài đặt và quản lý dịch vụ (Trang 15)
```bash
sudo apt install apache2 -y
sudo systemctl restart apache2
sudo systemctl status apache2
```

---

## 2. Tạo DocumentRoot và mã nguồn Website (Trang 15 & 17)
### 2.1. Cấu trúc cơ bản
Tạo thư mục lưu trữ mã nguồn cho 3 website: `googlehaui.com`, `youtubehaui.com`, `facebookhaui.com`:

```bash
for site in googlehaui youtubehaui facebookhaui; do
    sudo mkdir -p /var/www/${site}.com                                            # SỬA: Tên thư mục web
    echo "<h1>Welcome to ${site}.com</h1>" | sudo tee /var/www/${site}.com/index.html
    sudo chown -R www-data:www-data /var/www/${site}.com
    sudo chmod -R 755 /var/www/${site}.com
done
```

### 2.2. Dạng đề thi nâng cao: Tạo thêm thư mục con `en` và `vn`
Khi đề bài yêu cầu: *"Tạo 2 thư mục con en và vn trong đường dẫn mã nguồn Web và hiển thị tất cả trên trình duyệt"*:
```bash
for site in googlehaui youtubehaui; do
    # Tạo thư mục gốc và 2 thư mục con
    sudo mkdir -p /var/www/${site}.com/{en,vn}
    
    # Tạo nội dung cho từng thư mục
    echo "<h1>Trang chu ${site}.com</h1>" | sudo tee /var/www/${site}.com/index.html
    echo "<h1>English Version of ${site}.com</h1>" | sudo tee /var/www/${site}.com/en/index.html
    echo "<h1>Phien ban Tieng Viet ${site}.com</h1>" | sudo tee /var/www/${site}.com/vn/index.html
    
    sudo chown -R www-data:www-data /var/www/${site}.com
    sudo chmod -R 755 /var/www/${site}.com
done
```
* **Cách truy cập từ Client:**
  - Trang chủ: `http://www.googlehaui.com`
  - Trang tiếng Anh: `http://www.googlehaui.com/en`
  - Trang tiếng Việt: `http://www.googlehaui.com/vn`

---

## 3. Cấu hình file Virtual Host trong `/etc/apache2/sites-available/` (Trang 15)

Mẫu file `/etc/apache2/sites-available/googlehaui.com.conf`:
```apache
<VirtualHost *:80>
    ServerAdmin webmaster@googlehaui.com
    DocumentRoot /var/www/googlehaui.com       # SỬA: Đường dẫn DocumentRoot
    ServerName googlehaui.com                 # SỬA: Tên miền chính
    ServerAlias www.googlehaui.com             # SỬA: Tên miền bí danh (alias)
    ErrorLog ${APACHE_LOG_DIR}/googlehaui_error.log
    CustomLog ${APACHE_LOG_DIR}/googlehaui_access.log combined
</VirtualHost>
```

---

## 4. Kích hoạt và vô hiệu hóa Site (Trang 15)
```bash
# Kích hoạt các Virtual Host mới
sudo a2ensite googlehaui.com.conf youtubehaui.com.conf facebookhaui.com.conf     # SỬA: Tên file config cần bật

# Vô hiệu hóa site mặc định (nếu cần)
sudo a2dissite 000-default.conf

# Kiểm tra cú pháp (bắt buộc hiển thị Syntax OK)
sudo apache2ctl configtest

# Tải lại dịch vụ
sudo systemctl reload apache2
```

---

## 5. Kiểm tra truy cập
```bash
curl -H "Host: googlehaui.com" http://10.0.0.2
curl -H "Host: youtubehaui.com" http://10.0.0.2
curl -H "Host: facebookhaui.com" http://10.0.0.2
```
