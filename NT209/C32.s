.section .data
thongbao: .string "Nhap chuoi khong qua 255 ky tu \n"

.section .bss
        .lcomm input, 255    # Tạo vùng nhớ có 255 ký tự để đọc vào

.section .text
        .globl _start
_start:
    # In thông báo
        movl $4, %eax       # Gọi hàm sys_write
        movl $1, %ebx       # In ra thông báo
        movl $thongbao, %ecx   # Địa chỉ chuỗi thông báo
        movl $32, %edx      # Độ dài chuỗi cần in
        int $0x80           # Gọi hàm kernel

    # Nhập vào
        movl $3, %eax       # Gọi hàm sys_read
        movl $0, %ebx       # Nhập từ bàn phím
        mov $input, %ecx    # Địa chỉ chuỗi nhập
        movl $255, %edx      # Đọc 255 byte, bao gồm cả '\n'
        int $0x80           # Gọi hàm kernel

    # Mã Ascii để chuyển đổi hoa thường
    # A = 65, Z = 90, a = 97, z = 122

    # Thực thi
        movl $0, %ecx       # int i = 0, %ecx làm chỉ số duyệt.
        movl $input, %eax   # Địa chỉ của chuỗi nhập
        movb (%ecx,%eax), %bl   # ký tự đầu tiên của chuỗi (input[0])
        cmp $0, %ecx        # nếu i = 0
        je .condition1      # nhảy đến ktra xem có in hoa không.loop:                  #Lặp kiểm tra chuỗi 
        incl %ecx           # tăng i lên 1 đơn vị, kiểm tra chữ tiếp theo của chuỗi
        cmp $255, %ecx      # kiểm tra i < 255, vì giới hạn là 255 kí tự và i bắt đầu từ 0
        jge .printResult    # nếu i >= 255, in kết quả
        movb (%ecx,%eax), %bl   #Lấy kí tự input[i] vào thanh ghi %bl
        cmp $10, %bl        # ký tự là '\n'
        je .printResult     # nếu là '\n', in kết quả
        cmp $32, %bl        # Nếu ký tự là ' '
        je .condition       # nhảy đến ktra xem có in hoa không
        jmp .condition2     # Nếu không phải nhảy đến .condition2 để kiểm tra là chữ viết hoa hay thường

.condition:             # ky tu i+1 (Sau dấu cách) có in hoa ?
        incl %ecx       # Dịch sang 1 kí tự
        movb (%ecx,%eax), %bl #Lấy kí tự đó
        jmp .condition1     #Kiểm tra xem kí tự đó có viết hoa hay không

.condition1:                # ktra có viết thường?
        cmp $97, %bl        # dk so sánh >= 'a'
        jl .loop            # Nhảy đến .loop nếu %bl < 97
        cmp $122,%bl        # dk so sánh <='z'
        jle .upper          # Nhảy đến .upper nếu %bl <= 122, tức là nó là chữ thường nhảy đến vòng lặp đổi nó thành chữ in
        jmp .loop           # Quay lại vòng lặp

.condition2:            # ktra có viết hoa?
        cmp $65, %bl        # dk so sánh >= 'A'
        jl .loop
        cmp $90, %bl        # dk so sánh <='Z'
        jle .lower
        jmp .loop           # Quay lại vòng lặp
.upper:
        sub $32,%bl         # Chuyển chữ hoa thành chữ thường, bằng cách trừ đi 32
        movb %bl, (%ecx,%eax)   # Thay thế byte hiện tại trong chuỗi
        jmp .loop           # Quay lại vòng lặp

.lower:
        add $32,%bl         # Chuyển chữ thường thành chữ hoa, bằng cách cộng thêm 32
        movb %bl, (%ecx,%eax)   # Thay thế byte hiện tại trong chuỗi
        jmp .loop           # Quay lại vòng lặp

.printResult:
    # In kết quả
        movl $4, %eax       # Gọi hàm sys_write
        movl $1, %ebx       # In ra terminal
        movl $input, %ecx   # Địa chỉ của chuỗi nhập
        movl %ecx, %edx     # Độ dài của chuỗi
        int $0x80           # Gọi hàm kernel

    #Thoát
        movl $1, %eax    # syscall: sys_exit
        xorl %ebx, %ebx  # trả mã thoát = 0
        int $0x80
