         ;代码清单8-1
         ;文件名：c08_mbr.asm
         ;文件说明：硬盘主引导扇区代码（加载程序） 
         ;创建日期：2021-5-5 21:17
         
         app_lba_start equ 100           ;声明常数（用户程序起始逻辑扇区号）
                                         ;常数的声明不会占用汇编地址
                                    
SECTION mbr align=16 vstart=0x7c00       ;段内所有元素的汇编地址都从0x7c00开始计算

         ;设置堆栈段和栈指针 
         mov ax,0                        ;SS:SP=0x0000:0x0000
         mov ss,ax
         mov sp,ax
      
         mov ax,[cs:phy_base]            ;计算用于加载用户程序的逻辑段地址，低16位存入AX
         mov dx,[cs:phy_base+0x02]       ;高16位存入DX。phy_base由0x7c00开始，所以不用再加
         mov bx,16        
         div bx                          ;将DX:AX除以16，AX中的商就是得到的段地址(0x1000)
         mov ds,ax                       ;令DS和ES指向该段以进行操作。DS=0x1000
         mov es,ax                       ;ES=0x1000
    
         ;以下读取程序的起始部分 
         xor di,di                       ;DI=0x0000
         mov si,app_lba_start            ;程序在硬盘上的起始逻辑扇区号 存入SI
         xor bx,bx                       ;DI:SI=0x0000:100D DS:BX=0x1000:0000
         call read_hard_disk_0
      
         ;以下判断整个程序有多大
         mov dx,[2]                      ;曾经把dx写成了ds，花了二十分钟排错 
         mov ax,[0]                      ;DX:AX为32位的程序总长度
         mov bx,512                      ;512字节每扇区
         div bx
         cmp dx,0                        ;DX中为余数，AX为商。此处判断是否除尽
         jnz @1                          ;未除尽，因此结果比实际扇区数少1 
         dec ax                          ;已经读了一个扇区，扇区总数减1 
   @1:
         cmp ax,0                        ;考虑实际长度小于等于512个字节的情况 
         jz direct                       ;若AX为零，用户程序已全部被读取
         
         ;读取剩余的扇区
         push ds                         ;以下要用到并改变DS寄存器 

         mov cx,ax                       ;循环次数（剩余扇区数）
   @2:
         mov ax,ds
         add ax,0x20                     ;得到下一个以512字节为边界的段地址。每次加载一个扇区都重新构造一个段
         mov ds,ax                       ;读至DS:BX处
                              
         xor bx,bx                       ;每次读时，偏移地址始终为0x0000 
         inc si                          ;下一个逻辑扇区 
         call read_hard_disk_0
         loop @2                         ;循环读，直到读完整个功能程序 

         pop ds                          ;恢复数据段基址到用户程序头部段 
      
         ;计算入口点代码段基址 
   direct:
         mov dx,[0x08]                   ;DX:AX存放用户程序入口点段地址(20位汇编地址)
         mov ax,[0x06]
         call calc_segment_base
         mov [0x06],ax                   ;回填修正后的入口点代码段基址。处理了入口点代码段的重定位
      
         ;开始处理段重定位表
         mov cx,[0x0a]                   ;需要重定位的项目数量，也是后面循环的次数
         mov bx,0x0c                     ;重定位表首地址，位于用户程序头部偏移0x0c处。

 realloc:
         mov dx,[bx+0x02]                ;32位地址的高16位 
         mov ax,[bx]                     ;bx总是指向需要重定位的段的偏移地址
         call calc_segment_base          ;计算逻辑段地址
         mov [bx],ax                     ;回填段的基址
         add bx,4                        ;下一个重定位项（每项占4个字节） 
         loop realloc 
      
         jmp far [0x04]                  ;转移到用户程序  
 
;-------------------------------------------------------------------------------
read_hard_disk_0:                        ;从硬盘读取一个逻辑扇区
                                         ;输入：DI:SI=起始逻辑扇区号
                                         ;      DS:BX=目标缓冲区地址
         push ax
         push bx
         push cx
         push dx
      
         mov dx,0x1f2
         mov al,1
         out dx,al                       ;将1写入0x1f2端口。每次读取的扇区数为1

         inc dx                          ;0x1f3
         mov ax,si
         out dx,al                       ;LBA地址7~0

         inc dx                          ;0x1f4
         mov al,ah
         out dx,al                       ;LBA地址15~8

         inc dx                          ;0x1f5
         mov ax,di
         out dx,al                       ;LBA地址23~16

         inc dx                          ;0x1f6
         mov al,0xe0                     ;LBA28模式，主盘
         or al,ah                        ;LBA地址27~24
         out dx,al

         inc dx                          ;0x1f7
         mov al,0x20                     ;0x20为读命令
         out dx,al                       ;将读命令传送到0x1f7端口

  .waits:
         in al,dx
         and al,0x88
         cmp al,0x08                     ;判断0x1f7端口的第三位是否为1，以及第七位是否为0
         jnz .waits                      ;若满足上述条件，说明硬盘不忙，且已准备好数据传输 

         mov cx,256                      ;总共要读取的字数
         mov dx,0x1f0
  .readw:
         in ax,dx                        ;将0x1f0端口中的数据存入AX
         mov [bx],ax                     ;存入DS:BX处
         add bx,2
         loop .readw                     ;一次读区256个字

         pop dx
         pop cx
         pop bx
         pop ax
      
         ret

;-------------------------------------------------------------------------------
calc_segment_base:                       ;计算16位段地址
                                         ;输入：DX:AX=32位物理地址
                                         ;返回：AX=16位段基地址 
         push dx                          
         
         add ax,[cs:phy_base]            ;将用户程序在内存中的物理起始地址的低16位加到AX中
         adc dx,[cs:phy_base+0x02]       ;将高16位加到DX中。使用带进位加法，完成32位数的加法运算
         shr ax,4                        ;低16位右移四位
         ror dx,4                        ;高16位循环右移四位
         and dx,0xf000                   
         or ax,dx                        ;高16位的原最右边4位和低16位的最左边12位结合，存入AX，这是段地址
         
         pop dx
         
         ret

;-------------------------------------------------------------------------------
         phy_base dd 0x10000             ;用户程序被加载的物理起始地址，用一个32位的单元来容纳20位的地址
         
 times 510-($-$$) db 0
                  db 0x55,0xaa