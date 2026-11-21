# 05. Triển Khai Dịch Vụ Cấp Phát Địa Chỉ IP (DHCP)

Hướng dẫn cài đặt và cấu hình `isc-dhcp-server`: cấp IP động theo phạm vi (pool), cấp cố định theo địa chỉ MAC (Reservation) và bộ lọc từ chối cấp phát.

---

## 1. Cài đặt và khai báo Interface lắng nghe
```bash
# Cài đặt gói dịch vụ
sudo apt update
sudo apt install -y isc-dhcp-server

# Khai báo card mạng lắng nghe trong /etc/default/isc-dhcp-server
# Sửa dòng INTERFACESv4 thành tên card mạng thực tế (ens33)
sudo sed -i 's/INTERFACESv4=.*/INTERFACESv4="ens33"/' /etc/default/isc-dhcp-server
```

---

## 2. File cấu hình `/etc/dhcp/dhcpd.conf`

Chỉnh sửa file cấu hình chính:
```bash
sudo nano /etc/dhcp/dhcpd.conf
```

Thêm cấu hình phân dải mạng vào cuối file:

```text
# Cấu hình thời gian thuê
default-lease-time 300;       # 5 phút
max-lease-time 86400;         # 1 ngày
authoritative;

subnet 10.0.0.0 netmask 255.0.0.0 {
    option routers 10.0.0.254;
    option subnet-mask 255.0.0.0;
    option domain-name "dhcnhn.com";
    option domain-name-servers 10.0.0.2;

    # 1. Dải cấp phát động cho sinh viên
    range 10.0.0.100 10.0.0.200;

    # 2. DHCP gán cố định (Reservation) cho máy Giảng viên theo MAC
    host may-giang-vien {
        hardware ethernet 00:0c:29:aa:bb:cc;  # Địa chỉ MAC của máy trạm GV
        fixed-address 10.0.0.5;
    }

    # 3. Bộ lọc từ chối cấp IP cho thiết bị chỉ định
    host may-bi-chan {
        hardware ethernet 22:22:22:22:22:22;
        deny booting;
    }
}
```

---

## 3. Kiểm tra cú pháp và khởi động dịch vụ

```bash
# Kiểm tra cú pháp file cấu hình
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

# Khởi động lại dịch vụ
sudo systemctl restart isc-dhcp-server

# Kiểm tra trạng thái hoạt động
sudo systemctl status isc-dhcp-server
```

---

## 4. Kiểm tra nhận IP từ máy Client
* **Trên Windows Client:**
  ```cmd
  ipconfig /release
  ipconfig /renew
  ipconfig /all
  ```
* **Trên Linux Client:**
  ```bash
  sudo dhclient -r
  sudo dhclient -v
  ip a
  ```
