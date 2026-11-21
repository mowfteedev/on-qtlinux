# 05. Triển Khai Dịch Vụ Cấp Phát Địa Chỉ IP (DHCP)

Tài liệu chi tiết theo nguyên mẫu giáo trình trang 14-17 về cài đặt, cấu hình dải cấp phát, cấp cố định theo MAC và bộ lọc DHCP.

---

## 1. Cài đặt và khai báo Interface (Trang 14)
```bash
# Cài đặt dịch vụ
sudo apt install isc-dhcp-server -y
dpkg -l isc-dhcp-server

# Khai báo card mạng lắng nghe trong /etc/default/isc-dhcp-server
sudo sed -i 's/INTERFACESv4=.*/INTERFACESv4="ens33"/' /etc/default/isc-dhcp-server   # <--- THAY ĐỔI: Tên card mạng thực tế
```

---

## 2. File cấu hình `/etc/dhcp/dhcpd.conf` (Trang 14 & 15)

Thêm cấu hình vào cuối file `/etc/dhcp/dhcpd.conf`:

```text
# Quy đổi thời gian thuê thường gặp trong đề thi:
# 15 phút = 15 * 60 = 900 giây (mặc định)
# 1,1 ngày = 1.1 * 86400 = 95040 giây (tối đa)
default-lease-time 900;                       # <--- THAY ĐỔI: Thời gian thuê mặc định (giây)
max-lease-time 95040;                         # <--- THAY ĐỔI: Thời gian thuê tối đa (giây)
authoritative;

subnet 10.0.0.0 netmask 255.0.0.0 {           # <--- THAY ĐỔI: Địa chỉ mạng và subnet mask
    option routers 10.0.0.254;                 # <--- THAY ĐỔI: Địa chỉ Gateway cấp cho Client
    option subnet-mask 255.0.0.0;
    option domain-name "dhcnhn.com";           # <--- THAY ĐỔI: Tên miền
    option domain-name-servers 10.0.0.2;         # <--- THAY ĐỔI: Địa chỉ máy chủ DNS
    
    # 1. Dải cấp động cho sinh viên
    range 10.0.0.100 10.0.0.200;               # <--- THAY ĐỔI: Start IP và End IP của dải cấp động

    # 2. DHCP gán cố định (Reservation) theo địa chỉ MAC
    host may-giang-vien {
        hardware ethernet 00:0c:29:aa:bb:cc;  # <--- THAY ĐỔI: Địa chỉ MAC card mạng của máy GV
        fixed-address 10.0.0.5;                # <--- THAY ĐỔI: Địa chỉ IP cố định cần cấp
    }

    # 3. Bộ lọc từ chối cấp IP (Deny booting - Trang 15)
    host may-bi-chan {
        hardware ethernet 22:22:22:22:22:22;  # <--- THAY ĐỔI: Địa chỉ MAC cần từ chối cấp phát
        deny booting;
    }
}
```

---

## 3. Lệnh kiểm tra cú pháp và điều khiển dịch vụ (Trang 14 & 15)
```bash
# Kiểm tra cú pháp tập tin cấu hình DHCP
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

# Điều khiển dịch vụ
sudo systemctl restart isc-dhcp-server
sudo systemctl status isc-dhcp-server
```

---

## 4. Giải phóng và xin cấp lại IP từ máy Client (Trang 15)
* **Trên Linux Client:**
  ```bash
  sudo dhclient -r                            # Giải phóng địa chỉ IP hiện tại
  sudo dhclient                               # Xin cấp lại địa chỉ IP từ DHCP Server
  ip a
  ```
* **Trên Windows Client:**
  ```cmd
  ipconfig /release
  ipconfig /renew
  ipconfig /all
  ```
