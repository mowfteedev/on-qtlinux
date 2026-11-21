# 01. Thay Đổi Giao Diện Mạng (Netplan) Và Thao Tác Cơ Bản

Tài liệu hướng dẫn cấu hình mạng tĩnh trên máy chủ DC01 bằng Netplan và các thao tác dòng lệnh cơ bản trong giáo trình FE6092.

---

## 1. File cấu hình `/etc/netplan/01-netcfg.yaml`

Chạy lệnh `ip link` kiểm tra tên card mạng trước khi cấu hình:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:                  # <--- THAY ĐỔI: Tên card mạng thực tế xem từ lệnh 'ip link'
      dhcp4: false
      addresses:
        - 10.0.0.2/8        # <--- THAY ĐỔI: Địa chỉ IP tĩnh và prefix (/8) theo đề bài
      routes:
        - to: default
          via: 10.0.0.254   # <--- THAY ĐỔI: Địa chỉ Gateway theo đề bài
      nameservers:
        addresses: [10.0.0.2, 8.8.8.8]   # <--- THAY ĐỔI: Địa chỉ máy chủ DNS theo đề bài
        search: [dhcnhn.com]             # <--- THAY ĐỔI: Domain search theo đề bài
```

---

## 2. Lệnh áp dụng và kiểm tra mạng (Trang 6)

```bash
# Áp dụng cấu hình mạng
sudo netplan apply

# Kiểm tra địa chỉ IP và bảng định tuyến
ip a; ip r

# Kiểm tra phân giải DNS và file cấu hình resolv
resolvectl status
sudo cat /etc/resolv.conf

# Giải phóng và cấp lại địa chỉ IP bằng DHCP (nếu dùng DHCP)
sudo dhclient -r; sudo dhclient

# Kiểm tra kết nối
ping -c 2 10.0.0.254        # <--- THAY ĐỔI: IP Gateway cần kiểm tra
ping -c 2 8.8.8.8           # Kiểm tra thông ra Internet
```

---

## 3. Thao tác tập tin và thư mục (Nguyên mẫu giáo trình Bài 2 - Trang 7)

```bash
# 1. Chuyển thư mục thành /srv/ và in đường dẫn hiện tại
cd /srv/ && pwd

# 2. Tạo thư mục dùng chung share gồm thư mục giảng viên (gv) và sinh viên (sv)
sudo mkdir -p /srv/share/{gv,sv}

# 3. Tạo tập tin gv.txt và sv.txt lần lượt trong thư mục gv và sv
sudo touch /srv/share/gv/gv.txt /srv/share/sv/sv.txt

# 4. Viết nội dung và hiển thị nội dung
echo "Tai lieu Giang vien" | sudo tee /srv/share/gv/gv.txt
echo "Tai lieu Sinh vien" | sudo tee /srv/share/sv/sv.txt
cat /srv/share/gv/gv.txt /srv/share/sv/sv.txt

# 5. Đổi tên tập tin sv.txt thành sv1.txt
sudo mv /srv/share/sv/sv.txt /srv/share/sv/sv1.txt

# 6. Sao chép tập tin sv1.txt thành sv2.txt
sudo cp /srv/share/sv/sv1.txt /srv/share/sv/sv2.txt

# 7. Sao chép toàn bộ nội dung thư mục share tới Desktop
cp -r /srv/share ~/Desktop/

# 8. Xóa tập tin, xóa thư mục và xóa toàn bộ nội dung
sudo rm -f /srv/share/gv/gv.txt
sudo rmdir /srv/share/gv/
sudo rm -rf /srv/share/*
```

---

## 4. Quản lý lịch sử câu lệnh History (Trang 7)
```bash
history                     # Hiển thị các lệnh đã chạy
!<command_number>           # Chạy lại câu lệnh theo số thứ tự
history -c && history -w    # Xóa sạch toàn bộ lịch sử lệnh
```
