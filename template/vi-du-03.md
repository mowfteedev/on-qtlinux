# MÃ ĐỀ: 2

Quản trị lớp học MMT và TTDL của Trường ĐHCNHN dựa trên HĐH Linux với đặc điểm và yêu cầu như sau:

### Client tham gia miền và Quản trị tài khoản người dùng/nhóm trong miền (4 điểm)
1. Cấu hình giao diện mạng cho Linux Client và đưa Client này tham gia miền của máy chủ điều khiển miền (3 điểm).
2. Tạo nhóm giảng viên (`gv`) và sinh viên (`sv`) được chứa các tài khoản trong miền (1 điểm):
   * `gv1` – `Giangvien1`; `gv2` – `Giangvien2`
   * `sv1` – `Sinhvien1`; `sv2` – `Sinhvien2`

### Dịch vụ DHCP (3 điểm)
1. Cấu hình mạng chung khi cấp tự động:
   * Gateway: `10.0.0.254`; Domain name: `dhcnhn.com`; Domain name servers: `10.0.0.2`
   * Thời gian thuê mặc định: 5 phút (`300` giây); Thời gian thuê tối đa: 1,5 ngày (`129600` giây)
2. Client được cấp địa chỉ IP tự động trong dải: `10.0.0.10/8` – `10.0.0.100/8`.
3. Cấu hình mạng dành riêng cho Client với địa chỉ MAC `11:11:11:11:11:11` với địa chỉ IP: `10.0.0.5`.

### Quản trị tập tin/thư mục (3 điểm)
1. Tạo thư mục dùng chung (`share`) tại đường dẫn `/srv/` chứa thư mục của giảng viên (`GV`) và sinh viên (`SV`) trên máy chủ điều khiển miền.
2. Tạo tập tin `gv.txt` và `sv.txt` lần lượt trong thư mục của giảng viên và sinh viên.
3. Phân quyền truy cập chính xác:
   * Đối với thư mục `/srv/share`: người sở hữu có quyền kiểm soát hoàn toàn; nhóm có quyền ghi và đọc; người dùng khác có quyền đọc và thực thi.
   * Đối với thư mục `/srv/share/gv`: người sở hữu có quyền kiểm soát hoàn toàn; nhóm có quyền đọc và thực thi; người dùng khác không có quyền.
   * Đối với thư mục `/srv/share/sv` và toàn bộ nội dung trong thư mục: người sở hữu có quyền ghi và đọc; nhóm có quyền kiểm soát hoàn toàn; người dùng khác có quyền thực thi.
   * Đối với tập tin `/srv/share/gv/gv.txt`: người sở hữu có quyền kiểm soát hoàn toàn; nhóm và người dùng khác có quyền đọc và thực thi.
   * Quyền đối với tập tin/thư mục nào không mô tả cụ thể thì để theo mặc định.

---

## 2. CÁC LỆNH THỰC THI (HƯỚNG DẪN TỪNG BƯỚC)

---

### BƯỚC 1: QUẢN TRỊ TÀI KHOẢN MIỀN TRÊN MÁY CHỦ DC01 (1 Điểm)
*Thực hiện trên máy chủ DC01 dưới quyền root:*
```bash
# 1. Tạo 4 tài khoản người dùng trong miền
sudo samba-tool user create gv1 Giangvien1
sudo samba-tool user create gv2 Giangvien2
sudo samba-tool user create sv1 Sinhvien1
sudo samba-tool user create sv2 Sinhvien2

# 2. Tạo 2 nhóm trên miền: gv và sv
sudo samba-tool group add gv
sudo samba-tool group add sv

# 3. Gán thành viên vào nhóm
sudo samba-tool group addmembers gv gv1,gv2
sudo samba-tool group addmembers sv sv1,sv2

# 4. Lệnh kiểm tra cho giáo viên chấm:
sudo samba-tool group listmembers gv
sudo samba-tool group listmembers sv
```

---

### BƯỚC 2: CẤU HÌNH MẠNG & CHO LINUX CLIENT THAM GIA MIỀN (3 Điểm)
*Thực hiện trên máy trạm Linux Client (Client2 - Ubuntu Desktop):*

