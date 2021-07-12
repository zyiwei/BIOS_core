         ;�����嵥8-2
         ;�ļ�����c08.asm
         ;�ļ�˵�����û����� 
         ;�������ڣ�2021-5-5 21:17
         
;===============================================================================
SECTION header vstart=0                     ;�����û�����ͷ���� 
    program_length  dd program_end          ;�����ܳ���[0x00]
    
    ;�û�������ڵ�
    code_entry      dw start                ;ƫ�Ƶ�ַ[0x04]
                    dd section.code_1.start ;�ε�ַ[0x06] 
    
    realloc_tbl_len dw (header_end-code_1_segment)/4
                                            ;���ض�λ�������[0x0a]
    
    ;���ض�λ��           
    code_1_segment  dd section.code_1.start ;[0x0c]
    code_2_segment  dd section.code_2.start ;[0x10]
    data_1_segment  dd section.data_1.start ;[0x14]
    data_2_segment  dd section.data_2.start ;[0x18]
    stack_segment   dd section.stack.start  ;[0x1c]
    
    header_end:                
    
;===============================================================================
SECTION code_1 align=16 vstart=0         ;��������1��16�ֽڶ��룩 
put_string:                              ;��ʾ��(0��β)��
                                         ;���룺DS:BX=����ַ
         mov cl,[bx]                     ;��DS:BX��ȡ�������ַ�
         or cl,cl                        ;cl=0 ?
         jz .exit                        ;������ַ�Ϊ0������������ 
         call put_char
         inc bx                          ;��һ���ַ� 
         jmp put_string

   .exit:
         ret

;-------------------------------------------------------------------------------
put_char:                                ;��ʾһ���ַ�
                                         ;���룺cl=�ַ�ascii
         push ax
         push bx
         push cx
         push dx
         push ds
         push es

         ;����ȡ��ǰ���λ��
         mov dx,0x3d4                    ;DX:�����Ĵ����˿ں�
         mov al,0x0e                     ;AL:�Կ�8λ���Ĵ���������ֵ��14��
         out dx,al                       ;���Ĵ�������д��˿ڡ�����0x0e�żĴ���
         mov dx,0x3d5                    ;DX:���ݶ˿�0x3d5��
         in al,dx                        ;��0x0e����һ�ֽ����ݡ���Ļ���λ�õĸ�8λ 
         mov ah,al                       ;��8λ����AH

         mov dx,0x3d4
         mov al,0x0f                     ;AL:15�Ź��Ĵ���
         out dx,al                       ;����д�������˿�
         mov dx,0x3d5
         in al,dx                        ;��0x0f����һ�ֽ����ݡ���Ļ���λ�õĵ�8λ����AL
         mov bx,ax                       ;BX=������λ�õ�16λ��

         cmp cl,0x0d                     ;�س�����
         jnz .put_0a                     ;���ǡ������ǲ��ǻ��е��ַ� 
         mov ax,bx                       ;�˾����Զ��࣬��ȥ���󻹵ø��飬�鷳 
         mov bl,80                       
         div bl                          ;AX�еĹ��λ�ó���BL�е�80����AL�еõ���ǰ�е��к�
         mul bl                          ;AL�е��кų�BL�е�80��AX�еõ���ǰ�����׹��ֵ
         mov bx,ax                       ;���ֵ���͵�BX�б���
         jmp .set_cursor                 ;ת�Ƶ�.set_cursor�����ù������Ļ�ϵ�λ��

 .put_0a:
         cmp cl,0x0a                     ;���з���
         jnz .put_other                  ;���ǣ��Ǿ�������ʾ�ַ� 
         add bx,80                       ;�ǻ��з��������������80������һ������
         jmp .roll_screen                ;���ܹ��ԭ�������һ�У�.roll_screen�����Ƿ����

 .put_other:                             ;������ʾ�ַ�
         mov ax,0xb800
         mov es,ax                       ;ESָ���Դ棨ESԭ������ѹջ���棬������ʹ�ã�
         shl bx,1                        ;�����ֵ����һ�Σ�һ���ַ������ֽ���ʾ�����ֵ�˶��ĵ��ַ�ƫ�Ƶ�ַ��
         mov [es:bx],cl                  ;���ַ�д���Դ�

         ;���½����λ���ƽ�һ���ַ�
         shr bx,1                        ;�ַ�ƫ�Ƴ��Զ��ָ�������
         add bx,1                        ;����ƽ����

 .roll_screen:
         cmp bx,2000                     ;��곬����Ļ������
         jl .set_cursor                  ;�������������ù��

         mov ax,0xb800
         mov ds,ax
         mov es,ax                       ;DS��ES��ָ���Դ��
         cld
         mov si,0xa0                     ;SIΪ�ڶ��е�һ�еĹ��ֵ
         mov di,0x00                     ;DI:��һ�е�һ��
         mov cx,1920                     ;24�г�ÿ��80���ַ�
         rep movsw                       ;������1920���ַ�
         mov bx,3840                     ;�����Ļ���һ�С�25�е�һ���ַ����Դ���ƫ�Ƶ�ַΪ3840
         mov cx,80                       ;������һ��80���ַ�
 .cls:
         mov word[es:bx],0x0720          ;�ڵװ��ֵĿհ��ַ�
         add bx,2
         loop .cls

         mov bx,1920                     ;���������һ�е�һ�еĹ����ֵΪ1920

 .set_cursor:
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         mov al,bh                       ;����8λ
         out dx,al                       ;д��0x0e���Ĵ���
         mov dx,0x3d4
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         mov al,bl                       ;����8λ
         out dx,al                       ;д��0x0f���Ĵ���

         pop es
         pop ds
         pop dx
         pop cx
         pop bx
         pop ax

         ret

