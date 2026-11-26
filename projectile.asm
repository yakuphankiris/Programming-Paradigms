DEFAULT REL

extern printf
extern scanf
extern sin
extern cos

section .data
    g           dq 9.81     ; Gravitational acceleration (m/s^2)
    half        dq 0.5      ; Constant 0.5 for (1/2)*g*t^2 formula
    time_step   dq 0.25     ; Time step increment (seconds)            
    two         dq 2.0      ; Constant 2.0 for summary calculations
    zero        dq 0.0      ; Ground level threshold (y = 0)
    pi          dq 3.141592653589793 ; Pi constant
    deg180      dq 180.0    ; Degrees to radians conversion factor

    prompt_v0   db "Enter initial velocity (m/s): ", 0
    prompt_ang  db "Enter launch angle (degrees): ", 0
    scan_fmt    db "%lf", 0
    
    header      db 10, "Time (s)", 9, "X Distance (m)", 9, "Y Height (m)", 10
                db "-------------------------------------------", 10, 0
    row_fmt     db "%.2f", 9, 9, "%.2f", 9, 9, "%.2f", 10, 0
    
    summary_fmt db "-------------------------------------------", 10
                db "Total Flight Time : %.2f s", 10
                db "Maximum Height    : %.2f m", 10
                db "Total Range       : %.2f m", 10, 0

section .bss
    v0          resq 1                      ; Initial velocity magnitude
    angle       resq 1                      ; Launch angle (converted to radians)
    v0x         resq 1                      ; Horizontal velocity component
    v0y         resq 1                      ; Vertical velocity component
    t           resq 1                      ; Current simulation time

section .text
    global main

main:
    push    rbp
    mov     rbp, rsp

    ; Read initial velocity and launch angle from the user
    lea     rdi, [prompt_v0]
    xor     rax, rax
    call    printf

    lea     rdi, [scan_fmt]
    lea     rsi, [v0]
    xor     rax, rax
    call    scanf

    lea     rdi, [prompt_ang]
    xor     rax, rax
    call    printf

    lea     rdi, [scan_fmt]
    lea     rsi, [angle]
    xor     rax, rax
    call    scanf

    ; Convert angle to radians and compute velocity components (v0x, v0y)
    movsd   xmm0, [angle]
    mulsd   xmm0, [pi]
    divsd   xmm0, [deg180]
    movsd   [angle], xmm0

    movsd   xmm0, [angle]
    call    cos
    mulsd   xmm0, [v0]
    movsd   [v0x], xmm0

    movsd   xmm0, [angle]
    call    sin
    mulsd   xmm0, [v0]
    movsd   [v0y], xmm0

    ; Initialize time and print the trajectory table header
    lea     rdi, [header]
    xor     rax, rax
    call    printf

    movsd   xmm0, [zero]
    movsd   [t], xmm0

sim_loop:
    ; Calculate current (x, y) coordinates and exit when the projectile hits the ground
    movsd   xmm4, [t]

    movsd   xmm2, [v0y]
    mulsd   xmm2, xmm4

    movsd   xmm3, [half]
    mulsd   xmm3, [g]
    mulsd   xmm3, xmm4
    mulsd   xmm3, xmm4
    subsd   xmm2, xmm3

    ucomisd xmm2, [zero]
    jb      print_summary

    movsd   xmm1, [v0x]
    mulsd   xmm1, xmm4

    lea     rdi, [row_fmt]
    movsd   xmm0, xmm4
    mov     rax, 3
    call    printf

    movsd   xmm0, [t]
    addsd   xmm0, [time_step]
    movsd   [t], xmm0
    jmp     sim_loop

print_summary:
    ; Compute and display total flight time, maximum height, and total range
    movsd   xmm0, [two]
    mulsd   xmm0, [v0y]
    divsd   xmm0, [g]

    movsd   xmm1, [v0y]
    mulsd   xmm1, [v0y]
    movsd   xmm3, [two]
    mulsd   xmm3, [g]
    divsd   xmm1, xmm3

    movsd   xmm2, [v0x]
    mulsd   xmm2, xmm0

    lea     rdi, [summary_fmt]
    mov     rax, 3
    call    printf

    mov     rsp, rbp
    pop     rbp
    xor     rax, rax
    ret


 ; Compile :    nasm -f elf64 projectile.asm -o projectile.o
 ; Link    :    gcc projectile.o -o projectile -no-pie -lm 
 ; Run     :    ./projectile