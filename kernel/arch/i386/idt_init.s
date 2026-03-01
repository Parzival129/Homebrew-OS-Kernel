.section .text
.global idt_init
idt_init:
    mov 4(%esp), %eax    # Get the pointer to the IDTR from the stack (4 for number of bytes)
    lidt (%eax) # load the IDT pointer to the idt register in the cpu
    ret
