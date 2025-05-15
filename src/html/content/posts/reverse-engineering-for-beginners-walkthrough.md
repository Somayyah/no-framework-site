---
title: "Reverse engineering for beginners walkthrough - 1"
date: 2025-01-30 
description: Reading the book "Reverse engineering for beginners" by Dennis Yurichev 
type: "post"  
tags: ["assembly", "security", "reverse-engineering", "how-to", "technology", "arm", "operating systems", "kernel", "x86-64", "ARM"]
---

> Rest of the RE posts can be viewed [**here**](https://techwebunraveled.xyz/tags/reverse-engineering/).

# Reverse Engineering Journey

Reverse engineering is a deep topic I've been interested in for a while, and now I feel ready to dive in. I'm starting with the book [*Reverse Engineering for Beginners*](https://beginners.re/) by [Dennis Yurichev](https://yurichev.com/), and I'll move to other resources as needed.

## Chapter 1: Code Patterns

The book begins with an introduction to the author's background, his tech journey, and a discussion on compilers and computer architectures. It also touches on modern compilers and how they excel at optimizing code. It's a fun and informative read.

### 1.2.1 A Short Introduction to the CPU

This section explains the CPU, its function, and key terms. Here are some important definitions:

- **Instruction**: A primitive CPU command. Examples include moving data between registers, working with memory, and basic arithmetic operations. Each CPU has its own Instruction Set Architecture (ISA).
- **Machine Code**: Code that the CPU directly processes. Each instruction is typically encoded with several bytes.
- **Assembly Language**: A human-readable representation of machine code, often with extensions like macros to simplify programming.
- **CPU Register**: A fixed set of general-purpose registers (GPRs) within a CPU. For example, x86 has around 8 registers, x86-64 has about 16, and ARM has around 16. A register is essentially an untyped temporary variable, which is a powerful tool in assembly programming.

This introduction highlights the importance of assembly and how it relates to machine code and higher-level languages like C, C++, and Java.

### 1.3 An Empty Function

The book explores the assembly dump of an empty C function:

```c
void f() {
    return;
};
```

This function does nothing and returns nothing. Using GCC and MSVC on [Godbolt](https://godbolt.org/), we get the following assembly:

```bash
f       PROC
        ret     0
f       ENDP
```

In my study, I'll focus on **x86-64** and **ARM** architectures, which are the areas I'm most interested in exploring. The code above differs slightly from the book's output, even with the `/O7` optimization flag:

```bash
f:
    ret
```

After changing the compiler to **x86-64 GCC** with the `-O3` flag, I got the same result. So, it's important to always check the compiler version and optimization settings.

### 1.4.2 ARM

For ARM, the assembly output is a bit different:

```bash
f   PROC
    BX      lr  # For branching
    ENDP
```

I found this [cheatsheet](https://azeria-labs.com/downloads/cheatsheetv1.3-1920x1080.png) for ARM assembly. The `BX` instruction is used for branching, returning to the caller, whose address is stored in the `lr` (link register).

### Hello World in Assembly

Here’s the assembly code to print **"Hello, World!"** in **x86-64** assembly:

```assembly
.global _start
.intel_syntax noprefix

.section .text
_start:    

    // sys_write call    
    mov rax, 1
    mov rdi, 1    
    lea rsi, [hello_world]
    mov rdx, 14 
    syscall
    
    // sys_exit call to exit the program
    mov rax, 60
    mov rdi, 0
    syscall

.section .data
hello_world:
    .asciz "Hello, World!\n"

.section .bss 
```

The program contains 4 main sections:
- **Global section**: Identifies the entry point.
- **Text section**: Contains the actual code instructions.
- **Data section**: Holds **initialized** variables.
- **BSS section**: Holds **uninitialized** variables.

In the `.text` section, two [system calls](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/) are made:

- **`sys_write`**: To print out the "Hello, World!" string. The [syscall table](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/) specifies the arguments:

| %rax | System call | %rdi            | %rsi            | %rdx         | %r10 | %r8 | %r9 |
|------|-------------|-----------------|-----------------|-------------|------|----|----|
| 1    | sys_write   | unsigned int fd | const char *buf | size_t count |      |    |    |

The assembly code corresponding to the `sys_write` syscall is:

```assembly
mov rax, 1               // 1 = sys_write (this tells Linux we want to write)
mov rdi, 1               // File descriptor: 1 (stdout)
lea rsi, [hello_world]   // Address of the string (pointer)
mov rdx, 14              // Number of bytes to write
syscall                  // Perform the syscall
```

### Running the Assembly Code

To assemble and run the code, follow these steps:

1. **Assemble the source file (`hello-world.s`) into an object file (`hello-world.o`)**:
    ```bash
    as hello-world.s -o hello-world.o
    ```

2. **Link the object file to create an executable (`hello-world`)**:
    - The `-nostdlib` flag prevents linking with the standard C libraries.
    - The `-static` flag ensures the executable is statically linked.
    ```bash
    gcc -o hello-world hello-world.o -nostdlib -static
    ```

3. **Run the executable to see the output**:
    ```bash
    ./hello-world
    ```

This will output **"Hello, World!"** to the terminal. The second syscall is for sys_exit which enables us to exit from the code:

| %rax | System call | %rdi            | %rsi            | %rdx         | %r10 | %r8 | %r9 |
|------|------------|-----------------|-----------------|-------------|------|----|----|
| 60    | sys_exit  | int error_code | | |      |    |    |

So only two registers are needed, RAX to hold the syscall number, RDI to hold the return value then syscall to excute the call.

---

### Final Thoughts

While I’ve covered **x86-64** and **ARM** architectures, other compilers and architectures (like **MIPS**) are also mentioned in the book, though I’m not covering them in my study for now.
