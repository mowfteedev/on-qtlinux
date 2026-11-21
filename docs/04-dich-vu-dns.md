# 04. Dịch Vụ Phân Giải Tên Miền (DNS)

Tài liệu chi tiết theo nguyên mẫu giáo trình trang 10 và 11 về quản trị DNS bằng `samba-tool` và gói phần mềm BIND9.

---

## 1. Quản trị DNS bằng dòng lệnh `samba-tool dns` (Trang 10 & 13)

Thực hiện trên máy chủ điều khiển miền `dc01.dhcnhn.com`:

```bash
# 1. Tạo vùng tra cứu xuôi và ngược
samba-tool dns zonecreate dc01.dhcnhn.com googlehaui.com -U administrator   # <--- THAY ĐỔI: Tên zone xuôi cần tạo
samba-tool dns zonecreate dc01.dhcnhn.com 10.in-addr.arpa -U administrator  # <--- THAY ĐỔI: Tên zone ngược (dải 10.0.0.0/8 đảo thành 10.in-addr.arpa)

# 2. Thêm bản ghi A (xuôi) và PTR (ngược)
samba-tool dns add dc01.dhcnhn.com googlehaui.com www A 10.0.0.2 -U administrator         # <--- THAY ĐỔI: Tên bản ghi và IP
samba-tool dns add dc01.dhcnhn.com 10.in-addr.arpa 2.0.0 PTR www.googlehaui.com -U administrator # <--- THAY ĐỔI: 10.0.0.2 đảo thành 2.0.0

# 3. Cập nhật và Xóa bản ghi
samba-tool dns update dc01.dhcnhn.com googlehaui.com www A 10.0.0.2 10.0.0.11 -U administrator # <--- Cập nhật IP cũ sang mới
samba-tool dns delete dc01.dhcnhn.com googlehaui.com www A 10.0.0.2 -U administrator           # <--- Xóa bản ghi

# 4. Liệt kê và Kiểm tra
samba-tool dns zonelist dc01.dhcnhn.com -U administrator
samba-tool dns zoneinfo dc01.dhcnhn.com googlehaui.com -U administrator
samba-tool dns query dc01.dhcnhn.com googlehaui.com @ ALL -U administrator
```

---

## 2. Quản trị DNS sử dụng gói BIND9 (Nguyên mẫu Trang 11)

### 2.1. Cài đặt và quản lý dịch vụ
```bash
sudo apt install bind9 dnsutils -y
dpkg -l bind9
sudo systemctl restart bind9
sudo systemctl status bind9
```

### 2.2. Khai báo vùng trong `/etc/bind/named.conf.local`
```text
zone "dhcnhn.com" {                           # <--- THAY ĐỔI: Tên vùng xuôi
    type master;
    file "/etc/bind/forward.dhcnhn.com";
};

zone "10.in-addr.arpa" {                      # <--- THAY ĐỔI: Tên vùng ngược
    type master;
    file "/etc/bind/reverse.dhcnhn.com";
};
```

### 2.3. Kiểm tra cú pháp cấu hình BIND9 (Trang 12)
```bash
named-checkconf /etc/bind/named.conf
named-checkzone dhcnhn.com /etc/bind/forward.dhcnhn.com
```

---

## 3. Lệnh kiểm tra phân giải tên miền từ máy trạm
```bash
nslookup www.googlehaui.com
host www.googlehaui.com
dig www.googlehaui.com
```
