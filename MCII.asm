; =====================================================================
; MCII - MarkOs Compiler II  v0.2  (Pure x86_64 Assembly)
; MKU kaynagini x86_64 assembly'ye derler.
; MarkOS Ecosystem (c) 2026 - memetcanwq31-ship-it
; Build : nasm -f elf64 mcii.asm -o mcii.o && ld mcii.o -o mcii
; Usage : ./mcii program.mku program.asm
;         nasm -f elf64 program.asm -o program.o && ld program.o -o program
; Subset: print "metin" / print expr / let x = expr / + - * / % ( )
; =====================================================================

section .data
w_print:    db "print",0
w_let:      db "let",0

; --- kod sablonlari ---
t_nl:       db 10,0
t_pushrax:  db "    push rax",10,0
t_poprax:   db "    pop rax",10,0
t_movrbx:   db "    mov rbx, rax",10,0
t_imul:     db "    imul rax, rbx",10,0
t_cqo:      db "    cqo",10,0
t_idiv:     db "    idiv rbx",10,0
t_mod:      db "    mov rax, rdx",10,0
t_add:      db "    add rax, rbx",10,0
t_sub:      db "    sub rax, rbx",10,0
t_callpn:   db "    call print_num",10,0
t_movrax:   db "    mov rax, ",0
t_movraxv:  db "    mov rax, [v_",0
t_vclose:   db "]",10,0
t_store:    db "    mov [v_",0
t_store2:   db "], rax",10,0

; --- string data sablonlari ---
d_indent:   db "    s",0
d_dbq:      db ": db \"",0
d_qnl:      db "\",10",10,"    s",0
d_lenequ:   db "_len equ $ - s",0
d_nlchar:   db "    nlchar: db 10",10,0

; --- string print kodu ---
c_sysw1:    db "    mov rax, 1",10,"    mov rdi, 1",10,"    lea rsi, [s",0
c_sysw2:    db "]",10,"    mov rdx, s",0
c_sysw3:    db "_len",10,"    syscall",10,0

; --- cikti dosyasi parcalari ---
f_secdata:  db "section .data",10,0
f_text:     db "section .text",10,"global _start",10,"_start:",10,0
f_exit:     db "    mov rax, 60",10,"    xor rdi, rdi",10,"    syscall",10,0
f_secsbss:  db "section .bss",10,0
f_bssvar1:  db "    v_",0
f_bssvar2:  db ": dq 0",10,0

; --- print_num rutini (uretilen programa eklenir) ---
pn_text:
db "print_num:",10
db "    push rbx",10
db "    sub rsp, 32",10
db "    lea rbx, [rsp+31]",10
db "    mov byte [rbx], 10",10
db "    mov r9, rbx",10
db ".pdiv:",10
db "    xor rdx, rdx",10
db "    mov r10, 10",10
db "    div r10",10
db "    add dl, 48",10
db "    dec rbx",10
db "    mov [rbx], dl",10
db "    test rax, rax",10
db "    jnz .pdiv",10
db "    mov rax, 1",10
db "    mov rdi, 1",10
db "    mov rsi, rbx",10
db "    mov rdx, r9",10
db "    sub rdx, rbx",10
db "    inc rdx",10
db "    syscall",10
db "    add rsp, 32",10
db "    pop rbx",10
db "    ret",10,0

; --- hata mesajlari ---
m_usage:    db "usage: ./mcii input.mku output.asm",10,0
m_open:     db "MCII: cannot open input file",10,0
m_out:      db "MCII: cannot open output file",10,0
m_stmt:     db "MCII: unknown statement",10,0
m_eq:       db "MCII: expected '='",10,0
m_undef:    db "MCII: undefined variable",10,0
m_paren:    db "MCII: expected ')'",10,0
m_readerr:  db "MCII: read error",10,0

section .bss
srcbuf:     resb 131072
outbuf:     resb 524288
datasec:    resb 131072
tokbuf:     resb 128
nbuf:       resb 32
scratch:    resb 256
varlist:    resb 4096           ; 128 degisken x 32 bayt

section .text
global _start

; ---------------------------------------------------------------
; emit: rsi = zero-terminated string -> [rdi]'ye kopyalar, rdi ilerler
; rsi'yi korur, sonuna 0 yazar (buffer her zaman z-terminated)
; ---------------------------------------------------------------
emit:
    push rsi
    push rax
.l: lodsb
    mov [rdi], al
    inc rdi
    test al, al
    jnz .l
    pop rax
    pop rsi
    ret

