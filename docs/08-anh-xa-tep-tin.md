# 08. Chia Sẻ Thư Mục Qua Mạng Samba Và Ánh Xạ Từ Client

Tài liệu chi tiết theo nguyên mẫu giáo trình trang 20 và 21 về chia sẻ thư mục qua giao thức SMB/CIFS và ánh xạ từ máy trạm.

---

## 1. Cấu hình chia sẻ trong `/etc/samba/smb.conf` (Trang 20)

Thêm khối cấu hình vào cuối file `/etc/samba/smb.conf`:

```ini
[share]                                        # <--- THAY ĐỔI: Tên thư mục chia sẻ hiển thị qua mạng
   comment = Thu muc chia se chung cho GV va SV
   path = /srv/share                           # <--- THAY ĐỔI: Đường dẫn thư mục cục bộ chia sẻ
   read only = no                              # <--- THAY ĐỔI: no là cho phép ghi, yes là chỉ cho đọc
   browsable = yes
   guest ok = yes                              # <--- THAY ĐỔI: yes là cho phép khách truy cập không cần pass
   create mask = 0775
   directory mask = 0775
```

### Khởi động lại dịch vụ Samba Daemon (Trang 20)
```bash
# Trên máy chủ Samba AD DC
sudo systemctl restart samba-ad-dc

# (Hoặc nếu là máy chủ Samba độc lập)
sudo systemctl restart smbd
sudo systemctl restart nmbd
```

---

## 2. Ánh xạ (Mount) trên máy trạm Linux (Trang 20)

```bash
# Tạo thư mục điểm gắn kết
sudo mkdir -p /mnt/share                       # <--- THAY ĐỔI: Đường dẫn thư mục mount trên máy trạm

# Gắn kết (Mount) thư mục mạng bằng tài khoản quản trị
sudo mount //10.0.0.2/share /mnt/share -o user=administrator,pass=Dhcnhn1   # <--- THAY ĐỔI: IP, tên share, user và pass

# Kiểm tra thư mục sau khi mount
ls -la /mnt/share
df -h | grep share

# Hủy gắn kết (Umount - Trang 20)
sudo umount //10.0.0.2/share -vA
```

---

## 3. Ánh xạ trên máy trạm Windows Client1
* **Truy cập nhanh:** Nhấn `Win + R` $\rightarrow$ gõ: `\\10.0.0.2\share` *(<--- THAY ĐỔI: IP máy chủ và tên share)*.
* **Map Network Drive:** Vào **This PC** $\rightarrow$ chọn **Map network drive** $\rightarrow$ chọn ổ `Z:` $\rightarrow$ Folder: `\\10.0.0.2\share`.
