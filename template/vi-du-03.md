# Ví Dụ 03: Tổng Hợp Samba AD DC, DNS Record, DHCP Filter Và ACL

---

## 1. ĐỀ BÀI

### Câu 1: Quản trị Active Directory bằng `samba-tool` (3.0 điểm)
1. Tạo 2 tài khoản sinh viên: `sv1` (Pass: `Sinhvien1`), `sv2` (Pass: `Sinhvien2`).
2. Tạo 2 tài khoản giảng viên: `gv1` (Pass: `Giangvien1`), `gv2` (Pass: `Giangvien2`).
3. Tạo nhóm `Giangvien` chứa `gv1, gv2` và nhóm `Sinhvien` chứa `sv1, sv2`.
4. Liệt kê các thành viên trong từng nhóm để nghiệm thu.

### Câu 2: Quản trị dịch vụ DNS bằng `samba-tool dns` (3.0 điểm)
Thực hiện cấu hình DNS trên máy chủ điều khiển miền `dc01.dhcnhn.com`:
1. Tạo vùng tra cứu ngược: `10.in-addr.arpa`.
2. Tạo bản ghi **A**: `www` trỏ về IP `10.0.0.3`, `mail` trỏ về IP `10.0.0.4`.
3. Tạo bản ghi phân giải ngược **PTR** cho địa chỉ `10.0.0.2` trỏ về `dc01.dhcnhn.com`.
4. Dùng lệnh `samba-tool dns query` để kiểm tra các bản ghi vừa tạo.

### Câu 3: DHCP Server có Bộ lọc và Phân quyền Nâng cao ACL (4.0 điểm)
1. Cấu hình DHCP cấp động dải `10.0.0.10` – `10.0.0.50`. Cấu hình từ chối cấp IP tự động (`deny booting;`) cho máy có MAC `22:22:22:22:22:22`.
2. Tạo thư mục `/srv/share` và gán quyền cơ bản `chmod 775 /srv/share`.
3. Sử dụng công cụ POSIX ACL (`setfacl`):
   * Cấp toàn quyền (`rwx`) cho nhóm `Giangvien` trên `/srv/share`.
   * Cấp quyền chỉ đọc và thực thi (`r-x`) cho nhóm `Sinhvien` trên `/srv/share`.
4. Kiểm tra cấu hình ACL bằng lệnh `getfacl`.

---

## 2. CÁC LỆNH THỰC THI

### Giải Câu 1: Quản trị AD CLI
```bash
# 1. Tạo User
sudo samba-tool user create sv1 Sinhvien1
sudo samba-tool user create sv2 Sinhvien2
sudo samba-tool user create gv1 Giangvien1
sudo samba-tool user create gv2 Giangvien2

# 2. Tạo Group & gán thành viên
sudo samba-tool group add Giangvien
sudo samba-tool group add Sinhvien
sudo samba-tool group addmembers Giangvien gv1,gv2
sudo samba-tool group addmembers Sinhvien sv1,sv2

# 3. Nghiệm thu
sudo samba-tool group listmembers Giangvien
sudo samba-tool group listmembers Sinhvien
```

### Giải Câu 2: Quản trị DNS qua `samba-tool dns`
```bash
# 1. Tạo vùng tra cứu ngược (Reverse Zone)
sudo samba-tool dns zonecreate dc01.dhcnhn.com 10.in-addr.arpa -U administrator

# 2. Thêm các bản ghi A
sudo samba-tool dns add dc01.dhcnhn.com dhcnhn.com www A 10.0.0.3 -U administrator
sudo samba-tool dns add dc01.dhcnhn.com dhcnhn.com mail A 10.0.0.4 -U administrator

# 3. Thêm bản ghi phân giải ngược PTR cho 10.0.0.2
sudo samba-tool dns add dc01.dhcnhn.com 10.in-addr.arpa 2.0.0 PTR dc01.dhcnhn.com -U administrator

# 4. Truy vấn nghiệm thu
sudo samba-tool dns query dc01.dhcnhn.com dhcnhn.com @ ALL -U administrator
sudo samba-tool dns query dc01.dhcnhn.com 10.in-addr.arpa @ ALL -U administrator
```

### Giải Câu 3: DHCP Filter & POSIX ACL
```bash
# 1. Cấu hình DHCP có bộ lọc deny booting
sudo tee -a /etc/dhcp/dhcpd.conf << 'EOF'

subnet 10.0.0.0 netmask 255.0.0.0 {
    option routers 10.0.0.254;
    option domain-name "dhcnhn.com";
    option domain-name-servers 10.0.0.2;
    range 10.0.0.10 10.0.0.50;

    host may-bi-chan {
        hardware ethernet 22:22:22:22:22:22;
        deny booting;
    }
}
EOF

sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf && sudo systemctl restart isc-dhcp-server

# 2. Tạo thư mục & cấp quyền cơ bản
sudo mkdir -p /srv/share
sudo chmod 775 /srv/share

# 3. Gán quyền ACL nâng cao
sudo setfacl -m g:Giangvien:rwx /srv/share
sudo setfacl -m g:Sinhvien:r-x /srv/share

# 4. Kiểm tra kết quả
getfacl /srv/share
```

---

## 3. LƯU Ý KỸ THUẬT

1. **Cú pháp bản ghi PTR:** Đối với mạng lớp A `10.0.0.0/8`, zone ngược là `10.in-addr.arpa`. Bản ghi PTR cho IP `10.0.0.2` sẽ có octet ngược là `2.0.0`.
2. **Xác thực quyền quản trị:** Khi chạy `samba-tool dns`, luôn thêm cờ `-U administrator` để xác thực quyền quản trị miền (mật khẩu: `Dhcnhn1`).
3. **Ký hiệu ACL:** Thư mục có áp dụng ACL sẽ xuất hiện dấu cộng (`+`) ở cuối chuỗi quyền khi kiểm tra bằng `ls -ld` (ví dụ: `drwxrwxr-x+`).