; ---------------------------------------------------------------
; emit_num: rax -> ondalik metin olarak [rdi]'ye yazar
; ---------------------------------------------------------------
emit_num:
    push rbx
    push rdx
    push rsi
    lea rbx, [nbuf+23]
    mov byte [rbx], 0
.pn: xor rdx, rdx
    mov r10, 10
    div r10
    add dl, 48
    dec rbx
    mov [rbx], dl
    test rax, rax
    jnz .pn
    mov rsi, rbx
    call emit
    pop rsi
    pop rdx
    pop rbx
    ret

; ---------------------------------------------------------------
; streq: rsi, rbx = iki zstring -> rax = 1/0
; ---------------------------------------------------------------
streq:
    push rsi
    push rbx
    push rax
.c: mov al, [rsi]
    mov ah, [rbx]
    cmp al, ah
    jne .no
    test al, al
    jz .yes
    inc rsi
    inc rbx
    jmp .c
.yes: pop rax
    pop rbx
    pop rsi
    mov rax, 1
    ret
.no: pop rax
    pop rbx
    pop rsi
    xor rax, rax
    ret

; ---------------------------------------------------------------
; skip_ws: rbp (kaynak imleci) bosluk/yorum atlattirir
; ---------------------------------------------------------------
skip_ws:
.l: movzx eax, byte [rbp]
    cmp al, ' '
    je .adv
    cmp al, 9
    je .adv
    cmp al, 10
    je .adv
    cmp al, 13
    je .adv
    cmp al, '#'
    je .com
    ret
.adv: inc rbp
    jmp .l
.com: movzx eax, byte [rbp]
    test al, al
    jz .d
    cmp al, 10
    je .d
    inc rbp
    jmp .com
.d: ret

; ---------------------------------------------------------------
; read_word: [A-Za-z0-9_]* -> tokbuf (rbp ilerler)
; ---------------------------------------------------------------
read_word:
    push rbx
    lea rbx, [tokbuf]
.rw: movzx eax, byte [rbp]
    cmp al, '_'
    je .ok
    cmp al, 0
    je .d
    cmp al, '0'
    jb .d
    cmp al, '9'
    jbe .ok
    cmp al, 'A'
    jb .d
    cmp al, 'Z'
    jbe .ok
    cmp al, 'a'
    jb .d
    cmp al, 'z'
    ja .d
.ok: mov [rbx], al
    inc rbx
    inc rbp
    jmp .rw
.d: mov byte [rbx], 0
    pop rbx
    ret

; ---------------------------------------------------------------
; eq_tok: rsi = kelime, tokbuf ile karsilastirir -> rax = 1/0
; ---------------------------------------------------------------
eq_tok:
    push rbx
    lea rbx, [tokbuf]
    call streq
    pop rbx
    ret

; ---------------------------------------------------------------
; read_number: rbp'den sayi okur -> rax
; ---------------------------------------------------------------
read_number:
    xor rax, rax
.rn: movzx edx, byte [rbp]
    cmp dl, '0'
    jb .d
    cmp dl, '9'
    ja .d
    imul rax, rax, 10
    sub dl, '0'
    add rax, rdx
    inc rbp
    jmp .rn
.d: ret

; ---------------------------------------------------------------
; find_var: tokbuf varlist'te var mi -> rax = 1/0
; ---------------------------------------------------------------
find_var:
    push rbx
    push rsi
    push rcx
    xor rcx, rcx
.fv: cmp rcx, r13
    jae .no
    mov r11, rcx
    imul r11, r11, 32
    lea rsi, [varlist]
    add rsi, r11
    lea rbx, [tokbuf]
    call streq
    test rax, rax
    jnz .yes
    inc rcx
    jmp .fv
.yes: pop rcx
    pop rsi
    pop rbx
    mov rax, 1
    ret
.no: pop rcx
    pop rsi
    pop rbx
    xor rax, rax
    ret

; ---------------------------------------------------------------
; declare_var: tokbuf'u varlist'e ekler (yoksa)
; ---------------------------------------------------------------
declare_var:
    call find_var
    test rax, rax
    jnz .ex
    mov r11, r13
    imul r11, r11, 32
    add r11, varlist
    lea rbx, [tokbuf]
.cp: mov al, [rbx]
    mov [r11], al
    test al, al
    jz .st
    inc rbx
    inc r11
    jmp .cp
.st: inc r13
.ex: ret

