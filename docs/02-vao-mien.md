# 02. Cấu Hình Máy Trạm Tham Gia Vào Miền (Join Domain)

Hướng dẫn cấu hình máy trạm Windows Client1 và Linux Client2 gia nhập miền `dhcnhn.com`.

---

## 1. Điều kiện tiên quyết
* Cả hai máy trạm phải ping thông tới máy chủ DC01 (`10.0.0.2`).
* Máy trạm bắt buộc phải trỏ DNS Server chính về địa chỉ IP của DC01: `10.0.0.2`.
* Kiểm tra phân giải tên miền:
  ```bash
  ping dhcnhn.com
  ```
  Kết quả phải trả về phản hồi từ IP `10.0.0.2`.

---

## 2. Máy trạm Windows Client1 tham gia miền
1. Nhấn tổ hợp phím `Win + R`, nhập `sysdm.cpl` và nhấn Enter.
2. Tại tab **Computer Name**, chọn nút **Change...**
3. Tại mục **Member of**, tích chọn **Domain**, nhập: `dhcnhn.com`.
4. Nhập thông tin tài khoản quản trị miền:
   * Username: `administrator` (hoặc `dhcnhn\administrator`)
   * Password: `Dhcnhn1`
5. Nhận thông báo chào mừng vào miền, bấm **OK** và khởi động lại máy tính.
6. Đăng nhập vào máy tính bằng tài khoản domain (ví dụ: `dhcnhn\gv1`).

---

## 3. Máy trạm Linux Client2 (Ubuntu Desktop) tham gia miền

### Bước 1: Cài đặt các gói công cụ cần thiết
```bash
sudo apt update
sudo apt install -y sssd sssd-tools realmd adcli
```

### Bước 2: Bật PAM tự động tạo thư mục home khi đăng nhập lần đầu
Mở file `/etc/pam.d/common-session` và thêm dòng sau vào cuối file:
```text
session optional pam_mkhomedir.so skel=/etc/skel umask=0077
```
*(Có thể chạy lệnh nhanh: `echo "session optional pam_mkhomedir.so skel=/etc/skel umask=0077" | sudo tee -a /etc/pam.d/common-session`)*

### Bước 3: Cho phép người dùng miền đăng nhập
Mở file `/etc/security/group.conf` và thêm dòng:
```text
* ; * ; * ; Al0000-2400 ; domain users
```

### Bước 4: Thực hiện lệnh gia nhập miền
```bash
# Quét thông tin miền
sudo realm discover dhcnhn.com

# Tham gia miền với quyền administrator (mật khẩu: Dhcnhn1)
sudo realm -v join dhcnhn.com -U administrator
```

### Bước 5: Kiểm tra kết quả
```bash
# Xem thông tin miền đã gia nhập
realm list

# Kiểm tra nhận diện tài khoản từ miền
id gv1@dhcnhn.com

# Đăng nhập thử sang tài khoản miền
su - gv1@dhcnhn.com
```
