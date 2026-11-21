# 03. Quản Trị Tài Khoản Trong Miền Và Tài Khoản Cục Bộ

Hướng dẫn tạo, phân nhóm và quản lý tài khoản người dùng trên miền (Samba Active Directory) và cục bộ (Linux OS).

---

## 1. Quản trị tài khoản cục bộ trên Linux OS

Sử dụng khi quản trị người dùng chỉ đăng nhập nội bộ trên một máy đơn lẻ:

```bash
# Cài đặt gói hỗ trợ kiểm tra thành viên nhóm
sudo apt install members

# Tạo tài khoản người dùng cục bộ
sudo adduser gv1
sudo adduser gv2
sudo adduser sv1
sudo adduser sv2
sudo adduser sv3

# Tạo nhóm người dùng cục bộ
sudo addgroup Giangvien
sudo addgroup Giangvien2
sudo addgroup Sinhvien

# Gán người dùng vào nhóm
sudo adduser gv1 Giangvien
sudo adduser gv2 Giangvien
sudo adduser gv2 Giangvien2
sudo adduser sv1 Sinhvien
sudo adduser sv2 Sinhvien

# Xoá tài khoản và nhóm cục bộ theo yêu cầu
sudo deluser sv3
sudo delgroup Giangvien2

# Kiểm tra danh sách người dùng và nhóm
cat /etc/passwd | grep -E "gv|sv"
members Giangvien
members Sinhvien
```

---

## 2. Quản trị tài khoản miền bằng `samba-tool` trên DC01

Thao tác quản trị người dùng tập trung cho toàn bộ hệ thống miền:

### 2.1. Tạo tài khoản trong miền
Mật khẩu phải đáp ứng độ phức tạp Active Directory:
```bash
sudo samba-tool user create sv1 Sinhvien1
sudo samba-tool user create sv2 Sinhvien2
sudo samba-tool user create sv3 Sinhvien3
sudo samba-tool user create gv1 Giangvien1
sudo samba-tool user create gv2 Giangvien2
```

### 2.2. Tạo nhóm và gán thành viên
```bash
# Tạo các nhóm
sudo samba-tool group add Giangvien
sudo samba-tool group add Giangvien2
sudo samba-tool group add Sinhvien

# Thêm thành viên vào nhóm
sudo samba-tool group addmembers Giangvien gv1,gv2
sudo samba-tool group addmembers Giangvien2 gv2
sudo samba-tool group addmembers Sinhvien sv1,sv2
```

### 2.3. Xoá tài khoản và nhóm
```bash
sudo samba-tool user delete sv3
sudo samba-tool group delete Giangvien2
```

### 2.4. Kiểm tra danh sách và thành viên
```bash
# Liệt kê tất cả user và group trong miền
sudo samba-tool user list
sudo samba-tool group list

# Liệt kê thành viên của nhóm cụ thể
sudo samba-tool group listmembers Giangvien
sudo samba-tool group listmembers Sinhvien

# Kiểm tra qua dịch vụ Winbind
wbinfo -u
wbinfo -g
```