; ---------------------------------------------------------------
; fail: rsi = mesaj, stderr'a yazip exit 1
; ---------------------------------------------------------------
fail:
    push rsi
    mov rsi, rsi
    ; yaz
    mov rbx, rsi
    xor rcx, rcx
.fl: mov al, [rbx]
    test al, al
    jz .f2
    inc rcx
    inc rbx
    jmp .fl
.f2: mov rax, 1
    mov rdi, 2
    mov rdx, rcx
    pop rsi
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

; ---------------------------------------------------------------
; gen_factor: sayi / degisken / (expr) -> sonuc rax kodu uretilir
; ---------------------------------------------------------------
gen_factor:
    call skip_ws
    movzx eax, byte [rbp]
    cmp al, '('
    je .paren
    cmp al, '0'
    jb .ident
    cmp al, '9'
    ja .ident
    call read_number
    push rax
    mov rsi, t_movrax
    call emit
    pop rax
    call emit_num
    mov rsi, t_nl
    call emit
    ret
.ident:
    call read_word
    call find_var
    test rax, rax
    jz .undef
    mov rsi, t_movraxv
    call emit
    mov rsi, tokbuf
    call emit
    mov rsi, t_vclose
    call emit
    ret
.paren:
    inc rbp
    call gen_expr
    call skip_ws
    cmp byte [rbp], ')'
    jne .perr
    inc rbp
    ret
.undef:
    mov rsi, m_undef
    jmp fail
.perr:
    mov rsi, m_paren
    jmp fail

; ---------------------------------------------------------------
; gen_term: factor (*|/|%) factor ...
; ---------------------------------------------------------------
gen_term:
    call gen_factor
.l: call skip_ws
    movzx eax, byte [rbp]
    cmp al, '*'
    je .mul
    cmp al, '/'
    je .div
    cmp al, '%'
    je .mod
    ret
.mul: inc rbp
    mov rsi, t_pushrax
    call emit
    call gen_factor
    mov rsi, t_movrbx
    call emit
    mov rsi, t_poprax
    call emit
    mov rsi, t_imul
    call emit
    jmp .l
.div: inc rbp
    mov rsi, t_pushrax
    call emit
    call gen_factor
    mov rsi, t_movrbx
    call emit
    mov rsi, t_poprax
    call emit
    mov rsi, t_cqo
    call emit
    mov rsi, t_idiv
    call emit
    jmp .l
.mod: inc rbp
    mov rsi, t_pushrax
    call emit
    call gen_factor
    mov rsi, t_movrbx
    call emit
    mov rsi, t_poprax
    call emit
    mov rsi, t_cqo
    call emit
    mov rsi, t_idiv
    call emit
    mov rsi, t_mod
    call emit
    jmp .l

; ---------------------------------------------------------------
; gen_expr: term (+|-) term ...
; ---------------------------------------------------------------
gen_expr:
    call gen_term
.l: call skip_ws
    movzx eax, byte [rbp]
    cmp al, '+'
    je .add
    cmp al, '-'
    je .sub
    ret
.add: inc rbp
    mov rsi, t_pushrax
    call emit
    call gen_term
    mov rsi, t_movrbx
    call emit
    mov rsi, t_poprax
    call emit
    mov rsi, t_add
    call emit
    jmp .l
.sub: inc rbp
    mov rsi, t_pushrax
    call emit
    call gen_term
    mov rsi, t_movrbx
    call emit
    mov rsi, t_poprax
    call emit
    mov rsi, t_sub
    call emit
    jmp .l

; ---------------------------------------------------------------
; parse_loop: statement statement ...
; ---------------------------------------------------------------
parse_loop:
    call skip_ws
    cmp byte [rbp], 0
    je .done
    call read_word
    mov rsi, w_print
    call eq_tok
    test rax, rax
    jnz .do_print
    mov rsi, w_let
    call eq_tok
    test rax, rax
    jnz .do_let
    mov rsi, m_stmt
    jmp fail

.do_print:
    call skip_ws
    cmp byte [rbp], '"'
    je .pstr
    call gen_expr
    mov rsi, t_callpn
    call emit
    jmp parse_loop
.pstr:
    inc rbp
    lea rbx, [tokbuf]
.cs: mov al, [rbp]
    cmp al, '"'
    je .ce
    test al, al
    jz .ce
    mov [rbx], al
    inc rbx
    inc rbp
    jmp .cs
.ce: inc rbp
    mov byte [rbx], 0
    ; --- datasec'e string satiri ekle ---
    push rdi
    mov rdi, r14
    mov rsi, d_indent
    call emit
    mov rax, r12
    call emit_num
    mov rsi, d_dbq
    call emit
    mov rsi, tokbuf
    call emit
    mov rsi, d_qnl
    call emit
    mov rax, r12
    call emit_num
    mov rsi, d_lenequ
    call emit
    mov rax, r12
    call emit_num
    mov rsi, t_nl
    call emit
    mov r14, rdi
    pop rdi
    ; --- koda yazma syscall'i uret ---
    mov rsi, c_sysw1
    call emit
    mov rax, r12
    call emit_num
    mov rsi, c_sysw2
    call emit
    mov rax, r12
    call emit_num
    mov rsi, c_sysw3
    call emit
    inc r12
    jmp parse_loop

.do_let:
    call skip_ws
    call read_word
    call skip_ws
    cmp byte [rbp], '='
    jne .eqerr
    inc rbp
    call gen_expr
    call declare_var
    mov rsi, t_store
    call emit
    mov rsi, tokbuf
    call emit
    mov rsi, t_store2
    call emit
    jmp parse_loop
.eqerr:
    mov rsi, m_eq
    jmp fail
.done:
    ret

; ---------------------------------------------------------------
; write_str: rdi = fd, rsi = zstring -> dosyaya yazar
; ---------------------------------------------------------------
write_str:
    push rbx
    push rcx
    mov rbx, rsi
    xor rcx, rcx
.l: mov al, [rbx]
    test al, al
    jz .d
    inc rcx
    inc rbx
    jmp .l
.d: mov rdx, rcx
    test rdx, rdx
    jz .e
    mov rax, 1
    syscall
.e: pop rcx
    pop rbx
    ret

; ---------------------------------------------------------------
; _start
; ---------------------------------------------------------------
_start:
    mov rax, [rsp]          ; argc
    cmp rax, 3
    jl .usage
    mov rbx, [rsp+8]        ; argv
    mov rdi, [rbx+8]        ; argv[1] input
    mov rsi, [rbx+16]       ; argv[2] output

    ; input dosyayini oku
    mov rax, 2              ; sys_open
    xor rdx, rdx            ; O_RDONLY
    syscall
    test rax, rax
    js .openerr
    mov r12, rax            ; fd (gecici)
    mov rax, 0              ; sys_read
    mov rdi, r12
    lea rsi, [srcbuf]
    mov rdx, 131071
    syscall
    test rax, rax
    js .readerr
    lea rbp, [srcbuf]
    add rbp, rax
    mov byte [rbp], 0       ; null-terminate
    mov rax, 3
    mov rdi, r12
    syscall

    ; global cursor'lari kur
    lea rdi, [outbuf]
    lea r14, [datasec]
    xor r12, r12            ; string sayaci
    xor r13, r13            ; degisken sayaci
    lea rbp, [srcbuf]

    call parse_loop

    ; output dosyayi ac
    mov rdi, [rsp+24]       ; argv[2] tekrar
    mov rax, 2
    mov rdx, 0x241          ; O_WRONLY|O_CREAT|O_TRUNC
    mov r10, 0o644
    syscall
    test rax, rax
    js .outerr
    mov r15, rax            ; output fd

    mov rdi, r15
    lea rsi, [f_secdata]
    call write_str
    lea rsi, [datasec]
    call write_str
    lea rsi, [d_nlchar]
    call write_str
    lea rsi, [f_text]
    call write_str
    lea rsi, [outbuf]
    call write_str
    lea rsi, [f_exit]
    call write_str
    lea rsi, [pn_text]
    call write_str
    lea rsi, [f_secsbss]
    call write_str

    ; degisken basina bss satiri
    xor rcx, rcx
.vars: cmp rcx, r13
    jae .vdone
    mov r11, rcx
    imul r11, r11, 32
    lea rdx, [varlist]
    add rdx, r11
    lea rdi, [scratch]
    push rcx
    mov rsi, f_bssvar1
    call emit
    mov rsi, rdx
    call emit
    mov rsi, f_bssvar2
    call emit
    pop rcx
    mov rdi, r15
    lea rsi, [scratch]
    call write_str
    inc rcx
    jmp .vars
.vdone:
    mov rax, 3
    mov rdi, r15
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall

.usage: mov rsi, m_usage
    jmp fail
.openerr: mov rsi, m_open
    jmp fail
.readerr: mov rsi, m_readerr
    jmp fail
.outerr: mov rsi, m_out
    jmp fail
