         ;代码清单12-1
         ;文件名：c12_mbr.asm
         ;文件说明：硬盘主引导扇区代码 
         ;创建日期：2021-10-27 22:52

         ;设置堆栈段和栈指针 
         mov eax,cs      
         mov ss,eax                         ;此处编译器后的结果与使用ax一样
         mov sp,0x7c00
      
         ;计算GDT所在的逻辑段地址
         mov eax,[cs:pgdt+0x7c00+0x02]      ;GDT的32位线性基地址 
         xor edx,edx
         mov ebx,16
         div ebx                            ;分解成16位逻辑地址 

         mov ds,eax                         ;令DS指向该段以进行操作
         mov ebx,edx                        ;段内起始偏移地址 

         ;创建0#描述符，它是空描述符，这是处理器的要求
         mov dword [ebx+0x00],0x00000000
         mov dword [ebx+0x04],0x00000000  

         ;创建1#描述符，这是一个数据段，对应0~4GB的线性地址空间
         mov dword [ebx+0x08],0x0000ffff    ;基地址为0，段界限为0xfffff
         mov dword [ebx+0x0c],0x00cf9200    ;粒度为4KB，存储器段描述符 

         ;创建保护模式下初始代码段描述符
         mov dword [ebx+0x10],0x7c0001ff    ;基地址为0x00007c00，512字节 
         mov dword [ebx+0x14],0x00409800    ;粒度为1个字节，代码段描述符 

         ;创建以上代码段的别名描述符
         mov dword [ebx+0x18],0x7c0001ff    ;基地址为0x00007c00，512字节
         mov dword [ebx+0x1c],0x00409200    ;粒度为1个字节，数据段描述符(可通过此描述符修改代码段内的数据)

         mov dword [ebx+0x20],0x7c00fffe    ;基地址为0x00007c00
         mov dword [ebx+0x24],0x00cf9600    ;栈段描述符。低端有效地址为0x00006c00,高端地址为0x00007bff
         
         ;初始化描述符表寄存器GDTR
         mov word [cs: pgdt+0x7c00],39      ;描述符表的界限。总大小40字节，界限值39
 
         lgdt [cs: pgdt+0x7c00]
      
         in al,0x92                         ;南桥芯片内的端口 
         or al,0000_0010B
         out 0x92,al                        ;打开A20

         cli                                ;中断机制尚未工作

         mov eax,cr0
         or eax,1
         mov cr0,eax                        ;设置PE位
      
         ;以下进入保护模式... ...
         jmp dword 0x0010:flush             ;16位的描述符选择子：32位偏移
                                             
         [bits 32]                          
  flush:                                     
         mov eax,0x0018                      
         mov ds,eax
      
         mov eax,0x0008                     ;加载数据段(0..4GB)选择子
         mov es,eax
         mov fs,eax
         mov gs,eax
      
         mov eax,0x0020                     ;0000 0000 0010 0000
         mov ss,eax
         xor esp,esp                        ;ESP <- 0
      
         mov dword [es:0x0b8000],0x072e0750 ;字符'P'、'.'及其显示属性
         mov dword [es:0x0b8004],0x072e074d ;字符'M'、'.'及其显示属性
         mov dword [es:0x0b8008],0x07200720 ;两个空白字符及其显示属性
         mov dword [es:0x0b800c],0x076b076f ;字符'o'、'k'及其显示属性

         ;开始冒泡排序 
         mov ecx,pgdt-string-1              ;遍历次数=串长度-1 
  @@1:
         push ecx                           ;32位模式下的loop使用ecx 
         xor bx,bx                          ;32位模式下，偏移量可以是16位，也可以 
  @@2:                                      ;是后面的32位 （32位代码中也可以使用16位寄存器寻址）
         mov ax,[string+bx]                 ;一次性读取两个字符到AX寄存器中。
         cmp ah,al                          ;ah中存放的是源字的高字节，比较两个字符
         jge @@3                            ;(AH)>=(AL),跳转到 @@3
         xchg al,ah                         ;(AH)<(AL),交换AL,AH中的值
         mov [string+bx],ax                 ;将经过比较处理后的两个字符放回原处
  @@3:
         inc bx                             ;bx中的值（遍历索引）加一
         loop @@2                           ;ecx中的值减一，同时判断是否为0，若不为零，则继续内循环
         pop ecx                            ;内循环结束，ecx为0，从栈顶弹出更新ecx
         loop @@1                           ;ecx值减一，并判断是否进行外循环
      
         mov ecx,pgdt-string
         xor ebx,ebx                        ;偏移地址是32位的情况 
  @@4:                                      ;32位的偏移具有更大的灵活性
         mov ah,0x07
         mov al,[string+ebx]
         mov [es:0xb80a0+ebx*2],ax          ;演示0~4GB寻址。
         inc ebx
         loop @@4
      
         hlt 

;-------------------------------------------------------------------------------
     string           db 's0ke4or92xap3fv8giuzjcy5l1m7hd6bnqtw.'    ;位于32位代码段中，不允许写入（使用）
                                                                    ;代码段别名描述符
;-------------------------------------------------------------------------------
     pgdt             dw 0
                      dd 0x00007e00      ;GDT的物理地址
;-------------------------------------------------------------------------------                             
     times 510-($-$$) db 0
                      db 0x55,0xaa