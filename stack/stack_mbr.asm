         ;�����嵥7-1
         ;�ļ�����c07_mbr.asm
         ;�ļ�˵����Ӳ����������������
         ;�������ڣ�2021-4-13 22:02
         
         jmp near start         ;����û��ָ���������
	
 message db '1+2+3+...+100='    ;�ڱ���׶Σ����������ַ����𿪣��γɵ������ֽ�
        
 start:
         mov ax,0x7c0           ;�������ݶεĶλ���ַ 
         mov ds,ax              ;���ݶμĴ���DS=0x7c0

         mov ax,0xb800          ;���ø��Ӷλ�ַ����ʾ������
         mov es,ax              ;���ӶμĴ���ES=0xb800

         ;������ʾ�ַ��� 
         mov si,message         ;SIָ�����ݶ�ƫ��
         mov di,0               ;DIָ���Դ�ƫ��
         mov cx,start-message   ;CXΪѭ�������������ַ�����
     @g:
         mov al,[si]
         mov [es:di],al         ;��DS:SI�е�һ���ַ����͵�ES:DI
         inc di
         mov byte [es:di],0x07  ;������ʾ����
         inc di                 ;ָ����һ����Ҫ�����ַ��ĵ�ַ
         inc si                 ;��һ���ַ����ڵ�ַ
         loop @g                ;�Ƚ�CX�����ݼ�һ���ٸ���CX�Ƿ�Ϊ������Ƿ�ʼ��һ��ѭ��

         ;���¼���1��100�ĺ� 
         xor ax,ax              ;��AX����
         mov cx,1               ;CX��Ϊ�ۼ���
     @f:
         add ax,cx              ;�ۼӺʹ���AX
         inc cx 
         cmp cx,100             ;CX��100�Ƚ�
         jle @f                 ;���CX<=100������ѭ��

         ;���¼����ۼӺ͵�ÿ����λ 
         xor cx,cx              ;���ö�ջ�εĶλ���ַ
         mov ss,cx              ;ջ�εĶε�ַSS=0x0000
         mov sp,cx              ;ջָ��SP=0x0000,��ʱ�������ջ��Ϊͬһ����

         mov bx,10              ;BXΪ����10
         xor cx,cx              ;��CX���㣬�����ۼ���λ
     @d:
         inc cx                 ;�ֽ�һ����λ����λ����һ��
         xor dx,dx              ;DX:AXΪ32λ������������λ����
         div bx                 ;����10
         or dl,0x30             ;������DL�У��Ҹ���λһ��Ϊ�㡣�õ�ASCII��
         push dx                ;��DX������ѹ��ջ�С��Ƚ�SP�����ݼ����������ݴ���SS:SP��ָλ��(��һ�ε�ַΪ0x0000:0xFFFE)
         cmp ax,0               ;�жϳ������������Ƿ�Ϊ��
         jne @d                 ;�����Ϊ�㣬����ѭ��

         ;������ʾ������λ 
     @a:
         pop dx                 ;��SS:SPָ���һ���ִ���DX�У�SP�Ӷ�
         mov [es:di],dl         ;������������д�뻺��
         inc di
         mov byte [es:di],0x07  ;��ʾ����
         inc di
         loop @a                ;һֱѭ��ֱ��CX��Ϊ��
       
         jmp near $ 
       

times 510-($-$$) db 0
                 db 0x55,0xaa