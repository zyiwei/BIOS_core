         ;�����嵥6-1
         ;�ļ�����c06_mbr.asm
         ;�ļ�˵����Ӳ����������������
         ;�������ڣ�2021-4-12 22:12 
      
         jmp near start                ;��Խ�ת��
         
  mytext db 'L',0x07,'a',0x07,'b',0x07,'e',0x07,'l',0x07,' ',0x07,'o',0x07,\
            'f',0x07,'f',0x07,'s',0x07,'e',0x07,'t',0x07,':',0x07
  number db 0,0,0,0,0                  ;ר�Ŵ���ַ�����������
  
  start:
         mov ax,0x7c0                  ;�������ݶλ���ַ 
         mov ds,ax                     ;ds = 0x07c0
         
         mov ax,0xb800                 ;���ø��Ӷλ���ַ 
         mov es,ax                     ;es = 0xb800,esָ����ʾ���������ڶ�
         
         cld                           ;FLAG�Ĵ���DFλ���㣬�����ͣ���ַ�ɵ͵���
         mov si,mytext                 ;DS:SIԭ���ݴ���ַ
         mov di,0                      ;ES:DI����Ŀ�ĵ�ַ
         mov cx,(number-mytext)/2      ;ʵ���ϵ��� 13��CSΪ�������͵�������ÿ����һ���ֵݼ�
         rep movsw                     ;�������ͣ�ÿ�δ���һ���֡�ָ��ǰ׺rep����ʾCS��Ϊ�����ظ�movsw
     
         ;�õ�����������ƫ�Ƶ�ַ
         mov ax,number
         
         ;���������λ
         mov bx,ax
         mov cx,5                      ;ѭ���������ֽ�AX�е�����Ҫѭ��5��
         mov si,10                     ;���� 
  digit: 
         xor dx,dx                     ;��DX�����ñ������ĸ�16λ
         div si
         mov [bx],dl                   ;����DL�е�������λ����BX��������ָʾ���ڴ浥Ԫ
         inc bx                        ;��BX�е����ݼ�һ
         loop digit                    ;ʹCX���ݼ�һ�����ж��Ƿ�Ϊ��
         
         ;��ʾ������λ
         mov bx,number                 ;�������и�����λ����������ƫ���׵�ַ���浽BX��
         mov si,4                      ;SI = 4����ĩβ����5����
   show:
         mov al,[bx+si]                ;BX+SI��������ָ��ִ�е�ʱ���ɴ��������
         add al,0x30                   ;�õ�AL�����ֶ�Ӧ��ASCII��
         mov ah,0x04                   ;ǰ8λ���ַ�����ʾ����
         mov [es:di],ax                ;��AX�����ݴ��͵�ES��ָ��ε��Դ���
         add di,2                      ;DIΪ�Դ�ƫ�ƣ�ÿ����һ���ԼӶ�
         dec si                        ;ָ����һλ����
         jns show                      ;FLAG�Ĵ����е�SFλ�����dec���������λΪ1����SF��1������ѭ��
         
         mov word [es:di],0x0744       ;�ڵװ�����ʾ�ַ�D

         jmp near $                    ;ͬ: $: jump near $, ����$����������

  times 510-($-$$) db 0
                   db 0x55,0xaa