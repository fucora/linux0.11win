!********************************************************************************************************
!	���������Ӳ��MBR��,���ڰ�linux0.11ӳ��Image�����ڴ�(��bootsect.s����0x90000��ʼ��,��setup.s����
!0x90200��ʼ��,��head.s��sysģ�����0x10000��ʼ��),Ȼ������ԭ��bootsect.s��110��"call kill_motor"����ִ��.
!Ŀ����ʵ��ֱ�Ӵ�Ӳ������linux0.11.
!	����: fastwork	email: fastwork@sina.com	����: 2005.4.1
!********************************************************************************************************


.globl begtext,begdata,begbss,endtext,enddata,endbss
.text
begtext:
.data
begdata:
.bss
begbss:
.text

INITSEG		= 0x07c0
BOOTSECTSEG	= 0x9000
SETUPSEG	= 0x9020
SYSSEG		= 0x1000

NAME_LEN	= 0x05

!��������Ϣƫ�Ƶ�ַ
FIRST_PARTITION_OFT	= 0x01be
START_SECT_OFT		= 0x08+FIRST_PARTITION_OFT

!��������Ϣƫ�Ƶ�ַ
S_NINODES	= 0x00
S_NZONES	= 0x02
S_IMAP_BLOCKS	= 0x04
S_ZMAP_BLOCKS	= 0x06
S_FIRSTDATAZONE	= 0x08
S_LOG_ZONE_SIZE	= 0x0a
S_MAX_SIZE	= 0x0c
S_MAGIC		= 0x10

!i�ڵ���Ϣƫ�Ƶ�ַ
I_MODE		= 0x00
I_UID		= 0x02
I_SIZE		= 0x04
I_MTIME		= 0x08
I_GID		= 0x0c
I_NLINKS	= 0x0d
I_ZONE0		= 0x0e

!Ӳ�̲���ƫ�Ƶ�ַ
!-----------------------------------------------------------
!INT 41 -> FIXED DISK PARAMETERS (XT,AT,XT2,XT286,PS except ESDI disks)
!	dw	cylinders
!	db	heads
!	dw	0
!	dw	write pre-comp
!	db	0
!	db	0 "control byte"
!	db	0, 0, 0
!	dw	landing zone
!	db	sectors/track
!	db	0
!-----------------------------------------------------------
HD_INFO_PTR_OFT	= 4*0x41		!��һ��Ӳ�̲�����Ķε�ַ��ƫ�Ƶ�ַ��BIOS�ж�0x41������ʼ��4���ֽ���
NCYL_OFT	= 0x00			!������
NHEAD_OFT	= 0x02			!��ͷ��
WPCON_OFT	= 0x05			!дǰԤ���������
CTL_OFT		= 0x08			!�����ֽ�
LZONE_OFT	= 0x0c			!��ͷ��½�������
SPT_OFT		= 0x0e			!ÿ�ŵ�������

!������ʱ���һ����������
SECTOR_BUF_OFT	= 1024

entry start
start:
	xor ax, ax
	mov ds, ax
	lds si, [HD_INFO_PTR_OFT]
	mov ah, NHEAD_OFT(si)	!��ȡ��ͷ��
	mov al, SPT_OFT(si)	!��ȡÿ�ŵ�������

        mov bx, #INITSEG
	mov ds, bx
	mov ss, bx
	mov es, bx
	mov sp, #0x0300

	mov nhead, ah		!�����ͷ��
	mov nspt, al		!����ÿ�ŵ�������

	mov ah, #0x03
	xor bh,bh
	int 0x10		!�����λ��,DH,DL=��,��
	mov bx, #0x0007 	!������ʾ����
	mov bp, #msg
	mov cx, #45
	mov ax, #0x1301
	int 0x10		!��ʾ�ַ���"MBR loading the image from Hard disk..."


!��ȡ������
	mov bx, #SECTOR_BUF_OFT
	mov ax, #0x01
	call read_block_use_zone_num

	mov ax, SECTOR_BUF_OFT+S_IMAP_BLOCKS
	add ax, SECTOR_BUF_OFT+S_ZMAP_BLOCKS
	add ax, #2
	mov inode_start_zone, ax		!���i�ڵ����ʼ�̿��

	mov ax, SECTOR_BUF_OFT+S_FIRSTDATAZONE
	mov firstdatazone, ax			!��������ʼ�̿��

