@rem	this script will compile the kernel without any make facility
@rem	it is a work in progres....
@rem	fix \aoutgcc to the root where this is
@rem	in GCC the -B flag doesn't really work correctly
@rem 	
@rem
@cls
@set opath=%PATH%
@set PATH=\aoutgcc\bin;%PATH%
@echo Building the Linux 0.11 kernel
@..\..\bin\as86 -0 -a -o boot/bootsect.o boot/bootsect.s 2>%TEMP%\stderr.txt
@..\..\bin\ld86 -0 -s -o boot/bootsect boot/bootsect.o 2>%TEMP%\stderr.txt
@..\..\bin\as86 -0 -a -o boot/setup.o boot/setup.s 2>%TEMP%\stderr.txt
@..\..\bin\ld86 -0 -s -o boot/setup boot/setup.o 2>%TEMP%\stderr.txt
@..\..\bin\a386 -c -o boot/head.o boot/head.s 2>%TEMP%\stderr.txt
@..\..\bin\gcc -B ..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -nostdinc -Iinclude -c -o init/main.o init/main.c 2>%TEMP%\stderr.txt


@cd kernel
@echo Compiling kernel
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include	-c -o sched.o sched.c 2>%TEMP%\stderr.txt
@..\..\..\bin\a386 -c -o system_call.o system_call.s 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o traps.o traps.c 2>%TEMP%\stderr.txt
@..\..\..\bin\a386 -c -o asm.o asm.s 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o fork.o fork.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o panic.o panic.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o printk.o printk.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o vsprintf.o vsprintf.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o sys.o sys.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o exit.o exit.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o signal.o signal.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o mktime.o mktime.c 2>%TEMP%\stderr.txt
@..\..\..\bin\ld -r -o kernel.o sched.o system_call.o traps.o asm.o fork.o panic.o printk.o vsprintf.o sys.o exit.o signal.o mktime.o 2>%TEMP%\stderr.txt
@cd ..

@cd mm
@echo Compiling memory management
@..\..\..\bin\gcc -B ..\..\..\bin -O -Wall -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -finline-functions -nostdinc -I../include -c -o memory.o memory.c 2>%TEMP%\stderr.txt
@..\..\..\bin\a386 -o page.o page.s 2>%TEMP%\stderr.txt
@..\..\..\bin\ld -r -o mm.o memory.o page.o 2>%TEMP%\stderr.txt
@cd..

@cd fs
@echo Compiling filesystem
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o open.o open.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o read_write.o read_write.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o inode.o inode.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o file_table.o file_table.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o buffer.o buffer.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o super.o super.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o block_dev.o block_dev.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o char_dev.o char_dev.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o file_dev.o file_dev.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o stat.o stat.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o exec.o exec.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o pipe.o pipe.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o namei.o namei.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o bitmap.o bitmap.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o fcntl.o fcntl.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o ioctl.o ioctl.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o truncate.o truncate.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fcombine-regs -fomit-frame-pointer -nostdinc -I../include -c -o select.o select.c 2>%TEMP%\stderr.txt
@..\..\..\bin\ld -r -o fs.o open.o read_write.o inode.o file_table.o buffer.o super.o block_dev.o char_dev.o file_dev.o stat.o exec.o pipe.o namei.o bitmap.o fcntl.o ioctl.o truncate.o select.o 2>%TEMP%\stderr.txt
@cd ..

@cd kernel\blk_drv
@echo Compiling block devices
@..\..\..\..\bin\gcc -B ..\..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions  -nostdinc -I../../include -c -o ll_rw_blk.o ll_rw_blk.c 2>%TEMP%\stderr.txt
@..\..\..\..\bin\gcc -B ..\..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions  -nostdinc -I../../include -c -o floppy.o floppy.c 2>%TEMP%\stderr.txt
@..\..\..\..\bin\gcc -B ..\..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions  -nostdinc -I../../include -c -o hd.o hd.c 2>%TEMP%\stderr.txt
@..\..\..\..\bin\gcc -B ..\..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions  -nostdinc -I../../include -c -o ramdisk.o ramdisk.c 2>%TEMP%\stderr.txt
@..\..\..\..\bin\ar rcs blk_drv.a ll_rw_blk.o floppy.o hd.o ramdisk.o 2>%TEMP%\stderr.txt

