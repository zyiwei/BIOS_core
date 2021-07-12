         ;代码清单8-2
         ;文件名：c08.asm
         ;文件说明：用户程序 
         ;创建日期：2021-5-5 21:17
         
;===============================================================================
SECTION header vstart=0                     ;定义用户程序头部段 
    program_length  dd program_end          ;程序总长度[0x00]
    
    ;用户程序入口点
    code_entry      dw start                ;偏移地址[0x04]
                    dd section.code_1.start ;段地址[0x06] 
    
    realloc_tbl_len dw (header_end-code_1_segment)/4
                                            ;段重定位表项个数[0x0a]
    
    ;段重定位表           
    code_1_segment  dd section.code_1.start ;[0x0c]
    code_2_segment  dd section.code_2.start ;[0x10]
    data_1_segment  dd section.data_1.start ;[0x14]
    data_2_segment  dd section.data_2.start ;[0x18]
    stack_segment   dd section.stack.start  ;[0x1c]
    
    header_end:                
    
;===============================================================================
SECTION code_1 align=16 vstart=0         ;定义代码段1（16字节对齐） 
put_string:                              ;显示串(0结尾)。
                                         ;输入：DS:BX=串地址
         mov cl,[bx]                     ;从DS:BX中取出单个字符
         or cl,cl                        ;cl=0 ?
         jz .exit                        ;若这个字符为0，返回主程序 
         call put_char
         inc bx                          ;下一个字符 
         jmp put_string

   .exit:
         ret

;-------------------------------------------------------------------------------
put_char:                                ;显示一个字符
                                         ;输入：cl=字符ascii
         push ax
         push bx
         push cx
         push dx
         push ds
         push es

         ;以下取当前光标位置
         mov dx,0x3d4                    ;DX:索引寄存器端口号
         mov al,0x0e                     ;AL:显卡8位光标寄存器的索引值（14）
         out dx,al                       ;光标寄存器索引写入端口。操作0x0e号寄存器
         mov dx,0x3d5                    ;DX:数据端口0x3d5。
         in al,dx                        ;从0x0e读出一字节数据。屏幕光标位置的高8位 
         mov ah,al                       ;高8位存入AH

         mov dx,0x3d4
         mov al,0x0f                     ;AL:15号光标寄存器
         out dx,al                       ;号码写入索引端口
         mov dx,0x3d5
         in al,dx                        ;从0x0f读出一字节数据。屏幕光标位置的低8位存入AL
         mov bx,ax                       ;BX=代表光标位置的16位数

         cmp cl,0x0d                     ;回车符？
         jnz .put_0a                     ;不是。看看是不是换行等字符 
         mov ax,bx                       ;此句略显多余，但去掉后还得改书，麻烦 
         mov bl,80                       
         div bl                          ;AX中的光标位置除以BL中的80，在AL中得到当前行的行号
         mul bl                          ;AL中的行号乘BL中的80，AX中得到当前行行首光标值
         mov bx,ax                       ;光标值仍送到BX中保存
         jmp .set_cursor                 ;转移到.set_cursor处设置光标在屏幕上的位置

 .put_0a:
         cmp cl,0x0a                     ;换行符？
         jnz .put_other                  ;不是，那就正常显示字符 
         add bx,80                       ;是换行符。光标内容增加80，到下一行行首
         jmp .roll_screen                ;可能光标原先在最后一行，.roll_screen决定是否滚屏

 .put_other:                             ;正常显示字符
         mov ax,0xb800
         mov es,ax                       ;ES指向显存（ES原内容已压栈保存，可任意使用）
         shl bx,1                        ;将光标值左移一次（一个字符两个字节显示，光标值乘二的到字符偏移地址）
         mov [es:bx],cl                  ;将字符写入显存

         ;以下将光标位置推进一个字符
         shr bx,1                        ;字符偏移除以二恢复光标身份
         add bx,1                        ;向后推进光标

 .roll_screen:
         cmp bx,2000                     ;光标超出屏幕？滚屏
         jl .set_cursor                  ;正常，继续设置光标

         mov ax,0xb800
         mov ds,ax
         mov es,ax                       ;DS和ES都指向显存段
         cld
         mov si,0xa0                     ;SI为第二行第一列的光标值
         mov di,0x00                     ;DI:第一行第一列
         mov cx,1920                     ;24行乘每行80个字符
         rep movsw                       ;传送这1920个字符
         mov bx,3840                     ;清除屏幕最底一行。25行第一列字符在显存中偏移地址为3840
         mov cx,80                       ;清除最后一行80个字符
 .cls:
         mov word[es:bx],0x0720          ;黑底白字的空白字符
         add bx,2
         loop .cls

         mov bx,1920                     ;滚屏后，最后一行第一列的光标数值为1920

 .set_cursor:
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         mov al,bh                       ;光标高8位
         out dx,al                       ;写入0x0e光标寄存器
         mov dx,0x3d4
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         mov al,bl                       ;光标低8位
         out dx,al                       ;写入0x0f光标寄存器

         pop es
         pop ds
         pop dx
         pop cx
         pop bx
         pop ax

         ret

