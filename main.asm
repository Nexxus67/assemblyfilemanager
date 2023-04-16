; This program is a simple file manager that allows the user to navigate through
; directories, create and delete files and folders, and copy and move files.

section .data
    prompt db "> "
    cwd db "/"

section .bss
    buffer resb 256

section .text
    global _start

_start:
    ; Display the prompt and get user input
    mov edx, prompt
    mov ecx, edx
    mov ebx, 1
    mov eax, 4
    int 0x80 ; Display prompt

    mov eax, 3 ; Read user input
    mov ebx, 0 ; Read from standard input
    mov ecx, buffer
    mov edx, 256
    int 0x80

    ; Parse user input
    mov ebx, buffer
    mov ecx, buffer
    mov al, [ebx]
    cmp al, '/'
    jne parse_cmd
    inc ebx
    mov edx, ebx
    mov al, '/'
    jmp print_dir

parse_cmd:
    mov edx, buffer
    mov al, '/'
    mov [edx], al

    ; Parse command
    mov ecx, edx
    mov ebx, buffer
    mov al, [ebx]
    cmp al, 'c'
    je create_file
    cmp al, 'd'
    je create_dir
    cmp al, 'r'
    je remove_file
    cmp al, 'm'
    je move_file
    cmp al, 'p'
    je print_dir
    jmp error

create_file:
    inc ecx
    mov ebx, ecx
    mov edx, "Enter file name: "
    mov eax, 4 ; Display prompt
    int 0x80

    ; Read file name
    mov eax, 3 ; Read user input
    mov ebx, 0 ; Read from standard input
    add ecx, 2
    mov edx, ecx
    mov ecx, buffer
    sub edx, ecx
    int 0x80

    ; Create file
    mov eax, 8 ; Open file
    mov ebx, buffer
    mov ecx, 0o666 ; Permissions
    int 0x80
    mov edx, eax

    mov eax, 4 ; Display message
    mov ebx, 1 ; Standard output
    mov ecx, "File created successfully"
    int 0x80

    jmp _start

create_dir:
    inc ecx
    mov ebx, ecx
    mov edx, "Enter directory name: "
    mov eax, 4 ; Display prompt
    int 0x80

    ; Read directory name
    mov eax, 3 ; Read user input
    mov ebx, 0 ; Read from standard input
    add ecx, 2
    mov edx, ecx
    mov ecx, buffer
    sub edx, ecx
    int 0x80

    ; Create directory
    mov eax, 39 ; Create directory
    mov ebx, buffer
    mov ecx, 0o777 ; Permissions
    int 0x80

    mov eax, 4 ; Display message
    mov ebx, 1 ; Standard output
    mov ecx, "Directory created successfully"
    int 0x80

    jmp _start

remove_file:
    inc ecx
    mov ebx, ecx
    mov edx, "Enter file name: "
    mov eax, 4 ; Display prompt
    int 0x80

    ; Read file name
    mov eax, 3 ; Read user

move_file:
    ; Ask user for source and destination paths
    mov ah, 0x09
    mov dx, move_file_src_prompt
    int 0x21
    mov ah, 0x0a
    mov dx, file_input_buffer
    int 0x21
    mov si, file_input_buffer
    mov ah, 0x09
    mov dx, move_file_dest_prompt
    int 0x21
    mov ah, 0x0a
    mov dx, file_input_buffer
    int 0x21
    mov di, file_input_buffer
    
    ; Move the file
    mov ah, 0x3d ; Open file
    mov al, 0x00 ; Read-only mode
    mov dx, si ; Source path
    int 0x21
    mov bx, ax ; Save file handle
    mov ah, 0x3c ; Create or open file
    mov al, 0x01 ; Write-only mode
    mov dx, di ; Destination path
    int 0x21
    mov cx, 0x4000 ; Copy buffer size
.copy_file_loop:
    mov ah, 0x3f ; Read from file
    mov bx, ax ; Set file handle
    mov dx, copy_buffer
    mov cx, 0x4000 ; Copy buffer size
    int 0x21
    or ax, ax ; Check if end of file
    jz copy_file_end
    mov ah, 0x40 ; Write to file
    mov bx, ax ; Set file handle
    mov dx, copy_buffer
    int 0x21
    jmp .copy_file_loop
copy_file_end:
    mov ah, 0x3e ; Close file
    mov bx, ax ; Set file handle
    int 0x21
    mov ah, 0x3e ; Close file
    mov bx, bx ; Set file handle
    int 0x21
    mov ah, 0x09 ; Print success message
    mov dx, move_file_success
    int 0x21
    jmp main_loop
    
exit_program:
    ; Exit program
    mov ah, 0x4c
    xor al, al
    int 0x21
