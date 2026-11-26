# Projectile Motion Simulator (x86-64 Assembly)

## 1. Project Overview
This project is an x86-64 NASM Assembly application that simulates 2D projectile motion in a frictionless environment. The program prompts the user for an initial velocity and launch angle, then calculates and prints the projectile's trajectory $(x, y)$ at `0.25`-second intervals until it hits the ground ($y < 0$). Finally, it displays a summary of the total flight time, maximum height, and horizontal range.

## 2. Mathematical Model
Given initial velocity $v_0$ ($\text{m/s}$), launch angle $\theta$ ($\text{degrees}$), and gravitational acceleration $g = 9.81\text{ m/s}^2$:

* **Angle in Radians:** $\theta_{\text{rad}} = \theta \times \frac{\pi}{180}$
* **Initial Velocity Components:**
  * $v_{0x} = v_0 \cdot \cos(\theta_{\text{rad}})$
  * $v_{0y} = v_0 \cdot \sin(\theta_{\text{rad}})$
* **Position at Time $t$:**
  * $x(t) = v_{0x} \cdot t$
  * $y(t) = v_{0y} \cdot t - \frac{1}{2}gt^2$
* **Summary Metrics:**
  * $t_{\text{total}} = \frac{2 v_{0y}}{g}$
  * $H_{\max} = \frac{v_{0y}^2}{2g}$
  * $R = v_{0x} \cdot t_{\text{total}}$

## 3. Technical Implementation
* **Assembler & ABI:** Written for 64-bit Linux (ELF64) using `DEFAULT REL` (RIP-relative addressing) and adhering to the System V AMD64 calling convention.
* **Floating-Point Arithmetic:** Uses SSE2 scalar double-precision instructions (`movsd`, `addsd`, `subsd`, `mulsd`, `divsd`, `ucomisd`) and `XMM` registers.
* **C Standard Library Integration:** Links against `libc` and `libm` (`-lm`) to utilize `printf`, `scanf`, `sin`, and `cos`.

## 4. Build and Run Instructions
To assemble, link, and run the program on a 64-bit Linux environment:

1. **Assemble the source code into an ELF64 object file:**
   `nasm -f elf64 projectile.asm -o projectile.o`

2. **Link with the C and math libraries (`-lm`):**
   `gcc projectile.o -o projectile -no-pie -lm`

3. **Execute the simulator:**
   `./projectile`

## 5. Sample Output

```text
Enter initial velocity (m/s): 30
Enter launch angle (degrees): 45

Time (s)        X Distance (m)  Y Height (m)
-------------------------------------------
0.00            0.00            0.00
0.25            5.30            5.00
0.50            10.61           9.38
...
4.25            90.16           1.56
-------------------------------------------
Total Flight Time : 4.32 s
Maximum Height    : 22.81 m
Total Range       : 91.74 m