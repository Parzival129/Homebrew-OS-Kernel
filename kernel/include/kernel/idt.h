#ifndef _KERNEL_IDT_H
#define _KERNEL_IDT_H

#define NO_IDT_ENTRIES 256

#include <stdint.h>

// Creates a IDT entry, 8 bytes long

struct idt_entry {
   uint16_t base_low;        // offset bits 0..15
   uint16_t selector;        // a code segment selector in GDT or LDT
   uint8_t  zero;            // unused, set to 0
   uint8_t  type_attributes; // gate type, dpl, and p fields
   uint16_t base_high;        // offset bits 16..31
} __attribute__((packed));

// struct pointer to IDT

struct idt_ptr {
    uint16_t limit; // limit size of the idt table (1 less than idt size in bytes)
    uint32_t base; // linear address of IDT (consider paging)
} __attribute__((packed)); // Tells the compiler to 'squish' these attributes together in memory with no 'padding' between them
// Avoids problems with CPU confusion when reading idt info


// Function to initialize idt from kernel_main
void idt_install(void);

#endif