# Ví Dụ 02: Dịch Vụ Cấp Phát DHCP Và Máy Chủ Web Apache2 Virtual Hosts

---

## 1. ĐỀ BÀI

### Câu 1: Cấu hình mạng máy chủ DC01 (2.0 điểm)
Thiết lập Netplan tĩnh cho DC01: IP `10.0.0.2/8`, Gateway `10.0.0.254`, DNS `10.0.0.2`, `8.8.8.8`. Kiểm tra ping thông mạng.

### Câu 2: Triển khai Dịch vụ DHCP Server (4.0 điểm)
Cấu hình gói `isc-dhcp-server` trên DC01 đáp ứng các yêu cầu:
1. Thông số chung: Subnet `10.0.0.0/8`, Gateway `10.0.0.254`, DNS Server `10.0.0.2`, Domain name `dhcnhn.com`.
2. Thời gian thuê địa chỉ mặc định: 5 phút (`300s`); Thời gian thuê tối đa: 1 ngày (`86400s`).
3. Dải cấp động cho máy tính sinh viên: từ `10.0.0.100` đến `10.0.0.200`.
4. Cấu hình DHCP dành riêng (Static Reservation): Gán cố định IP `10.0.0.5` cho máy tính giảng viên có địa chỉ MAC `00:0c:29:11:22:33`.
5. Kiểm tra cú pháp cấu hình và kích hoạt dịch vụ chạy ổn định.

### Câu 3: Triển khai Web ảo Apache2 Virtual Hosts (4.0 điểm)
Cấu hình máy chủ Web Apache2 phục vụ 3 website trên cùng cổng 80:
* Site 1: `googlehaui.com` (Bí danh: `www.googlehaui.com`)
* Site 2: `youtubehaui.com` (Bí danh: `www.youtubehaui.com`)
* Site 3: `facebookhaui.com` (Bí danh: `www.facebookhaui.com`)
Yêu cầu:
* Tạo thư mục `DocumentRoot` và file `index.html` riêng cho từng website.
* Kích hoạt cả 3 website và kiểm tra cú pháp bằng lệnh của Apache.

---

## 2. CÁC LỆNH THỰC THI

### Giải Câu 1: Cấu hình Netplan
```bash
sudo tee /etc/netplan/01-netcfg.yaml << 'EOF'
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: false
      addresses: [10.0.0.2/8]
      routes:
        - to: default
          via: 10.0.0.254
      nameservers:
        addresses: [10.0.0.2, 8.8.8.8]
        search: [dhcnhn.com]
EOF
sudo netplan apply
```

### Giải Câu 2: Cấu hình DHCP Server (`isc-dhcp-server`)
```bash
# 1. Khai báo card mạng lắng nghe trong /etc/default/isc-dhcp-server
sudo sed -i 's/INTERFACESv4=.*/INTERFACESv4="ens33"/' /etc/default/isc-dhcp-server

# 2. Cấu hình /etc/dhcp/dhcpd.conf
sudo tee -a /etc/dhcp/dhcpd.conf << 'EOF'

default-lease-time 300;
max-lease-time 86400;
authoritative;

subnet 10.0.0.0 netmask 255.0.0.0 {
    option routers 10.0.0.254;
    option subnet-mask 255.0.0.0;
    option domain-name "dhcnhn.com";
    option domain-name-servers 10.0.0.2;
    range 10.0.0.100 10.0.0.200;

    host may-giang-vien {
        hardware ethernet 00:0c:29:11:22:33;
        fixed-address 10.0.0.5;
    }
}
EOF

# 3. Kiểm tra cú pháp
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

# 4. Khởi động dịch vụ
sudo systemctl restart isc-dhcp-server
sudo systemctl status isc-dhcp-server
```

### Giải Câu 3: Cấu hình Apache Virtual Hosts
```bash
# 1. Tạo DocumentRoot và file index.html mẫu
for site in googlehaui youtubehaui facebookhaui; do
    sudo mkdir -p /var/www/${site}.com
    echo "<h1>Welcome to ${site}.com</h1>" | sudo tee /var/www/${site}.com/index.html
done

# 2. Tạo 3 file VirtualHost
for site in googlehaui youtubehaui facebookhaui; do
    sudo tee /etc/apache2/sites-available/${site}.com.conf << EOF
<VirtualHost *:80>
    ServerName ${site}.com
    ServerAlias www.${site}.com
    DocumentRoot /var/www/${site}.com
    ErrorLog \${APACHE_LOG_DIR}/${site}_error.log
    CustomLog \${APACHE_LOG_DIR}/${site}_access.log combined
</VirtualHost>
EOF
done

# 3. Kích hoạt cả 3 website & nạp lại cấu hình
sudo a2ensite googlehaui.com.conf youtubehaui.com.conf facebookhaui.com.conf
sudo apache2ctl configtest
sudo systemctl reload apache2

# 4. Kiểm tra nhanh bằng curl
curl -H "Host: googlehaui.com" http://10.0.0.2
curl -H "Host: youtubehaui.com" http://10.0.0.2
curl -H "Host: facebookhaui.com" http://10.0.0.2
```

---

## 3. LƯU Ý KỸ THUẬT

1. **Khởi động DHCP:** Nếu dịch vụ DHCP không khởi động được, kiểm tra file `/etc/default/isc-dhcp-server` đã khai báo đúng tên interface hay chưa, và chạy lệnh `sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf` để xem chi tiết dòng lỗi cú pháp.
2. **Kiểm tra cú pháp Apache:** Lệnh `sudo apache2ctl configtest` cần trả về `Syntax OK` trước khi tải lại dịch vụ.
