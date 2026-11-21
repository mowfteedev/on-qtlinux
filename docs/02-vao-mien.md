# 02. Cấu Hình Máy Trạm Tham Gia Vào Miền (Join Domain)

Hướng dẫn cấu hình máy trạm Windows Client1 và Linux Client2 gia nhập miền `dhcnhn.com`.

---

## 1. Kiểm tra kết nối trước khi vào miền
* Cả hai máy trạm bắt buộc phải trỏ DNS chính về IP của máy chủ DC01: `10.0.0.2`.
* Kiểm tra phân giải tên miền:
  ```bash
  ping dhcnhn.com             # <--- THAY ĐỔI: Tên miền theo yêu cầu đề bài
  ```
  Kết quả phải trả về phản hồi từ IP `10.0.0.2` (DC01).

---

## 2. Máy trạm Windows Client1 tham gia miền
1. Nhấn `Win + R`, nhập `sysdm.cpl` và nhấn Enter.
2. Tại tab **Computer Name**, chọn nút **Change...**
3. Tại mục **Member of**, tích chọn **Domain**, nhập: `dhcnhn.com` *(<--- THAY ĐỔI: Tên miền theo đề)*.
4. Nhập thông tin tài khoản quản trị miền:
   * Username: `administrator` (hoặc `dhcnhn\administrator`)
   * Password: `Dhcnhn1` *(<--- THAY ĐỔI: Mật khẩu quản trị DC)*
5. Khởi động lại máy tính $\rightarrow$ Đăng nhập bằng tài khoản miền: `dhcnhn\gv1`.

---

## 3. Máy trạm Linux Client2 (Ubuntu Desktop) tham gia miền (Trang 9)

```bash
# 1. Cài đặt các gói phần mềm
sudo apt update
sudo apt install -y sssd sssd-tools realmd adcli

# 2. Bật PAM tự động tạo thư mục home khi người dùng miền đăng nhập lần đầu
echo "session optional pam_mkhomedir.so skel=/etc/skel umask=0077" | sudo tee -a /etc/pam.d/common-session

# 3. Cho phép người dùng miền đăng nhập trong /etc/security/group.conf
echo "* ; * ; * ; Al0000-2400 ; domain users" | sudo tee -a /etc/security/group.conf

# 4. Quét và tham gia miền
sudo realm discover dhcnhn.com                          # <--- THAY ĐỔI: Tên miền cần quét
sudo realm -v join dhcnhn.com -U administrator          # <--- THAY ĐỔI: Tên miền và user quản trị

# 5. Kiểm tra kết quả
realm list
id gv1@dhcnhn.com                                       # <--- THAY ĐỔI: Tên user kiểm tra
su - gv1@dhcnhn.com
```