!����i�ڵ��һ���̿�,��firstdatazone
	!mov ax, #INITSEG		!��ϸ���˿�����,����es����INITSEG,Ϊʡ�ռ��������ȥ��
	!mov es, ax			!��ʵ�����Ļ����ܶ��Ķ������е������
	mov bx, #SECTOR_BUF_OFT
	mov ax, firstdatazone
	call read_block_use_zone_num


				!****************************************************************************
				!	����image_name�ڸ�i�ڵ�ĵ�һ���̿����Ŀ¼��(�����ں�ӳ��ֻ�ܷ��ڸ�
				!Ŀ¼��,���ұ�����ǰ��64��,�д��Ľ�)
				!һ���̿���Դ��64��struct dir_entry{ unsigned short inode; char name[14]; }
				!****************************************************************************
	mov bx, #SECTOR_BUF_OFT+2
notmatch:
	mov di, bx
	mov si, #image_name
	mov cx, #NAME_LEN
	repz 
	cmpsb
	je match
	add bx, #16
	j notmatch
match:
	sub bx, #0x02
 	mov ax, (bx)		!���linux0.11ӳ���i�ڵ��(��1��ʼ)

!**************************************************************************************************************
!	���濪ʼ����linux0.11ӳ���ļ�:ǰ2.5k bytes���ڵ�ַ0x90000��ʼ��(bootsect.sΪ512bytes,setup.sΪ2k bytes),
!ʣ�µķ��ڵ�ַ0x10000��ʼ��
!	Minixһ���̿�Ϊ1k bytes,�����0.5kʹ�ô�����΢�鷳һ��,�Ұѿ�ʼ��7k������0x90000��ʼ��,Ȼ�����2.5k�����
!4.5k�����Ƶ�0x10000��ʼ��
!	�Ҽ���ӳ���ļ��ò���������,�Ͼ�������linux0.11,��Ҳȷʵû��ô��
!**************************************************************************************************************
!��ȡlinux0.11ӳ���i�ڵ�

	dec ax
	xor dx, dx
	mov bx, #32			!һ���̿��ܴ��32��i�ڵ�
	div bx				!ax=(dx*2^16+ax)/bx, dx=(dx*2^16+ax)%bx
	push dx				!�������̿�ĵڼ���i�ڵ�?(0��ʾ��һ��)
	add ax, inode_start_zone

	!mov bx, #INITSEG		!��ϸ���˿�����,����es����INITSEG,Ϊʡ�ռ��������ȥ��
	!mov es, bx			!��ʵ�����Ļ����ܶ��Ķ������е������
	mov bx, #SECTOR_BUF_OFT
	call read_block_use_zone_num	!����i�ڵ��
	pop bx				!bx=(linux0.11ӳ���ļ���i�ڵ��-1) mod 32
	shl bx, #5			!��ʱbx��linux0.11ӳ���ļ���i�ڵ��ڶ�����1k�����е�ƫ�Ƶ�ַ
	add bx, #SECTOR_BUF_OFT		!bx=ӳ���ļ�i�ڵ������INITSEG�ε�ƫ�Ƶ�ַ
	push bx				!����
	mov ax, (bx+I_SIZE)		!ax���linux0.11ӳ��"�ļ���С"�ĵ�2�ֽ�
	mov dx, (bx+I_SIZE+2)		!dx���linux0.11ӳ��"�ļ���С"�ĸ�2�ֽ�
	mov cx, #1024
	div cx
	cmp dx, #0x0000			!���¿�ʼ����linux0.11ӳ���ļ�ռ�õ��̿���
	je set_image_nzones
	inc ax
set_image_nzones:
	mov image_nzones, ax		!����linux0.11ӳ���ļ�ռ�õ��̿���

					!*********************************************************************
					!	��ֱ�ӿ�
					!*********************************************************************

!��ǰ˵��,�ȶ�������7��ֱ�ӿ�,����0x90000��ʼ��
	mov timers, #0x07
	mov ax, #BOOTSECTSEG
	mov es, ax
	xor bx, bx
read_direct_zone:
	pop si				!ѭ����һ��ʱ=linux0.11ӳ���ļ���i�ڵ��ڶ�����1k������,�����INITSEG��ƫ�Ƶ�ַ
	mov ax, I_ZONE0(si)
	add si, #2
	push si
	call read_block_use_zone_num
	dec timers
	cmp timers, #0x00
	jne read_direct_zone
	sub image_nzones, #0x0007

!����,�Ѿ�����7��ֱ�ӿ���,���ڰѺ����4.5k�Ƶ�SYSSEG�ο�ʼ��(��0x10000)
	mov si, #2048+512
	mov ax, #SYSSEG
	mov es, ax
	mov ax, #BOOTSECTSEG
	mov ds, ax
	xor di, di
	mov cx, #4*1024+512
	rep
	movsb	!Move byte at address DS:SI to address ES:DI

					!*********************************************************************
					!	��һ�μ�ӿ�ָ�����̿�
					!*********************************************************************

