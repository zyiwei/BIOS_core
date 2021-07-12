         ;代码清单9-2
         ;文件名：c09_2.asm
         ;文件说明：用于演示BIOS中断的用户程序 
         ;创建日期：2021-3-28 20:35
         
;===============================================================================
SECTION header vstart=0                     ;定义用户程序头部段 
    program_length  dd program_end          ;程序总长度[0x00]
    
    ;用户程序入口点
    code_entry      dw start                ;偏移地址[0x04]
                    dd section.code.start   ;段地址[0x06] 
    
    realloc_tbl_len dw (header_end-realloc_begin)/4
                                            ;段重定位表项个数[0x0a]
    
    realloc_begin:
    ;段重定位表           
    code_segment    dd section.code.start   ;[0x0c]
    data_segment    dd section.data.start   ;[0x14]
    stack_segment   dd section.stack.start  ;[0x1c]
    
header_end:                
    
;===============================================================================
SECTION code align=16 vstart=0           ;定义代码段（16字节对齐） 
start:
      mov ax,[stack_segment]
      mov ss,ax
      mov sp,ss_pointer
      mov ax,[data_segment]
      mov ds,ax
      
      mov cx,msg_end-message
      mov bx,message                     ;ds:bx指向字符
      
 .putc:
      mov ah,0x0e                        ;中断0x10的0x0e号功能。在屏幕的光标位置写一个字符，推进光标
      mov al,[bx]                        ;要写的字符存入al。这是0x10号中断的参数
      int 0x10                           ;向屏幕上写字符，使用BIOS中断
      inc bx
      loop .putc

 .reps:
      mov ah,0x00                        ;使用0x16中断的0x00号功能。从键盘读字符
      int 0x16                           ;使用软中断0x16从键盘上读字符
      
      mov ah,0x0e
      mov bl,0x07
      int 0x10                           ;把从键盘取得的字符显示到屏幕上. al中为从键盘读取的字符

      jmp .reps

;===============================================================================
SECTION data align=16 vstart=0

    message       db 'Hello, friend!',0x0d,0x0a
                  db 'This simple procedure used to demonstrate '
                  db 'the BIOS interrupt.',0x0d,0x0a
                  db 'Please press the keys on the keyboard ->'
    msg_end:
                   
;===============================================================================
SECTION stack align=16 vstart=0
           
                 resb 256
ss_pointer:
 
;===============================================================================
SECTION program_trail
program_end: