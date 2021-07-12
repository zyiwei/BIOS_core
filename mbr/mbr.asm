         ;代码清单5-1 
         ;文件名：c05_mbr.asm
         ;文件说明：硬盘主引导扇区代码
         ;创建日期：2021-3-31 21:15 
         
         mov ax,0xb800                 ;将es指向文本模式的显示缓冲区
         mov es,ax                     ;es=0xb800

         ;以下显示字符串"Label offset:"
         mov byte [es:0x00],'L'        ;低地址存入字符(以ASCII码形式)
         mov byte [es:0x01],0x07       ;高地址设置字符表现形式
         mov byte [es:0x02],'a'
         mov byte [es:0x03],0x07
         mov byte [es:0x04],'b'
         mov byte [es:0x05],0x07
         mov byte [es:0x06],'e'
         mov byte [es:0x07],0x07
         mov byte [es:0x08],'l'
         mov byte [es:0x09],0x07
         mov byte [es:0x0a],' '
         mov byte [es:0x0b],0x07
         mov byte [es:0x0c],"o"
         mov byte [es:0x0d],0x07
         mov byte [es:0x0e],'f'
         mov byte [es:0x0f],0x07
         mov byte [es:0x10],'f'
         mov byte [es:0x11],0x07
         mov byte [es:0x12],'s'
         mov byte [es:0x13],0x07
         mov byte [es:0x14],'e'
         mov byte [es:0x15],0x07
         mov byte [es:0x16],'t'
         mov byte [es:0x17],0x07
         mov byte [es:0x18],':'
         mov byte [es:0x19],0x07

         mov ax,number                 ;取得标号number的偏移地址，number为汇编地址，等于number处的偏移地址
         mov bx,10                     ;将10存入bx中，后面作为除数

         ;设置数据段的基地址
         mov cx,cs                     ;
         mov ds,cx                     ;ds=cs

         ;求个位上的数字
         mov dx,0                      ;将除数高16位置零，除数为DX:AX
         div bx                        ;DX:AX / BX
         mov [0x7c00+number+0x00],dl   ;保存个位上的数字, dl为余数

         ;求十位上的数字
         xor dx,dx                     ;将dx清零
         div bx
         mov [0x7c00+number+0x01],dl   ;保存十位上的数字

         ;求百位上的数字
         xor dx,dx
         div bx
         mov [0x7c00+number+0x02],dl   ;保存百位上的数字

         ;求千位上的数字
         xor dx,dx
         div bx
         mov [0x7c00+number+0x03],dl   ;保存千位上的数字

         ;求万位上的数字 
         xor dx,dx
         div bx
         mov [0x7c00+number+0x04],dl   ;保存万位上的数字

         ;以下用十进制显示标号的偏移地址
         mov al,[0x7c00+number+0x04]   ;将已保存的万位上的数字放入al中
         add al,0x30                   ;获得该数字的ASCII码
         mov [es:0x1a],al              ;将该数字的ASCII码放入低位显存中(紧跟放入的字符)
         mov byte [es:0x1b],0x04       ;高位放入数字的表现形式
         
         mov al,[0x7c00+number+0x03]
         add al,0x30
         mov [es:0x1c],al
         mov byte [es:0x1d],0x04
         
         mov al,[0x7c00+number+0x02]
         add al,0x30
         mov [es:0x1e],al
         mov byte [es:0x1f],0x04

         mov al,[0x7c00+number+0x01]
         add al,0x30
         mov [es:0x20],al
         mov byte [es:0x21],0x04

         mov al,[0x7c00+number+0x00]
         add al,0x30
         mov [es:0x22],al
         mov byte [es:0x23],0x04
         
         mov byte [es:0x24],'D'        ;表示所显示数字为十进制
         mov byte [es:0x25],0x07       ;表现形式
          
   infi: jmp near infi                 ;无限循环，infi处的汇编地址-当前指令的汇编地址
      
  number db 0,0,0,0,0                  ;用于存放5位地址
  
  times 203 db 0                       ;在前面的内容和结尾的0xaa55之间，有203字节的空洞，用0来填补(重复db 0 203次)
            db 0x55,0xaa               ;一个有效的主引导扇区，最后两个字节的数据必须是0x55和0xaa