!��"һ�μ�ӿ�"(���һ�����ŵ��̿�)

	mov bx, #INITSEG
	mov es, bx
	mov ds, bx
	mov bx, #SECTOR_BUF_OFT

	pop si
	mov ax, I_ZONE0(si)		!ax=i_zone[7]
	call read_block_use_zone_num	!����һ�μ�ӿ�

!����һ�μ�ӿ�ָ�����̿�
	push #0x0000
	mov ax, #SYSSEG+0x120	!0xa0=4.5*1024/16
	mov es, ax
	xor bx, bx
read_first_level_zone:
	pop si
	mov ax, SECTOR_BUF_OFT(si)
	add si, #2
	push si
	call read_block_use_zone_num
	dec image_nzones
	cmp image_nzones, #0x0000
	jne read_first_level_zone

					!****************************************************************
					!	bootsect.s����"call kill_motor"֮ǰ��ɵĹ��ܾ��ǰ�ӳ����
					!�������ڴ��к��ʵ�λ��,ֻ�������Ǵ����̶������.������ROOT_DEV
					!�ĳ�����ڴ�Ӳ������ûʲô�ô���ֱ������setup.s������
					!****************************************************************
	jmpi 0, SETUPSEG	!����setup.s����ִ��

!����Minix�̿��(����ax��)��ȡ��������(1k bytes)��ES:BX��ʼ���ڴ洦.
!����̿��Ϊ0,��ES:BX��ʼ����1k bytes��0
!������ES:BXָ����һλ��(ע��BX���ܳ���0xffff)
read_block_use_zone_num:
	cmp ax, #0x0000
	jne notzero_zone
	mov cx, #1024
	mov di, bx
	rep
	stosb		!Store AL at address ES:DI
	j recal_es_bx
notzero_zone:
	shl ax, #1
	add ax, start_sect
	mov abs_sector, ax
	mov abs_sector+2, #0x00	!���ڼ�������̿�Ų�����2^16��,���Ҫ���Ͻ��Ļ�,ǰ����λ����Ӷ�Ҫ�ж��Ƿ����
	call read_block
recal_es_bx:
	cmp bx, #0xfc00		!���BX=0xfc00,���ϱ��ζ�ȡ��1k�ֽ�,��BX������64k������,�����޸�ES:BX
	jne add1024
	mov ax, es
	add ax, #0x1000
	mov es, ax
	xor bx, bx
	j return
add1024:
	add bx, #1024
return:
	ret


!��ȡһ���̿�(1k bytes)��ES:BX��ַ��,����Ϊabs_sector
read_block:
	call calculate_chs
	mov ax, #0x0202		!���ܺ�ah=0x02----������,al=0x02----��ȡ2������
	mov dl, #0x80		!��һ��Ӳ��
	int 0x13		!***********************************************************************
				!	INT 13 - DISK - READ SECTORS INTO MEMORY
				!	AH = 02h
				!	AL = number of sectors to read
				!	CH = track (for hard disk, bits 8,9 in high bits of CL)
				!	CL = sector
				!	DH = head
				!	DL = drive (for hard disk bit 7 is 1)
				!	ES:BX = address of buffer to fill
				!	Return: CF = set if error occurred
				!	AH = status (0 if successful)
				!	AL = number of sectors read
   				!************************************************************************
	cmp ah, #0
	jne read_block		!���ɹ�������

	ret


!���ݾ���������(����abs_sector,��0��ʼ)���������(CH),��ͷ(DH),����(CL);
calculate_chs:
	mov dx, abs_sector+2
	mov ax, abs_sector
	mov di, nspt
	div di
	mov cx, dx
	add cx, #1		!sector=(abs_sector%nspt)+1
				!ax=abs_sector/nspt
	xor dx, dx
	mov di, nhead
	div di			!head=dx=track%nhead, cyl=ax=track/nhead

	mov dh, dl		!DH=��ͷ
	mov ch, al		!CH=�����
	ret

!��ͷ��
nhead:
	.word 16

!ÿ�ŵ�������
nspt:
	.word 63

!linux0.11ӳ�����·��
image_name:
	.ascii "Image"

msg:
	.byte 13,10
	.ascii "MBR loading the image from Hard disk..."
	.byte 13,10,13,10

!��һ��������ʼ������
.org 0x1c6
start_sect:
	.word 0x0001

.org 500
!linux0.11ӳ���̿���
image_nzones:
	.word 0x0000

!i�ڵ���ʼ�̿��
inode_start_zone:
	.word	0x0000

!��һ�����ݿ���̿��
firstdatazone:
	.word 0x0000

!����������(��0��ʼ���)
abs_sector:
	.word	0x0000
	.word   0x0000

.org 510
!�м����
timers:
	.byte 0x55
	.byte 0xaa


.text
endtext:
.data
enddata:
.bss
endbss: