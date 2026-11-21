# 07. Quyền Sở Hữu Và Quyền Truy Cập Tập Tin, Thư Mục

Hướng dẫn thiết lập quyền truy cập tiêu chuẩn Linux (`chmod`), quyền sở hữu (`chown`) và quyền nâng cao POSIX ACL (`setfacl`).

---

## 1. Nguyên lý phân quyền Linux Standard
* **Chủ sở hữu (Owner / User):** `u`
* **Nhóm sở hữu (Group):** `g`
* **Người dùng khác (Others):** `o`
* **Giá trị số (Octal):** `r` (read) = 4, `w` (write) = 2, `x` (execute) = 1.

---

## 2. Ma trận phân quyền chi tiết tại `/srv/share`

Theo yêu cầu chuẩn bài thực hành:

| Đường dẫn đối tượng | Quyền Owner | Quyền Group | Quyền Others | Ký hiệu symbolic | Mã số Octal |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/srv/share` | Toàn quyền (`rwx`) | Đọc & Ghi (`rw-`) | Đọc & Thực thi (`r-x`) | `rwx rw- r-x` | **`765`** |
| `/srv/share/gv` | Toàn quyền (`rwx`) | Đọc & Thực thi (`r-x`) | Không có quyền (`---`) | `rwx r-x ---` | **`750`** |
| `/srv/share/sv` *(đệ quy cả con)* | Ghi & Đọc (`rw-`) | Toàn quyền (`rwx`) | Thực thi (`--x`) | `rw- rwx --x` | **`671`** |
| `/srv/share/gv/gv.txt` | Toàn quyền (`rwx`) | Đọc & Thực thi (`r-x`) | Đọc & Thực thi (`r-x`) | `rwx r-x r-x` | **`755`** |

### Lệnh thực thi:
```bash
# 1. Tạo cây thư mục và tập tin
sudo mkdir -p /srv/share/{gv,sv}
sudo touch /srv/share/gv/gv.txt /srv/share/sv/sv.txt

# 2. Áp dụng quyền
sudo chmod 765 /srv/share
sudo chmod 750 /srv/share/gv
sudo chmod -R 671 /srv/share/sv        # Cờ -R áp dụng đệ quy cho cả thư mục con
sudo chmod 755 /srv/share/gv/gv.txt
```

---

## 3. Gán quyền sở hữu người dùng và nhóm (`chown`)
```bash
# Gán gv1 và nhóm Giangvien sở hữu thư mục gv
sudo chown -R gv1:Giangvien /srv/share/gv

# Gán sv1 và nhóm Sinhvien sở hữu thư mục sv
sudo chown -R sv1:Sinhvien /srv/share/sv
```

---

## 4. Phân quyền nâng cao bằng POSIX ACL (`setfacl` / `getfacl`)
Sử dụng khi cần cấp quyền cho nhiều nhóm khác nhau trên cùng một thư mục:

```bash
# Xem quyền ACL hiện tại
getfacl /srv/share

# Cấp quyền đọc, ghi, thực thi cho nhóm Sinhvien
sudo setfacl -m g:Sinhvien:rwx /srv/share

# Xóa quyền ACL của nhóm Sinhvien
sudo setfacl -x g:Sinhvien /srv/share
```

---

## 5. Lệnh kiểm tra kết quả
```bash
ls -ld /srv/share /srv/share/gv /srv/share/sv
ls -l /srv/share/gv/gv.txt /srv/share/sv/sv.txt
```
