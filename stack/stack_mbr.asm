         ;代码清单7-1
         ;文件名：c07_mbr.asm
         ;文件说明：硬盘主引导扇区代码
         ;创建日期：2021-4-13 22:02
         
         jmp near start         ;跳过没有指令的数据区
	
 message db '1+2+3+...+100='    ;在编译阶段，编译器将字符串拆开，形成单独的字节
        
 start:
         mov ax,0x7c0           ;设置数据段的段基地址 
         mov ds,ax              ;数据段寄存器DS=0x7c0

         mov ax,0xb800          ;设置附加段基址到显示缓冲区
         mov es,ax              ;附加段寄存器ES=0xb800

         ;以下显示字符串 
         mov si,message         ;SI指向数据段偏移
         mov di,0               ;DI指向显存偏移
         mov cx,start-message   ;CX为循环次数，等于字符个数
     @g:
         mov al,[si]
         mov [es:di],al         ;将DS:SI中的一个字符传送到ES:DI
         inc di
         mov byte [es:di],0x07  ;加入显示属性
         inc di                 ;指向下一个将要存入字符的地址
         inc si                 ;下一个字符所在地址
         loop @g                ;先将CX中内容减一，再根据CX是否为零决定是否开始下一轮循环

         ;以下计算1到100的和 
         xor ax,ax              ;将AX清零
         mov cx,1               ;CX作为累加器
     @f:
         add ax,cx              ;累加和存入AX
         inc cx 
         cmp cx,100             ;CX和100比较
         jle @f                 ;如果CX<=100，继续循环

         ;以下计算累加和的每个数位 
         xor cx,cx              ;设置堆栈段的段基地址
         mov ss,cx              ;栈段的段地址SS=0x0000
         mov sp,cx              ;栈指针SP=0x0000,此时代码段与栈段为同一个段

         mov bx,10              ;BX为除数10
         xor cx,cx              ;将CX清零，用于累计数位
     @d:
         inc cx                 ;分解一次数位，数位多了一个
         xor dx,dx              ;DX:AX为32位被除数，将高位清零
         div bx                 ;除以10
         or dl,0x30             ;余数在DL中，且高四位一定为零。得到ASCII码
         push dx                ;将DX的内容压入栈中。先将SP的内容减二，把数据存入SS:SP所指位置(第一次地址为0x0000:0xFFFE)
         cmp ax,0               ;判断除法结束后商是否为零
         jne @d                 ;如果不为零，继续循环

         ;以下显示各个数位 
     @a:
         pop dx                 ;将SS:SP指向的一个字存入DX中，SP加二
         mov [es:di],dl         ;将弹出的数据写入缓存
         inc di
         mov byte [es:di],0x07  ;显示属性
         inc di
         loop @a                ;一直循环直到CX减为零
       
         jmp near $ 
       

times 510-($-$$) db 0
                 db 0x55,0xaa