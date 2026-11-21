# Quản Trị Hệ Thống Trên Nền Tảng Linux (FE6092)

Tài liệu ôn tập thực hành môn Quản trị Linux, bám sát các nội dung trọng tâm.

---

## Cấu Hình Môi Trường Ban Đầu

* [setup.md](setup.md): Hướng dẫn cấu hình card mạng ảo VMnet8 trên VMware Workstation.

---

## Danh Mục Nội Dung

1. [01-giao-dien-mang.md](docs/01-giao-dien-mang.md): Thay đổi giao diện mạng (Netplan tĩnh).
2. [02-vao-mien.md](docs/02-vao-mien.md): Cấu hình Client tham gia vào miền Active Directory.
3. [03-tai-khoan-mien-va-cuc-bo.md](docs/03-tai-khoan-mien-va-cuc-bo.md): Quản trị tài khoản trong miền và tài khoản cục bộ.
4. [04-dich-vu-dns.md](docs/04-dich-vu-dns.md): Cấu hình dịch vụ DNS phân giải tên miền.
5. [05-dich-vu-dhcp.md](docs/05-dich-vu-dhcp.md): Triển khai dịch vụ cấp phát địa chỉ IP (DHCP).
6. [06-dich-vu-web.md](docs/06-dich-vu-web.md): Triển khai máy chủ Web ảo (Apache2 Virtual Hosts).
7. [07-quyen-so-huu-va-tep-tin.md](docs/07-quyen-so-huu-va-tep-tin.md): Phân quyền và quyền sở hữu tập tin, thư mục.
8. [08-anh-xa-tep-tin.md](docs/08-anh-xa-tep-tin.md): Chia sẻ thư mục qua mạng bằng Samba và ánh xạ từ Client.

---

## File Cấu Hình Mẫu

* [configs/01-netplan.yaml](configs/01-netplan.yaml): File Netplan tĩnh mẫu.
* [configs/dhcpd.conf](configs/dhcpd.conf): File cấu hình DHCP Server mẫu.
* [configs/vhost-apache.conf](configs/vhost-apache.conf): File Virtual Hosts Apache2 mẫu.
* [configs/samba-share.conf](configs/samba-share.conf): Cấu hình chia sẻ Samba mẫu.

---

## Đề Thi Thực Tế & Lời Giải Chi Tiết

* [template/vi-du-01.md](template/vi-du-01.md): **Đề thi số 01 (Mã đề 4)** - Client Join Domain, DHCP dải 100-200 + deny MAC, Phân quyền thư mục `/srv/share/{GV,SV}`.
* [template/vi-du-02.md](template/vi-du-02.md): **Đề thi số 02 (Mã đề 3)** - Client Join Domain, DNS 3 zone xuôi/ngược, Apache Virtual Hosts kèm 2 thư mục con `en` và `vn`.
* [template/vi-du-03.md](template/vi-du-03.md): Đề thi tổng hợp nâng cao tham khảo thêm (DHCP Filter + POSIX ACL).

---

## Script Hỗ Trợ Kiểm Tra

* [scripts/check-dc01.sh](scripts/check-dc01.sh): Script kiểm tra trạng thái dịch vụ trên máy chủ DC01.
