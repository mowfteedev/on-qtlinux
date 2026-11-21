# 01. Thay Đổi Giao Diện Mạng (Netplan)

Nội dung hướng dẫn cấu hình địa chỉ IP tĩnh trên máy chủ DC01 bằng Netplan và kiểm tra kết nối mạng.

---

## 1. Thông số mạng quy định
* **Địa chỉ IP:** `10.0.0.2/8` (Subnet mask: `255.0.0.0`)
* **Default Gateway:** `10.0.0.254`
* **DNS Server:** `10.0.0.2, 8.8.8.8`
* **Search domain:** `dhcnhn.com`

---

## 2. File cấu hình `/etc/netplan/01-netcfg.yaml`

Chạy lệnh `ip link` kiểm tra tên card mạng (thường là `ens33`):

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: false
      addresses:
        - 10.0.0.2/8
      routes:
        - to: default
          via: 10.0.0.254
      nameservers:
        addresses: [10.0.0.2, 8.8.8.8]
        search: [dhcnhn.com]
```

> [!NOTE]
> Netplan sử dụng định dạng YAML, các cấp thụt dòng bằng dấu cách (space), không sử dụng phím Tab.

---

## 3. Lệnh áp dụng và kiểm tra

```bash
# Áp dụng cấu hình
sudo netplan apply

# Kiểm tra địa chỉ IP đã nhận
ip a show ens33

# Kiểm tra bảng định tuyến
ip r

# Kiểm tra kết nối
ping -c 2 10.0.0.254
ping -c 2 8.8.8.8
```

---

## 4. Cấu hình trên máy Client (Windows và Linux)
* **Client1 (Windows 10):**
  * Đặt IP: `10.0.0.11/8`, Gateway: `10.0.0.254`.
  * Preferred DNS Server: `10.0.0.2`.
* **Client2 (Ubuntu Desktop):**
  * Đặt IP: `10.0.0.22/8`, Gateway: `10.0.0.254`.
  * DNS: `10.0.0.2`.