;-------------------------------------------------------------------------------
  start:
         ;初始执行时，DS和ES指向用户程序头部段
         mov ax,[stack_segment]           ;设置到用户程序自己的堆栈 
         mov ss,ax                        ;SS指向用户程序堆栈的段地址
         mov sp,stack_end                 ;stack_end为256
         
         mov ax,[data_1_segment]          ;设置到用户程序自己的数据段
         mov ds,ax                        ;DS指向数据段data_1的段地址

         mov bx,msg0                      ;将字符串偏移地址传送到BX。此时DS:BX指向要显示的字符
         call put_string                  ;显示第一段信息 

         push word [es:code_2_segment]    ;在栈中压入代码段code_2的段地址。后面retf转移用
         mov ax,begin
         push ax                          ;压入code_2起始处偏移地址。可以直接push begin,80386+
         
         retf                             ;转移到代码段2执行 
         
  continue:
         mov ax,[es:data_2_segment]       ;段寄存器DS切换到数据段2 
         mov ds,ax
         
         mov bx,msg1
         call put_string                  ;显示第二段信息 

         jmp $ 

;===============================================================================
SECTION code_2 align=16 vstart=0          ;定义代码段2（16字节对齐）

  begin:
         push word [es:code_1_segment]    ;在栈中压入代码段code_1的段地址。后面retf转移用
         mov ax,continue
         push ax                          ;code_1中continue段偏移地址。可以直接push continue,80386+
         
         retf                             ;转移到代码段1接着执行 
         
;===============================================================================
SECTION data_1 align=16 vstart=0

    msg0 db '  This is NASM - the famous Netwide Assembler. '
         db 'Back at SourceForge and in intensive development! '
         db 'Get the current versions from http://www.nasm.us/.'
         db 0x0d,0x0a,0x0d,0x0a                                                ;0x0d回车，0x0a换行
         db '  Example code for calculate 1+2+...+1000:',0x0d,0x0a,0x0d,0x0a
         db '     xor dx,dx',0x0d,0x0a
         db '     xor ax,ax',0x0d,0x0a
         db '     xor cx,cx',0x0d,0x0a
         db '  @@:',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     add ax,cx',0x0d,0x0a
         db '     adc dx,0',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     cmp cx,1000',0x0d,0x0a
         db '     jle @@',0x0d,0x0a
         db '     ... ...(Some other codes)',0x0d,0x0a,0x0d,0x0a
         db 0                                                               ;标识字符串的结束

;===============================================================================
SECTION data_2 align=16 vstart=0

    msg1 db '  The above contents is written by ZHANGYIWEI. '
         db '2021-05-06'
         db 0

;===============================================================================
SECTION stack align=16 vstart=0
           
         resb 256               ;伪指令resb。从当前位置开始，保留256字节（不初始化），作为栈空间

stack_end:                      ;stack_end处汇编地址为256

;===============================================================================
SECTION trail align=16
program_end: