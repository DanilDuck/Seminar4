; hello_mmap.asm
%define O_RDONLY 0 
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2

%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_FSTAT 5
%define SYS_MMAP 9
%define SYS_MUNMAP 11

%define FD_STDOUT 1



section .data
    ; This is the file name. You are free to change it.
    fname: db 'hello.txt', 0

section .text

global print_file
global print_string

; use exit system call to shut down correctly
exit:
    mov  rax, 60
    xor  rdi, rdi
    syscall

; These functions are used to print a null terminated string
; rdi holds a string pointer
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

; This function is used to print a substring with given length
; rdi holds a string pointer
; rsi holds a substring length
print_substring:
    mov  rdx, rsi 
    mov  rsi, rdi
    mov  rax, SYS_WRITE
    mov  rdi, FD_STDOUT
    syscall
    ret

print_file:
	;rdi - название файла
	push r12	;fd
	push r13	;buf
	push r14	;addr

;open
    mov  rax, SYS_OPEN
    mov  rsi, O_RDONLY    
    mov  rdx, 0 	                  
    syscall
	
;save
	mov r12, rax			;save fd
	sub rsp, 144			;reserve stack
	mov r13, rsp			;save buffer

;fstat
	mov rdi, r12			;fd
	mov rsi, r13			;buffer
    mov rax, SYS_FSTAT		;syscall FSTAT
    syscall

;mmap
	mov rdi, 0				;addr
	mov rsi, [r13+48]		;length
	mov rdx, PROT_READ		;prot
	mov r10, MAP_PRIVATE	;flags
	mov r8, r12				;fd
	mov r9, 0				;offset
	mov rax, SYS_MMAP		;syscall MMAP
	syscall
	
	mov r14, rax			;save addr

;substring
	mov rdi, r14			;addr
	mov rsi, [r13+48]		;length
	call print_substring

;munmap
	mov rdi, r14			;addr
	mov rsi, [r13+48]		;length
	mov rax, SYS_MUNMAP		;syscall MUNMAP
	syscall

;close
	mov rdi, r12			;fd
	mov rax, SYS_CLOSE		;syscall CLOSE
	syscall

	add rsp, 144
	pop r14
	pop r13
	pop r12

    call exit