```bash
# 1. Kiểm tra DNS trỏ về 10.0.0.2 và ping thông miền:
ping -c 2 dhcnhn.com

# 2. Cài đặt các gói công cụ gia nhập miền
sudo apt update
sudo apt install -y sssd sssd-tools realmd adcli

# 3. Bật PAM tự động tạo thư mục home khi đăng nhập lần đầu
echo "session optional pam_mkhomedir.so skel=/etc/skel umask=0077" | sudo tee -a /etc/pam.d/common-session

# 4. Cho phép người dùng miền đăng nhập
echo "* ; * ; * ; Al0000-2400 ; domain users" | sudo tee -a /etc/security/group.conf

# 5. Thực hiện tham gia miền (Mật khẩu: Dhcnhn1)
sudo realm -v join dhcnhn.com -U administrator

# 6. Kiểm tra lấy điểm:
realm list
id gv1@dhcnhn.com
```

---

### BƯỚC 3: CẤU HÌNH DỊCH VỤ DHCP DẢI 10-100 & GÁN CỐ ĐỊNH MAC (3 Điểm)
*Thực hiện trên máy chủ DC01:*

1. Mở file cấu hình `/etc/dhcp/dhcpd.conf`:
```bash
sudo nano /etc/dhcp/dhcpd.conf
```
2. Thêm vào cuối file cấu hình:
```text
default-lease-time 300;       # SỬA: 5 phút = 300s
max-lease-time 129600;        # SỬA: 1,5 ngày = 129600s
authoritative;

subnet 10.0.0.0 netmask 255.0.0.0 {
    option routers 10.0.0.254;
    option subnet-mask 255.0.0.0;
    option domain-name "dhcnhn.com";
    option domain-name-servers 10.0.0.2;

    range 10.0.0.10 10.0.0.100;       # SỬA: Dải IP theo đề

    host client-giang-vien {
        hardware ethernet 11:11:11:11:11:11;  # SỬA: MAC máy
        fixed-address 10.0.0.5;                # SỬA: IP cố định
    }
}
```
3. Kiểm tra cú pháp và khởi động lại dịch vụ:
```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
sudo systemctl restart isc-dhcp-server
sudo systemctl status isc-dhcp-server
```

---

### BƯỚC 4: QUẢN TRỊ TẬP TIN / THƯ MỤC MA TRẬN CHMOD (3 Điểm)
*Thực hiện trên máy chủ DC01:*

```bash
# 1. Tạo thư mục dùng chung share tại /srv/ chứa thư mục GV và SV
sudo mkdir -p /srv/share/{gv,sv}

# 2. Tạo tập tin gv.txt và sv.txt
sudo touch /srv/share/gv/gv.txt /srv/share/sv/sv.txt
echo "Tai lieu GV" | sudo tee /srv/share/gv/gv.txt
echo "Tai lieu SV" | sudo tee /srv/share/sv/sv.txt

# 3. Phân quyền chính xác theo ma trận octal:
# /srv/share: Owner rwx (7), Group rw- (6), Other r-x (5) -> 765
sudo chmod 765 /srv/share

# /srv/share/gv: Owner rwx (7), Group r-x (5), Other --- (0) -> 750
sudo chmod 750 /srv/share/gv

# /srv/share/sv và toàn bộ nội dung: Owner rw- (6), Group rwx (7), Other --x (1) -> -R 671
sudo chmod -R 671 /srv/share/sv

# /srv/share/gv/gv.txt: Owner rwx (7), Group & Other r-x (5) -> 755
sudo chmod 755 /srv/share/gv/gv.txt

# 4. Lệnh kiểm tra cho giáo viên chấm:
ls -ld /srv/share /srv/share/gv /srv/share/sv
ls -l /srv/share/gv/gv.txt
```

---

## 3. LƯU Ý KỸ THUẬT QUAN TRỌNG

1. **Quy đổi thời gian thuê DHCP:**
   * 5 phút = $5 \times 60 = \mathbf{300}$ giây.
   * 1,5 ngày = $1.5 \times 24 \times 3600 = \mathbf{129600}$ giây.
2. **Cú pháp gán IP cố định (Reservation):** Bắt buộc đặt trong cặp ngoặc nhọn của khối `subnet 10.0.0.0` với chỉ thị `hardware ethernet 11:11:11:11:11:11;` và `fixed-address 10.0.0.5;`.
3. **Mã quyền số 671:** Nhớ thêm cờ `-R` khi chạy `chmod -R 671 /srv/share/sv` vì đề ghi rõ *"và toàn bộ nội dung trong thư mục"*.