;-------------------------------------------------------------------------------
  start:
         ;��ʼִ��ʱ��DS��ESָ���û�����ͷ����
         mov ax,[stack_segment]           ;���õ��û������Լ��Ķ�ջ 
         mov ss,ax                        ;SSָ���û������ջ�Ķε�ַ
         mov sp,stack_end                 ;stack_endΪ256
         
         mov ax,[data_1_segment]          ;���õ��û������Լ������ݶ�
         mov ds,ax                        ;DSָ�����ݶ�data_1�Ķε�ַ

         mov bx,msg0                      ;���ַ���ƫ�Ƶ�ַ���͵�BX����ʱDS:BXָ��Ҫ��ʾ���ַ�
         call put_string                  ;��ʾ��һ����Ϣ 

         push word [es:code_2_segment]    ;��ջ��ѹ������code_2�Ķε�ַ������retfת����
         mov ax,begin
         push ax                          ;ѹ��code_2��ʼ��ƫ�Ƶ�ַ������ֱ��push begin,80386+
         
         retf                             ;ת�Ƶ������2ִ�� 
         
  continue:
         mov ax,[es:data_2_segment]       ;�μĴ���DS�л������ݶ�2 
         mov ds,ax
         
         mov bx,msg1
         call put_string                  ;��ʾ�ڶ�����Ϣ 

         jmp $ 

;===============================================================================
SECTION code_2 align=16 vstart=0          ;��������2��16�ֽڶ��룩

  begin:
         push word [es:code_1_segment]    ;��ջ��ѹ������code_1�Ķε�ַ������retfת����
         mov ax,continue
         push ax                          ;code_1��continue��ƫ�Ƶ�ַ������ֱ��push continue,80386+
         
         retf                             ;ת�Ƶ������1����ִ�� 
         
;===============================================================================
SECTION data_1 align=16 vstart=0

    msg0 db '  This is NASM - the famous Netwide Assembler. '
         db 'Back at SourceForge and in intensive development! '
         db 'Get the current versions from http://www.nasm.us/.'
         db 0x0d,0x0a,0x0d,0x0a                                                ;0x0d�س���0x0a����
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
         db 0                                                               ;��ʶ�ַ����Ľ���

;===============================================================================
SECTION data_2 align=16 vstart=0

    msg1 db '  The above contents is written by ZHANGYIWEI. '
         db '2021-05-06'
         db 0

;===============================================================================
SECTION stack align=16 vstart=0
           
         resb 256               ;αָ��resb���ӵ�ǰλ�ÿ�ʼ������256�ֽڣ�����ʼ��������Ϊջ�ռ�

stack_end:                      ;stack_end������ַΪ256

;===============================================================================
SECTION trail align=16
program_end: