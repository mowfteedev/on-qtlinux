# 04. Dịch Vụ Phân Giải Tên Miền (DNS)

Hướng dẫn cấu hình vùng phân giải xuôi, vùng phân giải ngược và các bản ghi DNS bằng công cụ `samba-tool dns` và BIND9.

---

## 1. Quản trị DNS bằng dòng lệnh `samba-tool dns`

Thực hiện trên máy chủ điều khiển miền `dc01.dhcnhn.com`:

### 1.1. Tạo vùng tra cứu xuôi và ngược
```bash
# Tạo vùng tra cứu xuôi mới (nếu cần tạo thêm domain riêng)
samba-tool dns zonecreate dc01.dhcnhn.com googlehaui.com -U administrator

# Tạo vùng tra cứu ngược cho mạng 10.0.0.0/8
samba-tool dns zonecreate dc01.dhcnhn.com 10.in-addr.arpa -U administrator
```

### 1.2. Thêm các bản ghi DNS
```bash
# Thêm bản ghi A (Phân giải tên miền ra IP)
samba-tool dns add dc01.dhcnhn.com dhcnhn.com www A 10.0.0.2 -U administrator
samba-tool dns add dc01.dhcnhn.com dhcnhn.com mail A 10.0.0.4 -U administrator

# Thêm bản ghi PTR (Phân giải ngược IP ra tên miền)
# Lưu ý: Với mạng 10.0.0.0/8, địa chỉ 10.0.0.2 đảo thành 2.0.0
samba-tool dns add dc01.dhcnhn.com 10.in-addr.arpa 2.0.0 PTR dc01.dhcnhn.com -U administrator
```

### 1.3. Cập nhật và Xóa bản ghi
```bash
# Cập nhật địa chỉ IP cho bản ghi www
samba-tool dns update dc01.dhcnhn.com dhcnhn.com www A 10.0.0.2 10.0.0.11 -U administrator

# Xóa bản ghi www
samba-tool dns delete dc01.dhcnhn.com dhcnhn.com www A 10.0.0.2 -U administrator
```

### 1.4. Liệt kê và kiểm tra bản ghi
```bash
# Xem danh sách các zone đang quản lý
samba-tool dns zonelist dc01.dhcnhn.com -U administrator

# Xem tất cả bản ghi trong zone dhcnhn.com
samba-tool dns query dc01.dhcnhn.com dhcnhn.com @ ALL -U administrator

# Xem các bản ghi trong zone ngược
samba-tool dns query dc01.dhcnhn.com 10.in-addr.arpa @ ALL -U administrator
```

---

## 2. Kiểm tra phân giải tên miền từ máy trạm (Client)
Sử dụng các công cụ tiêu chuẩn:
```bash
# Kiểm tra phân giải xuôi
nslookup www.dhcnhn.com
host www.dhcnhn.com
dig www.dhcnhn.com

# Kiểm tra phân giải ngược
nslookup 10.0.0.2
host 10.0.0.2
```
