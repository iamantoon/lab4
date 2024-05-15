.include "defs.h"

.section .bss
fd:     .quad 0
len:    .quad 0
ptr:    .quad 0
argc:   .quad 0
arg1:   .quad 0

.section .text
.global _start

_start:
    movq    (%rsp), %rbx       
    movq    %rbx, argc
    leaq    16(%rsp), %rcx     
    movq    %rcx, arg1

    cmpq    $2, argc
    jne     exit                

    call    open_file
    call    get_file_size
    call    memory_map
    call    write_to_stdout

    call    unmap_memory
    call    close_file

exit:
    movq    $SYS_EXIT, %rax
    movq    $0, %rdi
    syscall

open_file:
    movq    $SYS_OPEN, %rax
    movq    arg1, %rcx
    movq    (%rcx), %rdi
    movq    $O_RDONLY, %rsi
    movq    $0, %rdx
    syscall
    movq    %rax, fd
    ret

get_file_size:
    movq    $SYS_LSEEK, %rax
    movq    fd, %rdi
    movq    $SEEK_END, %rdx
    movq    $0, %rsi
    syscall
    movq    %rax, len
    ret

memory_map:
    movq    $SYS_MMAP, %rax
    movq    $0, %rdi
    movq    len, %rsi
    movq    $PROT_READ, %rdx
    movq    $MAP_SHARED, %r10
    movq    fd, %r8
    movq    $0, %r9
    syscall
    movq    %rax, ptr
    ret

write_to_stdout:
    movq    $SYS_WRITE, %rax
    movq    $STDOUT, %rdi
    movq    ptr, %rsi
    movq    len, %rdx
    syscall
    ret

unmap_memory:
    movq    $SYS_MUNMAP, %rax
    movq    ptr, %rdi
    movq    len, %rsi
    syscall
    ret

close_file:
    movq    $SYS_CLOSE, %rax
    movq    fd, %rdi
    syscall
    ret
