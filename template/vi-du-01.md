# ĐỀ THI SỐ 01 (MÃ ĐỀ: 4) - ĐỀ KIỂM TRA THƯỜNG XUYÊN 2

> **Học phần:** Quản trị hệ thống trên nền tảng Linux (FE6092) - HaUI  
> **Hình thức:** Thực hành trên máy ảo (10 điểm)

---

## 1. ĐỀ BÀI CHI TIẾT

Quản trị lớp học MMT và TTDL của Trường ĐHCNHN dựa trên HĐH Linux với đặc điểm và yêu cầu như sau:

### Phần 1: Client tham gia miền và Quản trị tài khoản người dùng/nhóm trong miền (4 điểm)
1. Cấu hình giao diện mạng cho Linux Client và đưa Client này tham gia miền của máy chủ điều khiển miền (3 điểm).
2. Tạo nhóm giảng viên (`gv`) và sinh viên (`sv`) được chứa các tài khoản trong miền (1 điểm):
   * `gv1` – `Giangvien1`; `gv2` – `Giangvien2`
   * `sv1` – `Sinhvien1`; `sv2` – `Sinhvien2`

### Phần 2: Dịch vụ DHCP (3 điểm)
1. Cấu hình mạng chung khi cấp tự động:
   * Gateway: `10.0.0.254`; Domain name: `dhcnhn.com`; Domain name servers: `10.0.0.2`
   * Thời gian thuê mặc định: 15 phút (`900` giây); Thời gian thuê tối đa: 1,1 ngày (`95040` giây)
2. Client được cấp địa chỉ IP tự động trong dải: `10.0.0.100/8` – `10.0.0.200/8`.
3. Từ chối cấp tự động cấu hình mạng cho Client với địa chỉ MAC `22:22:22:22:22:22`.

### Phần 3: Quản trị tập tin/thư mục (3 điểm)
1. Mỗi nhóm giảng viên và nhóm sinh viên được cấp các tài khoản lưu trữ cục bộ:
   * `gv1` – `Giangvien1`; `gv2` – `Giangvien2`; `sv1` – `Sinhvien1`; `sv2` – `Sinhvien2`
2. Tạo thư mục dùng chung (`share`) tại đường dẫn `/srv/` chứa thư mục của giảng viên (`GV`) và sinh viên (`SV`) trên máy chủ điều khiển miền.
3. Tạo tập tin `gv.txt` và `sv.txt` lần lượt trong thư mục của giảng viên và sinh viên.
4. Giảng viên 1 và sinh viên 1 lần lượt sở hữu thư mục của giảng viên và sinh viên; Nhóm giảng viên và sinh viên lần lượt có quyền đối với thư mục của GV và SV.

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

# 2. Tạo 2 nhóm trên miền: gv và sv (theo đúng tên trong đề)
sudo samba-tool group add gv
sudo samba-tool group add sv

# 3. Gán người dùng vào nhóm tương ứng
sudo samba-tool group addmembers gv gv1,gv2
sudo samba-tool group addmembers sv sv1,sv2

# 4. Lệnh kiểm tra cho giáo viên chấm
sudo samba-tool group listmembers gv
sudo samba-tool group listmembers sv
```

---

### BƯỚC 2: CẤU HÌNH MẠNG & CHO LINUX CLIENT THAM GIA MIỀN (3 Điểm)
*Thực hiện trên máy trạm Linux Client (Client2 - Ubuntu Desktop):*

```bash
# 1. Cấu hình mạng Linux Client: đảm bảo DNS trỏ về 10.0.0.2 (DC01)
# Kiểm tra phân giải tên miền miền trước:
ping -c 2 dhcnhn.com
# (Bắt buộc phải trả về IP 10.0.0.2)

# 2. Cài đặt các gói công cụ gia nhập miền
sudo apt update
sudo apt install -y sssd sssd-tools realmd adcli

# 3. Bật PAM tự động tạo thư mục home khi người dùng miền đăng nhập lần đầu
echo "session optional pam_mkhomedir.so skel=/etc/skel umask=0077" | sudo tee -a /etc/pam.d/common-session

# 4. Cho phép nhóm domain users đăng nhập
echo "* ; * ; * ; Al0000-2400 ; domain users" | sudo tee -a /etc/security/group.conf

