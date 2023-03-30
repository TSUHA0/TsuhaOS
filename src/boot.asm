; 代码在内存中的位置为 0x7c00
[org 0x7c00]

; 设置屏幕模式为文本模式，清除屏幕
mov ax,3
int 0x10

; 初始化段寄存器
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00 ;程序指针


; 0xb800 文本显示的内存区域，从这里开始显示文本
mov ax, 0xb800
mov ds, ax
mov byte [0], 'H'

; 阻塞
jmp $ 

; 0 填充剩余区域
times 510 - ($ - $$) db 0
; 主引导扇区的最后两个字节必须是 0xaa55, 
; dw 0xaa 0x55
db 0x55, 0xaa ; 由于是小端存储，所以要先写 0x55
