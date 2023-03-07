; hello_mmap.asm
%define O_RDONLY 0 
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2

%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_MMAP 9
%define SYS_MUNMAP 11

%define FD_STDOUT 1



section .data
    fname: db 'hello.txt', 0

section .text
global _start

exit:
    mov  rax, 60
    xor  rdi, rdi
    syscall

print_string:
    push rdi
    call string_length
    pop  rsi
    mov  rdx, rax 
    mov  rax, SYS_WRITE
    mov  rdi, FD_STDOUT
    syscall
    ret

string_length:
    xor  rax, rax
.loop:
    cmp  byte [rdi+rax], 0
    je   .end 
    inc  rax
    jmp .loop 
.end:
    ret


print_substring:
    mov  rdx, rsi 
    mov  rsi, rdi
    mov  rax, SYS_WRITE
    mov  rdi, FD_STDOUT
    syscall
    ret

_start:
	push r12
	push r13

    mov  rax, SYS_OPEN
    mov  rdi, fname
    mov  rsi, O_RDONLY    ; Open file read only
    mov  rdx, 0 	  ; We are not creating a file
                          ; so this argument has no meaning
    syscall
	
	mov r12, rax			;save fd

	mov rdi, 0				;addr
	mov rsi, 0x1000			;length
	mov rdx, PROT_READ		;prot
	mov r10, MAP_PRIVATE	;flags
	mov r8, rax				;fd
	mov r9, 0				;offset
	mov rax, SYS_MMAP		;syscall MMAP
	syscall

	mov r13, rax			;save addr	

	mov rdi, rax			;addr	
	call print_string
	
	mov rdi, r13			;addr
	mov rsi, 0x1000			;length
	mov rax, SYS_MUNMAP		;syscall MUNMAP
	syscall
	
	mov rdi, r12			;fd
	mov rax, SYS_CLOSE		;syscall CLOSE
	syscall

	pop r13
	pop r12

    call exit
