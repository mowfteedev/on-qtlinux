# 07. Quyền Sở Hữu Và Quyền Truy Cập Tập Tin, Thư Mục

Tài liệu chi tiết theo nguyên mẫu giáo trình trang 18-20 về phân quyền bằng chữ cái, phân quyền bằng số octal, thay đổi chủ sở hữu và POSIX ACL.

---

## 1. Cú pháp chmod bằng chữ cái (Trang 19)
* **Đối tượng:** `u` (owner), `g` (group), `o` (other), `a` (all).
* **Quyền:** `r` (read), `w` (write), `x` (execute).
* **Toán tử:** `+` (thêm quyền), `-` (xóa quyền), `=` (gán cố định quyền).

```bash
chmod u+x file1             # Thêm quyền thực thi cho chủ sở hữu
chmod o+wx file2            # Thêm quyền ghi và thực thi cho người dùng khác
chmod g-r file3             # Xóa quyền đọc của nhóm
chmod ugo+rwx file4         # Gán quyền đọc, ghi, thực thi cho tất cả mọi người
```

---

## 2. Ma trận phân quyền bằng số Octal tại `/srv/share` (Trang 20)

| Đường dẫn đối tượng | Quyền Owner | Quyền Group | Quyền Others | Ký hiệu symbolic | Mã số Octal |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/srv/share` | Toàn quyền (`rwx`) | Đọc & Ghi (`rw-`) | Đọc & Thực thi (`r-x`) | `rwx rw- r-x` | **`765`** |
| `/srv/share/gv` | Toàn quyền (`rwx`) | Đọc & Thực thi (`r-x`) | Không có quyền (`---`) | `rwx r-x ---` | **`750`** |
| `/srv/share/sv` *(đệ quy cả con)* | Ghi & Đọc (`rw-`) | Toàn quyền (`rwx`) | Thực thi (`--x`) | `rw- rwx --x` | **`671`** |
| `/srv/share/gv/gv.txt` | Toàn quyền (`rwx`) | Đọc & Thực thi (`r-x`) | Đọc & Thực thi (`r-x`) | `rwx r-x r-x` | **`755`** |

### Lệnh thực thi:
```bash
# Tạo thư mục và file
sudo mkdir -p /srv/share/{gv,sv}
sudo touch /srv/share/gv/gv.txt /srv/share/sv/sv.txt

# Áp dụng quyền
sudo chmod 765 /srv/share                      # <--- THAY ĐỔI: Mã số octal tính từ ma trận quyền của đề
sudo chmod 750 /srv/share/gv                   # <--- THAY ĐỔI: Mã số octal tính từ ma trận quyền của đề
sudo chmod -R 671 /srv/share/sv                # <--- THAY ĐỔI: Cờ -R bắt buộc khi đề yêu cầu áp dụng cả thư mục con
sudo chmod 755 /srv/share/gv/gv.txt            # <--- THAY ĐỔI: Mã số octal tính từ ma trận quyền của đề
```

---

## 3. Thay đổi người sở hữu và nhóm (`chown` / `chgrp` - Trang 19)

```bash
# Đổi chủ sở hữu và nhóm người dùng cục bộ
sudo chown gv1 /srv/share/gv                   # <--- THAY ĐỔI: Đổi user sở hữu
sudo chgrp Giangvien /srv/share/gv             # <--- THAY ĐỔI: Đổi group sở hữu
sudo chown -R gv1:Giangvien /srv/share/gv      # <--- THAY ĐỔI: Đổi cả user và group đệ quy
sudo chown -R sv1:Sinhvien /srv/share/sv

# Đổi chủ sở hữu cho tài khoản Active Directory (Trang 19)
sudo chown administrator:"domain users" /srv/share
sudo chown dhcnhn\\administrator:"dhcnhn\domain users" /srv/share
```

---

## 4. Quản lý phân quyền nâng cao bằng POSIX ACL (Trang 19)

```bash
# Xem quyền ACL của thư mục
getfacl /srv/share

# Gán quyền rwx cho nhóm Sinhvien vào thư mục /srv/share
sudo setfacl -m g:Sinhvien:rwx /srv/share      # <--- THAY ĐỔI: Tên nhóm và quyền cần cấp

# Xóa quyền ACL của nhóm Sinhvien khỏi thư mục
sudo setfacl -x g:Sinhvien /srv/share          # <--- THAY ĐỔI: Tên nhóm cần thu hồi quyền
```

---

## 5. Lệnh kiểm tra kết quả
```bash
ls -ld /srv/share /srv/share/gv /srv/share/sv
ls -l /srv/share/gv/gv.txt /srv/share/sv/sv.txt
```
