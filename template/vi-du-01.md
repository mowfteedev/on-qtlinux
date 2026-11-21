# Ví Dụ 01: Mạng Netplan, Tài Khoản Samba AD Và Phân Quyền Tập Tin

---

## 1. ĐỀ BÀI

### Câu 1: Cấu hình mạng máy chủ (2.5 điểm)
Trên máy chủ **DC01**, sử dụng **Netplan** thiết lập thông số mạng tĩnh:
* IP Address: `10.0.0.2/8`
* Default Gateway: `10.0.0.254`
* DNS Server: `10.0.0.2, 8.8.8.8`
* Domain search: `dhcnhn.com`
* Yêu cầu: DC01 ping thông Gateway `10.0.0.254` và ping thông Internet `8.8.8.8`.

### Câu 2: Quản trị Active Directory bằng CLI (3.5 điểm)
Sử dụng công cụ **`samba-tool`** trên DC01 thực hiện các yêu cầu:
1. Tạo 3 tài khoản sinh viên: `sv1` (Pass: `Sinhvien1`), `sv2` (Pass: `Sinhvien2`), `sv3` (Pass: `Sinhvien3`).
2. Tạo 2 tài khoản giảng viên: `gv1` (Pass: `Giangvien1`), `gv2` (Pass: `Giangvien2`).
3. Tạo các nhóm: `Giangvien`, `Giangvien2`, `Sinhvien`.
4. Gán thành viên: Nhóm `Giangvien` gồm `gv1, gv2`; Nhóm `Giangvien2` gồm `gv2`; Nhóm `Sinhvien` gồm `sv1, sv2`.
5. Thực hiện xóa tài khoản `sv3` và xóa nhóm `Giangvien2`.

### Câu 3: Quản trị tập tin & Chia sẻ mạng Samba (4.0 điểm)
1. Tạo cây thư mục `/srv/share/{gv,sv}` và tạo tập tin `gv.txt`, `sv.txt` lần lượt trong hai thư mục trên.
2. Phân quyền truy cập chính xác:
   * `/srv/share`: Người sở hữu toàn quyền; Nhóm có quyền đọc và ghi; Người dùng khác có quyền đọc và thực thi.
   * `/srv/share/gv`: Người sở hữu toàn quyền; Nhóm có quyền đọc và thực thi; Người dùng khác không có quyền.
   * `/srv/share/sv` (và toàn bộ nội dung bên trong): Người sở hữu có quyền ghi và đọc; Nhóm toàn quyền; Người dùng khác có quyền thực thi.
   * `/srv/share/gv/gv.txt`: Người sở hữu toàn quyền; Nhóm và Người dùng khác có quyền đọc và thực thi.
3. Cấu hình chia sẻ thư mục `/srv/share` qua mạng Samba (tên share: `share`, cho phép khách đọc/ghi). Khởi động lại dịch vụ Samba.

---

## 2. CÁC LỆNH THỰC THI

### Giải Câu 1: Cấu hình Netplan
```bash
sudo tee /etc/netplan/01-netcfg.yaml << 'EOF'
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: false
      addresses:
        - 10.0.0.2/8
      routes:
        - to: default
          via: 10.0.0.254
      nameservers:
        addresses: [10.0.0.2, 8.8.8.8]
        search: [dhcnhn.com]
EOF

sudo netplan apply
ip a show ens33
ping -c 2 10.0.0.254
ping -c 2 8.8.8.8
```

### Giải Câu 2: Quản trị Samba AD bằng `samba-tool`
```bash
# Tạo User
sudo samba-tool user create sv1 Sinhvien1
sudo samba-tool user create sv2 Sinhvien2
sudo samba-tool user create sv3 Sinhvien3
sudo samba-tool user create gv1 Giangvien1
sudo samba-tool user create gv2 Giangvien2

# Tạo Group
sudo samba-tool group add Giangvien
sudo samba-tool group add Giangvien2
sudo samba-tool group add Sinhvien

# Thêm thành viên
sudo samba-tool group addmembers Giangvien gv1,gv2
sudo samba-tool group addmembers Giangvien2 gv2
sudo samba-tool group addmembers Sinhvien sv1,sv2

# Xóa User sv3 và Group Giangvien2
sudo samba-tool user delete sv3
sudo samba-tool group delete Giangvien2

# Kiểm tra kết quả
sudo samba-tool user list
sudo samba-tool group listmembers Giangvien
sudo samba-tool group listmembers Sinhvien
```

### Giải Câu 3: Phân quyền & Samba Share
```bash
# Khởi tạo thư mục và file
sudo mkdir -p /srv/share/{gv,sv}
sudo touch /srv/share/gv/gv.txt /srv/share/sv/sv.txt

# Thiết lập quyền
sudo chmod 765 /srv/share
sudo chmod 750 /srv/share/gv
sudo chmod -R 671 /srv/share/sv
sudo chmod 755 /srv/share/gv/gv.txt

# Khai báo chia sẻ Samba
sudo tee -a /etc/samba/smb.conf << 'EOF'

[share]
   comment = Thu muc chia se chung cho GV va SV
   path = /srv/share
   read only = no
   browsable = yes
   guest ok = yes
   create mask = 0775
   directory mask = 0775
EOF

# Khởi động lại dịch vụ Samba
sudo systemctl restart samba-ad-dc

# Kiểm tra quyền
ls -ld /srv/share /srv/share/gv /srv/share/sv
ls -l /srv/share/gv/gv.txt
```

---

## 3. LƯU Ý KỸ THUẬT

1. **Tên card mạng:** Kiểm tra bằng lệnh `ip link`. Nếu tên card mạng là `ens32` hoặc `eth0`, cần thay thế tương ứng trong file netplan.
2. **Quyền đệ quy:** Thư mục `/srv/share/sv` yêu cầu áp dụng cho cả nội dung bên trong nên bắt buộc sử dụng cờ `-R` (`chmod -R 671 /srv/share/sv`).
3. **Dịch vụ Samba AD:** Tên dịch vụ trên Ubuntu Server Samba AD DC là `samba-ad-dc`.
