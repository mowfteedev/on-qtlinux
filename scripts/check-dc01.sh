#!/usr/bin/env bash
# Script kiểm tra trạng thái dịch vụ trên máy chủ DC01

echo "=========================================="
echo " KIỂM TRA TRẠNG THÁI HỆ THỐNG DC01"
echo "=========================================="

echo -e "\n[1] IP Address & Default Gateway:"
ip -4 a show ens33 2>/dev/null | grep inet || ip -4 a | grep inet
ip r | grep default

echo -e "\n[2] Kiểm tra kết nối mạng:"
ping -c 1 10.0.0.254 >/dev/null 2>&1 && echo "  - Gateway (10.0.0.254): THÔNG (OK)" || echo "  - Gateway: MẤT KẾT NỐI (FAILED)"
ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo "  - Internet (8.8.8.8): THÔNG (OK)" || echo "  - Internet: MẤT KẾT NỐI (FAILED)"

echo -e "\n[3] Trạng thái các dịch vụ Daemon:"
for s in samba-ad-dc isc-dhcp-server apache2; do
    if systemctl is-active --quiet "$s" 2>/dev/null; then
        echo "  - $s: ACTIVE (Đang chạy)"
    else
        echo "  - $s: INACTIVE (Chưa chạy hoặc lỗi)"
    fi
done

echo -e "\n[4] Kiểm tra phân quyền /srv/share:"
if [ -d "/srv/share" ]; then
    ls -ld /srv/share /srv/share/gv /srv/share/sv 2>/dev/null
    ls -l /srv/share/gv/gv.txt 2>/dev/null
else
    echo "  - Thư mục /srv/share chưa được tạo."
fi

echo -e "\n[5] Danh sách User Active Directory:"
if command -v samba-tool >/dev/null 2>&1; then
    sudo samba-tool user list 2>/dev/null | grep -E "gv1|gv2|sv1|sv2" || echo "  - Chưa tạo user gv/sv trên AD."
fi

echo -e "\n=========================================="
echo " HOÀN TẤT KIỂM TRA"
echo "=========================================="
