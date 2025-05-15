---
title: "The anatomy of x86-64 assembly program"
date: 2025-02-05
description: x86-64 for newbies 
type: "post"
tags: ["x86-64", "reverse-engineering", "assembly", "operating systems"]
---

> Rest of the RE posts can be viewed [**here**](https://techwebunraveled.xyz/tags/reverse-engineering/).

Today we'll talk about the sections of assembly program and we'll use it to write a simple "Hello, World!" application. We'll focus on x86-64 architecture but generally same applies to ARM.

## The General Structure of Assembly program

Generally, a **x86-64** assembly program consists of these sections:

```assembly
.global _start
.intel_syntax noprefix

.section .text
_start:    

.section .data

.section .bss 
```

The program contains 4 main sections:
- **Global section**: Identifies the entry point, _start in our case.
- **Text section**: Contains the actual code instructions.
- **Data section**: Holds **initialized** variables.
- **BSS section**: Holds **uninitialized** variables.

## The Global Section

To execute a program we need an entrypoint to start with (similar to main in C), which is what the first line for. The general syntax is:

```assembly
.global <entry point label>
```

You don't have to use _start and "_" isn't mandatory, however the convention is to use an underscore for system-related or special symbols.

As to the second line, assembly follows two main syntax styles, intel syntax and AT&T Syntax with some differences between each other, [ref](https://imada.sdu.dk/u/kslarsen/dm546/Material/IntelnATT.htm), I'll be using the intel syntax by adding:

```assembly
.intel_syntax noprefix
```

The *noprefix* keyword is so we don't use the prefix '%' which makes writing the code easier, the abscence of the above directive changes the syntax style to AT&T style, so instead of:

```assembly
.intel_syntax noprefix
mov eax, 1 ; Intel style were destination before the source and % isn't used
```

We get:

```assembly
mov $1, %eax   // notice the prefix % is added to the register name and the source preceeds the destination
```

## The TEXT Section

In the `.text` section, we modify registers and write the actual instructions and syscalls which we will talk about later. To print something to the standard output we can take advantage of the sys_write syscall, which is easy to translate to assembly by following the [syscall table](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/), let's take a look at it's elements:

| %rax | System call | %rdi            | %rsi            | %rdx         | %r10 | %r8 | %r9 |
|------|-------------|-----------------|-----------------|-------------|------|----|----|
| 1    | sys_write   | unsigned int fd | const char *buf | size_t count |      |    |    |

The assembly code corresponding to the `sys_write` syscall is:

```assembly
mov rax, 1               // 1 = sys_write (this tells Linux we want to write)
mov rdi, 1               // File descriptor: 1 (stdout)
lea rsi, [INITIALIZED VARIABLE NAME]   // Address of the string (pointer)
mov rdx, 14              // Number of bytes to write
syscall                  // Perform the syscall
```

We use the opcode *mov* to copy (not actually move) the data into the registers, meanwhile if we want to copy and address of a variable which holds our string we use lea, in the sys_write table entry we see that rsi should have a pointer to a buffer which is how we know it requires an address to such buffer not the actual value.

We end the syscall with the Opcode *syscall* to execute it. Just like in other programming languages like C, we need to exit from our code somehow, so we can use sys_exit syscall which only requires two registers!

```assembly
mov rax, 60
mov rdi, 0
syscall
```

## The DATA Section

Here we declare the variables and initialize them, for example to initialize a null terminated string:

```assembly
.section .data
hello_world:
    .asciz "Hello, World!"
```

It's important that the variables are initialized, and to use them we refer to their address with the instruction ```lea``` (load effective address).

## The BSS Section

This section is also to save variables but unlike the DATA section they're not giving an initial value.

## Putting It All Together

Now let's use this information to print "Hello, World!" to the screen, for that we will use the syscall "sys_write" and "sys_exit" which we discussed above:

* Let's write the sections first:

```assembly
.global _start
.intel_syntax noprefix

.section .text
_start:

.section .data

.section .bss
```

* Then let's create our variable to store the string "Hello, World!"

```
.global _start
.intel_syntax noprefix

.section .text
_start:

.section .data
hello_world:
    .asciz "Hello, World!\n"
```

* Now we will invoke sys_write syscall to print the **Hello, world!** string:

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

## Running the Assembly Code

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

It's ok if you don't understand yet how these commands  work, we will explain them in a separate post.

---

## Final Thoughts

Now you have wrote your first assembly program, we are ready to move deeper into other topics and understand this language better.
