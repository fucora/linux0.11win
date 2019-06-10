!********************************************************************************************************
!	本程序放在硬盘MBR中,用于把linux0.11映像Image读入内存(把bootsect.s读入0x90000开始处,把setup.s读入
!0x90200开始处,把head.s和sys模块读入0x10000开始处),然后跳到原来bootsect.s的110行"call kill_motor"继续执行.
!目的是实现直接从硬盘启动linux0.11.
!	作者: fastwork	email: fastwork@sina.com	日期: 2005.4.1
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

!分区表信息偏移地址
FIRST_PARTITION_OFT	= 0x01be
START_SECT_OFT		= 0x08+FIRST_PARTITION_OFT

!超级块信息偏移地址
S_NINODES	= 0x00
S_NZONES	= 0x02
S_IMAP_BLOCKS	= 0x04
S_ZMAP_BLOCKS	= 0x06
S_FIRSTDATAZONE	= 0x08
S_LOG_ZONE_SIZE	= 0x0a
S_MAX_SIZE	= 0x0c
S_MAGIC		= 0x10

!i节点信息偏移地址
I_MODE		= 0x00
I_UID		= 0x02
I_SIZE		= 0x04
I_MTIME		= 0x08
I_GID		= 0x0c
I_NLINKS	= 0x0d
I_ZONE0		= 0x0e

!硬盘参数偏移地址
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
HD_INFO_PTR_OFT	= 4*0x41		!第一个硬盘参数表的段地址和偏移地址在BIOS中断0x41向量开始的4个字节上
NCYL_OFT	= 0x00			!柱面数
NHEAD_OFT	= 0x02			!磁头数
WPCON_OFT	= 0x05			!写前预补偿柱面号
CTL_OFT		= 0x08			!控制字节
LZONE_OFT	= 0x0c			!磁头着陆区柱面号
SPT_OFT		= 0x0e			!每磁道扇区数

!用以暂时存放一个扇区数据
SECTOR_BUF_OFT	= 1024

entry start
start:
	xor ax, ax
	mov ds, ax
	lds si, [HD_INFO_PTR_OFT]
	mov ah, NHEAD_OFT(si)	!读取磁头数
	mov al, SPT_OFT(si)	!读取每磁道扇区数

        mov bx, #INITSEG
	mov ds, bx
	mov ss, bx
	mov es, bx
	mov sp, #0x0300

	mov nhead, ah		!保存磁头数
	mov nspt, al		!保存每磁道扇区数

	mov ah, #0x03
	xor bh,bh
	int 0x10		!读光标位置,DH,DL=行,列
	mov bx, #0x0007 	!设置显示属性
	mov bp, #msg
	mov cx, #45
	mov ax, #0x1301
	int 0x10		!显示字符串"MBR loading the image from Hard disk..."


!读取超级块
	mov bx, #SECTOR_BUF_OFT
	mov ax, #0x01
	call read_block_use_zone_num

	mov ax, SECTOR_BUF_OFT+S_IMAP_BLOCKS
	add ax, SECTOR_BUF_OFT+S_ZMAP_BLOCKS
	add ax, #2
	mov inode_start_zone, ax		!存放i节点的起始盘块号

	mov ax, SECTOR_BUF_OFT+S_FIRSTDATAZONE
	mov firstdatazone, ax			!数据区起始盘块号

!读根i节点第一个盘块,即firstdatazone
	!mov ax, #INITSEG		!仔细看了看上文,发现es还是INITSEG,为省空间把这两句去掉
	!mov es, ax			!其实保留的话可能对阅读程序有点帮助吧
	mov bx, #SECTOR_BUF_OFT
	mov ax, firstdatazone
	call read_block_use_zone_num


				!****************************************************************************
				!	根据image_name在根i节点的第一个盘块查找目录项(所以内核映像只能放在根
				!目录下,并且必须在前面64项,有待改进)
				!一个盘块可以存放64个struct dir_entry{ unsigned short inode; char name[14]; }
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
 	mov ax, (bx)		!获得linux0.11映像的i节点号(以1开始)

