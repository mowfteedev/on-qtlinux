# 08. Chia Sẻ Thư Mục Qua Mạng Samba Và Ánh Xạ Từ Client

Hướng dẫn cấu hình dịch vụ Samba Share trên máy chủ DC01 và ánh xạ ổ đĩa mạng từ máy trạm Windows Client1 và Linux Client2.

---

## 1. Cấu hình Samba Share trên máy chủ DC01

Mở file cấu hình `/etc/samba/smb.conf`:
```bash
sudo nano /etc/samba/smb.conf
```

Thêm khối chia sẻ vào cuối file:

```ini
[share]
   comment = Thu muc chia se chung cho GV va SV
   path = /srv/share
   read only = no
   browsable = yes
   guest ok = yes
   create mask = 0775
   directory mask = 0775
```

Khởi động lại dịch vụ Samba AD DC:
```bash
sudo systemctl restart samba-ad-dc
```

---

## 2. Ánh xạ thư mục mạng từ máy trạm Windows Client1

### Cách 1: Truy cập trực tiếp qua đường dẫn UNC
1. Nhấn tổ hợp phím `Win + R`.
2. Nhập đường dẫn: `\\10.0.0.2\share` và nhấn Enter.
3. Nếu yêu cầu xác thực, nhập tài khoản domain:
   * User: `dhcnhn\gv1` (hoặc `dhcnhn\administrator`)
   * Password: `Giangvien1` (hoặc `Dhcnhn1`)

### Cách 2: Gắn ổ đĩa mạng cố định (Map Network Drive)
1. Mở **File Explorer** $\rightarrow$ chọn **This PC**.
2. Trên thanh công cụ, chọn **Map network drive**.
3. Chọn tên ổ đĩa (ví dụ: `Z:`).
4. Tại ô **Folder**, điền: `\\10.0.0.2\share`.
5. Tích chọn **Connect using different credentials** (nếu cần đổi user) $\rightarrow$ bấm **Finish**.

---

## 3. Ánh xạ (Mount) thư mục mạng từ máy trạm Linux Client2

### Bước 1: Tạo thư mục điểm gắn kết (Mount point)
```bash
sudo mkdir -p /mnt/share
```

### Bước 2: Thực hiện lệnh mount CIFS
```bash
# Mount với quyền administrator
sudo mount -t cifs //10.0.0.2/share /mnt/share -o user=administrator,pass=Dhcnhn1

# Hoặc mount với tài khoản giảng viên gv1
sudo mount -t cifs //10.0.0.2/share /mnt/share -o user=gv1,pass=Giangvien1,domain=dhcnhn.com
```

### Bước 3: Kiểm tra nội dung sau khi mount
```bash
ls -la /mnt/share
df -h | grep share
```

### Bước 4: Hủy gắn kết (Umount) khi không sử dụng
```bash
sudo umount /mnt/share
```