@cd ..\chr_drv
@echo Compiling char devices
@..\..\..\..\bin\gcc -B ..\..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../../include -c -o tty_io.o tty_io.c 2>%TEMP%\stderr.txt
@..\..\..\..\bin\gcc -B ..\..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../../include -c -o console.o console.c 2>%TEMP%\stderr.txt
@..\..\..\..\bin\gcc -B ..\..\..\..\bin -E -nostdinc -I../../include -traditional keyb.S -o keyboard.s 2>%TEMP%\stderr.txt
@..\..\..\..\bin\a386 -c -o keyboard.o keyboard.s 2>%TEMP%\stderr.txt
@..\..\..\..\bin\gcc -B ..\..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../../include -c -o serial.o serial.c 2>%TEMP%\stderr.txt
@..\..\..\..\bin\a386 -c -o rs_io.o rs_io.s 2>%TEMP%\stderr.txt
@..\..\..\..\bin\gcc -B ..\..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../../include -c -o tty_ioctl.o tty_ioctl.c 2>%TEMP%\stderr.txt
@..\..\..\..\bin\ar rcs chr_drv.a tty_io.o console.o keyboard.o serial.o rs_io.o tty_ioctl.o 2>%TEMP%\stderr.txt

@cd ..\math
@echo Compiling floating point math
@..\..\..\..\bin\gcc -B ..\..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../../include -c -o math_emulate.o math_emulate.c 2>%TEMP%\stderr.txt
@..\..\..\..\bin\ar rcs math.a math_emulate.o 2>%TEMP%\stderr.txt

@cd ..\..\lib
@echo Compiling kernel library
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o ctype.o ctype.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o _exit.o _exit.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o open.o open.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o close.o close.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o errno.o errno.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o write.o write.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o dup.o dup.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o setsid.o setsid.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o execve.o execve.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o wait.o wait.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o string.o string.c 2>%TEMP%\stderr.txt
@..\..\..\bin\gcc -B ..\..\..\bin -Wall -O -g -fstrength-reduce -fomit-frame-pointer -fcombine-regs -finline-functions -nostdinc -I../include -c -o malloc.o malloc.c 2>%TEMP%\stderr.txt
@..\..\..\bin\ar rcs lib.a ctype.o _exit.o open.o close.o errno.o write.o dup.o setsid.o execve.o wait.o string.o malloc.o 2>%TEMP%\stderr.txt
@cd ..

@echo Linking the kernel
@..\..\bin\ld -x -M   boot/head.o init/main.o kernel/kernel.o mm/mm.o fs/fs.o kernel/blk_drv/blk_drv.a kernel/chr_drv/chr_drv.a kernel/math/math.a lib/lib.a -o tools/system > System.map

@echo purging objects
@del /F boot\head.o init\main.o kernel\kernel.o mm\mm.o fs\fs.o kernel\blk_drv\blk_drv.a kernel\chr_drv\chr_drv.a kernel\math\math.a lib\lib.a
@del /F boot\*.o 
@del /F kernel\*.o
@del /F mm\*.o
@del /F fs\*.o
@del /F kernel\blk_drv\*.o
@del /F kernel\chr_drv\*.o
@del /F kernel\math\*.o
@del /F lib\*.o

@copy /Y tools\system system.tmp >%TEMP%\stderr.txt
@echo Kernel size:
@..\..\bin\size system.tmp
@..\..\bin\strip system.tmp >%TEMP%\stderr.txt
@tools\build boot\bootsect boot\setup system.tmp  > Image
@del /F system.tmp 2>%TEMP%\stderr.txt
@del /F %TEMP%\stderr.txt
@set PATH=%OPATH%
@set OPATH=