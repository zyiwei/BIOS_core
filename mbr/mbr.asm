         ;�����嵥5-1 
         ;�ļ�����c05_mbr.asm
         ;�ļ�˵����Ӳ����������������
         ;�������ڣ�2021-3-31 21:15 
         
         mov ax,0xb800                 ;��esָ���ı�ģʽ����ʾ������
         mov es,ax                     ;es=0xb800

         ;������ʾ�ַ���"Label offset:"
         mov byte [es:0x00],'L'        ;�͵�ַ�����ַ�(��ASCII����ʽ)
         mov byte [es:0x01],0x07       ;�ߵ�ַ�����ַ�������ʽ
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

         mov ax,number                 ;ȡ�ñ��number��ƫ�Ƶ�ַ��numberΪ����ַ������number����ƫ�Ƶ�ַ
         mov bx,10                     ;��10����bx�У�������Ϊ����

         ;�������ݶεĻ���ַ
         mov cx,cs                     ;
         mov ds,cx                     ;ds=cs

         ;���λ�ϵ�����
         mov dx,0                      ;��������16λ���㣬����ΪDX:AX
         div bx                        ;DX:AX / BX
         mov [0x7c00+number+0x00],dl   ;�����λ�ϵ�����, dlΪ����

         ;��ʮλ�ϵ�����
         xor dx,dx                     ;��dx����
         div bx
         mov [0x7c00+number+0x01],dl   ;����ʮλ�ϵ�����

         ;���λ�ϵ�����
         xor dx,dx
         div bx
         mov [0x7c00+number+0x02],dl   ;�����λ�ϵ�����

         ;��ǧλ�ϵ�����
         xor dx,dx
         div bx
         mov [0x7c00+number+0x03],dl   ;����ǧλ�ϵ�����

         ;����λ�ϵ����� 
         xor dx,dx
         div bx
         mov [0x7c00+number+0x04],dl   ;������λ�ϵ�����

         ;������ʮ������ʾ��ŵ�ƫ�Ƶ�ַ
         mov al,[0x7c00+number+0x04]   ;���ѱ������λ�ϵ����ַ���al��
         add al,0x30                   ;��ø����ֵ�ASCII��
         mov [es:0x1a],al              ;�������ֵ�ASCII������λ�Դ���(����������ַ�)
         mov byte [es:0x1b],0x04       ;��λ�������ֵı�����ʽ
         
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
         
         mov byte [es:0x24],'D'        ;��ʾ����ʾ����Ϊʮ����
         mov byte [es:0x25],0x07       ;������ʽ
          
   infi: jmp near infi                 ;����ѭ����infi���Ļ���ַ-��ǰָ��Ļ���ַ
      
  number db 0,0,0,0,0                  ;���ڴ��5λ��ַ
  
  times 203 db 0                       ;��ǰ������ݺͽ�β��0xaa55֮�䣬��203�ֽڵĿն�����0���(�ظ�db 0 203��)
            db 0x55,0xaa               ;һ����Ч����������������������ֽڵ����ݱ�����0x55��0xaa