!**************************************************************************************************************
!	下面开始读出linux0.11映像文件:前2.5k bytes放在地址0x90000开始处(bootsect.s为512bytes,setup.s为2k bytes),
!剩下的放在地址0x10000开始处
!	Minix一个盘块为1k bytes,上面的0.5k使得处理稍微麻烦一点,我把开始的7k都读到0x90000开始处,然后把这2.5k后面的
!4.5k数据移到0x10000开始处
!	我假设映像文件用不到二级块,毕竟是在玩linux0.11,它也确实没那么大
!**************************************************************************************************************
!读取linux0.11映像的i节点

	dec ax
	xor dx, dx
	mov bx, #32			!一个盘块能存放32个i节点
	div bx				!ax=(dx*2^16+ax)/bx, dx=(dx*2^16+ax)%bx
	push dx				!是所在盘块的第几个i节点?(0表示第一个)
	add ax, inode_start_zone

	!mov bx, #INITSEG		!仔细看了看上文,发现es还是INITSEG,为省空间把这两句去掉
	!mov es, bx			!其实保留的话可能对阅读程序有点帮助吧
	mov bx, #SECTOR_BUF_OFT
	call read_block_use_zone_num	!读出i节点块
	pop bx				!bx=(linux0.11映像文件的i节点号-1) mod 32
	shl bx, #5			!此时bx是linux0.11映像文件的i节点在读出的1k数据中的偏移地址
	add bx, #SECTOR_BUF_OFT		!bx=映像文件i节点相对于INITSEG段的偏移地址
	push bx				!保存
	mov ax, (bx+I_SIZE)		!ax存放linux0.11映像"文件大小"的低2字节
	mov dx, (bx+I_SIZE+2)		!dx存放linux0.11映像"文件大小"的高2字节
	mov cx, #1024
	div cx
	cmp dx, #0x0000			!以下开始计算linux0.11映像文件占用的盘块数
	je set_image_nzones
	inc ax
set_image_nzones:
	mov image_nzones, ax		!保存linux0.11映像文件占用的盘块数

					!*********************************************************************
					!	读直接块
					!*********************************************************************

!如前说明,先读出所有7个直接块,放在0x90000开始处
	mov timers, #0x07
	mov ax, #BOOTSECTSEG
	mov es, ax
	xor bx, bx
read_direct_zone:
	pop si				!循环第一次时=linux0.11映像文件的i节点在读出的1k数据中,相对于INITSEG的偏移地址
	mov ax, I_ZONE0(si)
	add si, #2
	push si
	call read_block_use_zone_num
	dec timers
	cmp timers, #0x00
	jne read_direct_zone
	sub image_nzones, #0x0007

!好了,已经读出7个直接块了,现在把后面的4.5k移到SYSSEG段开始处(即0x10000)
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
					!	读一次间接块指定的盘块
					!*********************************************************************

!读"一次间接块"(存放一级块块号的盘块)

	mov bx, #INITSEG
	mov es, bx
	mov ds, bx
	mov bx, #SECTOR_BUF_OFT

	pop si
	mov ax, I_ZONE0(si)		!ax=i_zone[7]
	call read_block_use_zone_num	!读出一次间接块

!读读一次间接块指定的盘块
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
					!	bootsect.s中在"call kill_motor"之前完成的功能就是把映像文
					!件读入内存中合适的位置,只不过它是从软盘读入罢了.后面检查ROOT_DEV
					!的程序对于从硬盘启动没什么用处。直接跳到setup.s就行了
					!****************************************************************
	jmpi 0, SETUPSEG	!跳到setup.s继续执行

!根据Minix盘块号(放在ax中)读取两个扇区(1k bytes)到ES:BX开始的内存处.
!如果盘块号为0,则将ES:BX开始处的1k bytes清0
!最后调整ES:BX指向下一位置(注意BX不能超过0xffff)
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
	mov abs_sector+2, #0x00	!现在假设绝对盘块号不超过2^16吧,如果要更严谨的话,前面移位和相加都要判断是否溢出
	call read_block
recal_es_bx:
	cmp bx, #0xfc00		!如果BX=0xfc00,加上本次读取的1k字节,则BX将等于64k的上限,必须修改ES:BX
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


!读取一个盘块(1k bytes)到ES:BX地址处,参数为abs_sector
read_block:
	call calculate_chs
	mov ax, #0x0202		!功能号ah=0x02----读磁盘,al=0x02----读取2个扇区
	mov dl, #0x80		!第一个硬盘
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
	jne read_block		!不成功则重试

	ret


!根据绝对扇区号(存在abs_sector,以0开始)计算柱面号(CH),磁头(DH),扇区(CL);
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

	mov dh, dl		!DH=磁头
	mov ch, al		!CH=柱面号
	ret

!磁头数
nhead:
	.word 16

!每磁道扇区数
nspt:
	.word 63

!linux0.11映像绝对路径
image_name:
	.ascii "Image"

msg:
	.byte 13,10
	.ascii "MBR loading the image from Hard disk..."
	.byte 13,10,13,10

!第一个分区开始的扇区
.org 0x1c6
start_sect:
	.word 0x0001

.org 500
!linux0.11映像盘块数
image_nzones:
	.word 0x0000

!i节点起始盘块号
inode_start_zone:
	.word	0x0000

!第一个数据块的盘块号
firstdatazone:
	.word 0x0000

!绝对扇区号(以0开始编号)
abs_sector:
	.word	0x0000
	.word   0x0000

.org 510
!中间变量
timers:
	.byte 0x55
	.byte 0xaa


.text
endtext:
.data
enddata:
.bss
endbss: