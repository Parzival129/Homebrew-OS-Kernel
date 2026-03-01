.section .text

# Define ISR handler stubs for CPU exceptions (0-31)
# These stubs are called by the IDT when an exception occurs

# Exception handlers (no error code)
.macro ISR_NOERRCODE num
.global isr\num
isr\num:
    cli
    push $0          # Push a dummy error code
    push $\num       # Push the interrupt number
    jmp isr_common_handler
.endm

# Exception handlers (with error code)
.macro ISR_ERRCODE num
.global isr\num
isr\num:
    cli
    push $\num       # Push the interrupt number (error code already on stack)
    jmp isr_common_handler
.endm

# IRQ handlers
.macro IRQ_HANDLER num offset
.global irq\num
irq\num:
    cli
    push $0          # Push a dummy error code
    push $(\offset)  # Push the interrupt number
    jmp isr_common_handler
.endm

# CPU Exceptions
ISR_NOERRCODE 0    # Division by Zero
ISR_NOERRCODE 1    # Debug
ISR_NOERRCODE 2    # Non-Maskable Interrupt
ISR_NOERRCODE 3    # Breakpoint
ISR_NOERRCODE 4    # Into Detected Overflow
ISR_NOERRCODE 5    # Bound Range Exceeded
ISR_NOERRCODE 6    # Invalid Opcode
ISR_NOERRCODE 7    # Coprocessor Not Available
ISR_ERRCODE 8      # Double Fault (has error code)
ISR_NOERRCODE 9    # Coprocessor Segment Overrun
ISR_ERRCODE 10     # Invalid TSS (has error code)
ISR_ERRCODE 11     # Segment Not Present (has error code)
ISR_ERRCODE 12     # Stack-Segment Fault (has error code)
ISR_ERRCODE 13     # General Protection Fault (has error code)
ISR_ERRCODE 14     # Page Fault (has error code)
ISR_NOERRCODE 15   # Reserved
ISR_NOERRCODE 16   # Floating Point Exception
ISR_ERRCODE 17     # Alignment Check (has error code)
ISR_NOERRCODE 18   # Machine Check
ISR_NOERRCODE 19   # SIMD Floating-Point Exception
ISR_NOERRCODE 20   # Virtualization Exception
ISR_ERRCODE 21     # Control Protection Exception (has error code)
ISR_NOERRCODE 22   # Reserved
ISR_NOERRCODE 23   # Reserved
ISR_NOERRCODE 24   # Reserved
ISR_NOERRCODE 25   # Reserved
ISR_NOERRCODE 26   # Reserved
ISR_NOERRCODE 27   # Reserved
ISR_NOERRCODE 28   # Reserved
ISR_NOERRCODE 29   # Reserved
ISR_NOERRCODE 30   # Security Exception
ISR_NOERRCODE 31   # Reserved

# Hardware IRQ Handlers (mapped to interrupts 32-47)
IRQ_HANDLER 0   32  # Timer (IRQ0)
IRQ_HANDLER 1   33  # Keyboard (IRQ1)
IRQ_HANDLER 2   34  # Cascade (IRQ2)
IRQ_HANDLER 3   35  # COM2 (IRQ3)
IRQ_HANDLER 4   36  # COM1 (IRQ4)
IRQ_HANDLER 5   37  # LPT2 (IRQ5)
IRQ_HANDLER 6   38  # Floppy (IRQ6)
IRQ_HANDLER 7   39  # LPT1 (IRQ7)
IRQ_HANDLER 8   40  # Real Time Clock (IRQ8)
IRQ_HANDLER 9   41  # Peripheral (IRQ9)
IRQ_HANDLER 10  42  # Peripheral (IRQ10)
IRQ_HANDLER 11  43  # Peripheral (IRQ11)
IRQ_HANDLER 12  44  # Mouse (IRQ12)
IRQ_HANDLER 13  45  # Coprocessor (IRQ13)
IRQ_HANDLER 14  46  # ATA Primary (IRQ14)
IRQ_HANDLER 15  47  # ATA Secondary (IRQ15)

# Common handler called by all ISR/IRQ stubs
.global isr_common_handler
isr_common_handler: # Pushes additional data to stack so that it is consistent with the interrupt_frame structure expected by isr_handler in C
    # Save all general-purpose registers
    pusha                    # Push EAX, ECX, EDX, EBX, original ESP, EBP, ESI, EDI
    mov %ds, %ax
    push %eax                # Save data segment selector

    # Load kernel data segment
    mov $0x10, %ax          # Kernel data segment selector (from GDT)
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    # Call the high-level interrupt handler
    # Stack layout at this point:
    # [ESP + 0] = DS
    # [ESP + 4] = EDI
    # [ESP + 8] = ESI
    # [ESP + 12] = EBP
    # [ESP + 16] = ESP (original)
    # [ESP + 20] = EBX
    # [ESP + 24] = EDX
    # [ESP + 28] = ECX
    # [ESP + 32] = EAX
    # [ESP + 36] = Interrupt number
    # [ESP + 40] = Error code (or dummy 0)
    # [ESP + 44] = Return address (EIP)
    # [ESP + 48] = Code segment (CS)
    # [ESP + 52] = EFLAGS

    push %esp                # Push pointer to registers struct
    call isr_handler         # Call high-level handler, the stack is not set up correctly for the function to interpret the data
    add $4, %esp             # Clean up

    # Restore all registers
    pop %eax                 # Restore data segment selector
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    popa                     # Pop all general-purpose registers

    # Remove error code and interrupt number from stack
    add $8, %esp

    # Return from interrupt
    sti
    iret                     # Return from interrupt
