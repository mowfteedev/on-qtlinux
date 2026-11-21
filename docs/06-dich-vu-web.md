# 06. Triển Khai Máy Chủ Web Ảo (Apache2 Virtual Hosts)

Hướng dẫn cấu hình Web Server Apache2 phục vụ nhiều tên miền độc lập trên cùng cổng 80 (Name-based Virtual Hosting).

---

## 1. Cài đặt Apache2
```bash
sudo apt update
sudo apt install -y apache2
```

---

## 2. Tạo cấu trúc thư mục DocumentRoot và trang chủ
Tạo thư mục lưu trữ mã nguồn cho 3 website: `googlehaui.com`, `youtubehaui.com`, `facebookhaui.com`:

```bash
for site in googlehaui youtubehaui facebookhaui; do
    sudo mkdir -p /var/www/${site}.com
    echo "<h1>Welcome to ${site}.com</h1>" | sudo tee /var/www/${site}.com/index.html
    sudo chown -R www-data:www-data /var/www/${site}.com
    sudo chmod -R 755 /var/www/${site}.com
done
```

---

## 3. Soạn thảo các file cấu hình VirtualHost

Tạo 3 file cấu hình trong thư mục `/etc/apache2/sites-available/`:

### File `/etc/apache2/sites-available/googlehaui.com.conf`
```apache
<VirtualHost *:80>
    ServerName googlehaui.com
    ServerAlias www.googlehaui.com
    DocumentRoot /var/www/googlehaui.com
    ErrorLog ${APACHE_LOG_DIR}/googlehaui_error.log
    CustomLog ${APACHE_LOG_DIR}/googlehaui_access.log combined
</VirtualHost>
```

### File `/etc/apache2/sites-available/youtubehaui.com.conf`
```apache
<VirtualHost *:80>
    ServerName youtubehaui.com
    ServerAlias www.youtubehaui.com
    DocumentRoot /var/www/youtubehaui.com
    ErrorLog ${APACHE_LOG_DIR}/youtubehaui_error.log
    CustomLog ${APACHE_LOG_DIR}/youtubehaui_access.log combined
</VirtualHost>
```

### File `/etc/apache2/sites-available/facebookhaui.com.conf`
```apache
<VirtualHost *:80>
    ServerName facebookhaui.com
    ServerAlias www.facebookhaui.com
    DocumentRoot /var/www/facebookhaui.com
    ErrorLog ${APACHE_LOG_DIR}/facebookhaui_error.log
    CustomLog ${APACHE_LOG_DIR}/facebookhaui_access.log combined
</VirtualHost>
```

---

## 4. Kích hoạt và tải lại cấu hình

```bash
# Kích hoạt 3 site mới
sudo a2ensite googlehaui.com.conf youtubehaui.com.conf facebookhaui.com.conf

# Kiểm tra cú pháp (bắt buộc hiển thị Syntax OK)
sudo apache2ctl configtest

# Tải lại dịch vụ Apache2
sudo systemctl reload apache2
```

---

## 5. Kiểm tra truy cập
Kiểm tra bằng lệnh `curl` gửi kèm tiêu đề Host:
```bash
curl -H "Host: googlehaui.com" http://10.0.0.2
curl -H "Host: youtubehaui.com" http://10.0.0.2
curl -H "Host: facebookhaui.com" http://10.0.0.2
```
