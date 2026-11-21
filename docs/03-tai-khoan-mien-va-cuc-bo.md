# 03. Quản Trị Tài Khoản Trong Miền Và Tài Khoản Cục Bộ

Tài liệu chi tiết theo nguyên mẫu giáo trình trang 5, 10 và 12 về quản trị người dùng, nhóm cục bộ và Active Directory.

---

## 1. Quản trị tài khoản cục bộ trên Linux OS (Trang 5)

```bash
# Cài đặt gói members
sudo apt install members

# Quản trị mật khẩu tài khoản root
sudo passwd root              # Đổi mật khẩu root
sudo passwd -l root           # Khóa tài khoản root
sudo passwd -u root           # Mở khóa tài khoản root

# Tạo tài khoản và nhóm cục bộ
sudo adduser gv1              # <--- THAY ĐỔI: Tên tài khoản theo đề bài
sudo adduser gv2
sudo adduser sv1
sudo adduser sv2
sudo adduser sv3

sudo addgroup Giangvien       # <--- THAY ĐỔI: Tên nhóm theo đề bài
sudo addgroup Giangvien2
sudo addgroup Sinhvien

# Gán người dùng vào nhóm
sudo adduser gv1 Giangvien    # <--- THAY ĐỔI: Gán user vào group tương ứng
sudo adduser gv2 Giangvien
sudo adduser gv2 Giangvien2
sudo adduser sv1 Sinhvien
sudo adduser sv2 Sinhvien

# Xoá tài khoản và nhóm cục bộ
sudo deluser sv3              # <--- THAY ĐỔI: Tên user cần xóa
sudo delgroup Giangvien2      # <--- THAY ĐỔI: Tên group cần xóa

# Kiểm tra thành viên nhóm
members Giangvien             # Xem danh sách user trong nhóm Giangvien
members Sinhvien
getent passwd                 # Xem toàn bộ tài khoản hệ thống
```

---

## 2. Quản trị tài khoản miền bằng `samba-tool` trên DC01 (Trang 10 & 13)

### 2.1. Tạo User và Group
```bash
# Tạo user miền
sudo samba-tool user create sv1 Sinhvien1        # <--- THAY ĐỔI: Tên user và mật khẩu
sudo samba-tool user create sv2 Sinhvien2
sudo samba-tool user create sv3 Sinhvien3
sudo samba-tool user create gv1 Giangvien1
sudo samba-tool user create gv2 Giangvien2

# Tạo group miền
sudo samba-tool group add Giangvien              # <--- THAY ĐỔI: Tên nhóm theo đề bài
sudo samba-tool group add Giangvien2
sudo samba-tool group add Sinhvien

# Gán thành viên vào group
sudo samba-tool group addmembers Giangvien gv1,gv2
sudo samba-tool group addmembers Giangvien2 gv2
sudo samba-tool group addmembers Sinhvien sv1,sv2

# Xoá tài khoản và nhóm
sudo samba-tool user delete sv3                  # <--- THAY ĐỔI: User cần xóa
sudo samba-tool group delete Giangvien2          # <--- THAY ĐỔI: Group cần xóa
```

### 2.2. Thiết lập thuộc tính tài khoản theo yêu cầu Bài 2 (Trang 12)
```bash
# Mật khẩu không bao giờ hết hạn (Password never expires)
sudo samba-tool user setexpiry sv2 --noexpiry

# Yêu cầu đổi mật khẩu sau lần đăng nhập đầu tiên
sudo samba-tool user setpassword sv1 --must-change-at-next-login

# Vô hiệu hóa (khóa) và Mở khóa tài khoản
sudo samba-tool user disable sv4                 # Khóa tài khoản
sudo samba-tool user enable sv4                  # Mở khóa tài khoản
```

### 2.3. Lệnh kiểm tra và nghiệm thu
```bash
sudo samba-tool user list                        # Liệt kê tất cả user
sudo samba-tool group list                       # Liệt kê tất cả group
sudo samba-tool group listmembers Giangvien      # Liệt kê thành viên nhóm Giangvien
sudo samba-tool group listmembers Sinhvien       # Liệt kê thành viên nhóm Sinhvien
wbinfo -u; wbinfo -g                             # Kiểm tra qua winbind daemon
```