# 5. Thực hiện tham gia miền của máy chủ điều khiển miền (Mật khẩu: Dhcnhn1)
sudo realm -v join dhcnhn.com -U administrator

# 6. Lệnh kiểm tra lấy điểm:
realm list
id gv1@dhcnhn.com
```

---

### BƯỚC 3: CẤU HÌNH DỊCH VỤ DHCP TRÊN DC01 (3 Điểm)
*Thực hiện trên máy chủ DC01:*

1. Mở file cấu hình `/etc/dhcp/dhcpd.conf`:
```bash
sudo nano /etc/dhcp/dhcpd.conf
```
2. Thêm vào cuối file cấu hình:
```text
# Thời gian thuê mặc định: 15 phút (15 * 60 = 900 giây)
default-lease-time 900;

# Thời gian thuê tối đa: 1,1 ngày (1.1 * 86400 = 95040 giây)
max-lease-time 95040;
authoritative;

subnet 10.0.0.0 netmask 255.0.0.0 {
    option routers 10.0.0.254;
    option subnet-mask 255.0.0.0;
    option domain-name "dhcnhn.com";
    option domain-name-servers 10.0.0.2;

    # Cấp dải động từ 10.0.0.100 đến 10.0.0.200
    range 10.0.0.100 10.0.0.200;

    # Từ chối cấp tự động cấu hình mạng cho Client có MAC 22:22:22:22:22:22
    host may-bi-chan {
        hardware ethernet 22:22:22:22:22:22;
        deny booting;
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

### BƯỚC 4: QUẢN TRỊ TẬP TIN / THƯ MỤC TRÊN DC01 (3 Điểm)
*Thực hiện trên máy chủ DC01:*

```bash
# 1. Tạo các tài khoản và nhóm lưu trữ CỤC BỘ trên Linux
sudo addgroup gv
sudo addgroup sv

# Tạo user cục bộ (đặt pass lần lượt là Giangvien1, Giangvien2, Sinhvien1, Sinhvien2)
sudo adduser --ingroup gv gv1
sudo adduser --ingroup gv gv2
sudo adduser --ingroup sv sv1
sudo adduser --ingroup sv sv2

# 2. Tạo thư mục dùng chung share tại /srv/ chứa thư mục GV và SV
sudo mkdir -p /srv/share/{GV,SV}

# 3. Tạo tập tin gv.txt và sv.txt lần lượt trong thư mục GV và SV
sudo touch /srv/share/GV/gv.txt /srv/share/SV/sv.txt
echo "Tai lieu GV" | sudo tee /srv/share/GV/gv.txt
echo "Tai lieu SV" | sudo tee /srv/share/SV/sv.txt

# 4. Phân quyền sở hữu:
# Giảng viên 1 sở hữu thư mục GV; Nhóm gv có quyền đối với thư mục GV
sudo chown -R gv1:gv /srv/share/GV
sudo chmod 770 /srv/share/GV

# Sinh viên 1 sở hữu thư mục SV; Nhóm sv có quyền đối với thư mục SV
sudo chown -R sv1:sv /srv/share/SV
sudo chmod 770 /srv/share/SV

# 5. Lệnh kiểm tra cho giáo viên chấm:
ls -ld /srv/share/GV /srv/share/SV
ls -l /srv/share/GV/gv.txt /srv/share/SV/sv.txt
```

---

## 3. LƯU Ý KỸ THUẬT QUAN TRỌNG

1. **Tên nhóm trong đề:** Đề ghi rõ *"Tạo nhóm giảng viên (gv) và sinh viên (sv)"* $\rightarrow$ Đặt tên nhóm là `gv` và `sv` (chữ thường).
2. **Quy đổi thời gian thuê DHCP:**
   * 15 phút = $15 \times 60 = 900$ giây.
   * 1,1 ngày = $1.1 \times 24 \times 3600 = 95040$ giây.
3. **Phân biệt User miền và User cục bộ:**
   * Câu 1: Dùng lệnh `samba-tool user/group` để tạo tài khoản **trong miền**.
   * Câu 3: Dùng lệnh Linux OS `adduser` / `addgroup` để tạo tài khoản **cục bộ**.
