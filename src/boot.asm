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

mov si, booting
call print

xchg bx, bx

mov edi, 0x1000 ; 读取的目标内存
mov ecx, 0 ; 起始扇区
mov bl, 1 ; 扇区数量

call read_disk

xchg bx, bx

; 阻塞
jmp $ 

read_disk:
	
	; 设置读写扇区的数量
	mov dx, 0x1f2
	mov al, bl
	out dx, al

	inc dx ; 0x1f3
	mov al, cl ; 起始扇区低8位
	out dx, al

	inc dx ; 0x1f4
	shr ecx, 8
	mov al, cl ; 起始扇区中8位
	out dx, al

	inc dx ; 0x1f5
	shr ecx, 8
	mov al, cl ; 起始扇区高8位
	out dx, al

	inc dx ; 0x1f6
	shr ecx, 8
	and cl, 0b1111 ;高四位变为0， 只剩下低四位
	mov al, 0b1110_0000;
	or al, cl
	out dx, al

	inc dx ;0x1f7
	mov al, 0x20 ; 读硬盘
	out dx, al

	xor ecx, ecx ; 清空 ecx
	mov cl, bl ; 得到读写扇区数量

	.read:
		push cx
		call .waits
		call .reads
		pop cx
		loop .read

	ret

	.waits:
		mov dx, 0x1f7
		.check:
			in al, dx
			jmp $+2 ; 直接跳转到下一行，nop 消耗时钟周期
			jmp $+2 ; 一点点延迟，硬盘要求
			jmp $+2
			and al, 0b1000_1000
			cmp al, 0b0000_1000
			jnz .check
		ret
	
	.reads:
		mov dx, 0x1f0
		mov cx, 256 ; 一个扇区 256 字
		.readw:
			in ax, dx
			jmp $+2 ; 直接跳转到下一行，nop 消耗时钟周期
			jmp $+2 ; 一点点延迟，硬盘要求
			jmp $+2
			mov [edi], ax
			add edi, 2
			loop .readw
		ret
	

print:
	mov ah, 0x0e
.next:
	mov al, [si]
	cmp al, 0
	jz .done
	int 0x10
	inc si
	jmp .next
.done:
	ret

booting:
	db "TsuhaOS booting...", 13, 10, 0

; 0 填充剩余区域
times 510 - ($ - $$) db 0
; 主引导扇区的最后两个字节必须是 0xaa55, 
; dw 0xaa 0x55
db 0x55, 0xaa ; 由于是小端存储，所以要先写 0x55
