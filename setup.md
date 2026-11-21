# Cấu hình môi trường mạng trên VMware Workstation

Tài liệu hướng dẫn thiết lập card mạng ảo `VMnet8 (NAT)` trên VMware Workstation trước khi khởi động các máy ảo.

---

## 1. Mục đích cấu hình
* Đưa toàn bộ các máy ảo về chung dải mạng nội bộ `10.0.0.0/8` theo yêu cầu bài thực hành.
* Đặt Gateway mặc định `10.0.0.254` để máy chủ và máy trạm kết nối Internet qua NAT.
* Vô hiệu hóa dịch vụ DHCP mặc định của VMware để tránh xung đột với dịch vụ DHCP do máy chủ DC01 cung cấp.

---

## 2. Các bước thực hiện

### Bước 1: Mở Virtual Network Editor
1. Trên thanh công cụ VMware Workstation, chọn **Edit** $\rightarrow$ **Virtual Network Editor...**
2. Nếu xuất hiện nút **Change Settings** (yêu cầu quyền Administrator) ở góc dưới bên phải, click vào nút này để cấp quyền chỉnh sửa.

### Bước 2: Thiết lập thông số cho VMnet8
1. Chọn card mạng **VMnet8** (Type: NAT).
2. Tại mục **Subnet IP**, điền: `10.0.0.0`.
3. Tại mục **Subnet mask**, điền: `255.0.0.0`.

### Bước 3: Đổi Gateway IP
1. Click vào nút **NAT Settings...**
2. Tại ô **Gateway IP**, chỉnh sửa thành: `10.0.0.254`.
3. Click **OK** để quay lại màn hình trước.

### Bước 4: Tắt DHCP của VMware
1. Tại giao diện chính của Virtual Network Editor, tìm dòng:
   `Use local DHCP service to distribute IP address to VMs`
2. **Bỏ tích chọn** (uncheck) ô này.

### Bước 5: Lưu cấu hình
1. Click **Apply** và click **OK** để hoàn tất cấu hình.

---

## 3. Gán card mạng cho máy ảo
Vào phần **Settings** của từng máy ảo (DC01, Client1, Client2):
* Chọn mục **Network Adapter**.
* Đảm bảo đã chọn **NAT** (hoặc chọn **Custom: Specific virtual network** $\rightarrow$ chọn `VMnet8`).
