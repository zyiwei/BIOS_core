         ;代码清单6-1
         ;文件名：c06_mbr.asm
         ;文件说明：硬盘主引导扇区代码
         ;创建日期：2021-4-12 22:12 
      
         jmp near start                ;相对近转移
         
  mytext db 'L',0x07,'a',0x07,'b',0x07,'e',0x07,'l',0x07,' ',0x07,'o',0x07,\
            'f',0x07,'f',0x07,'s',0x07,'e',0x07,'t',0x07,':',0x07
  number db 0,0,0,0,0                  ;专门存放字符串的数据区
  
  start:
         mov ax,0x7c0                  ;设置数据段基地址 
         mov ds,ax                     ;ds = 0x07c0
         
         mov ax,0xb800                 ;设置附加段基地址 
         mov es,ax                     ;es = 0xb800,es指向显示缓冲区所在段
         
         cld                           ;FLAG寄存器DF位清零，正向传送，地址由低到高
         mov si,mytext                 ;DS:SI原数据串地址
         mov di,0                      ;ES:DI传送目的地址
         mov cx,(number-mytext)/2      ;实际上等于 13，CS为批量传送的字数，每传送一个字递减
         rep movsw                     ;批量传送，每次传送一个字。指令前缀rep，表示CS不为零则重复movsw
     
         ;得到标号所代表的偏移地址
         mov ax,number
         
         ;计算各个数位
         mov bx,ax
         mov cx,5                      ;循环次数，分解AX中的数需要循环5次
         mov si,10                     ;除数 
  digit: 
         xor dx,dx                     ;将DX清零获得被除数的高16位
         div si
         mov [bx],dl                   ;保存DL中的余数数位，至BX的内容所指示的内存单元
         inc bx                        ;将BX中的内容加一
         loop digit                    ;使CX内容减一，并判断是否为零
         
         ;显示各个数位
         mov bx,number                 ;将保存有各个数位的数据区的偏移首地址保存到BX中
         mov si,4                      ;SI = 4，从末尾遍历5个数
   show:
         mov al,[bx+si]                ;BX+SI运算是在指令执行的时候，由处理器完成
         add al,0x30                   ;得到AL中数字对应的ASCII码
         mov ah,0x04                   ;前8位是字符的显示属性
         mov [es:di],ax                ;将AX中数据传送到ES所指向段的显存中
         add di,2                      ;DI为显存偏移，每传送一次自加二
         dec si                        ;指向下一位数字
         jns show                      ;FLAG寄存器中的SF位，如果dec运算结果最高位为1，则将SF置1，跳出循环
         
         mov word [es:di],0x0744       ;黑底白字显示字符D

         jmp near $                    ;同: $: jump near $, 符号$隐藏在行首

  times 510-($-$$) db 0
                   db 0x55,0xaa