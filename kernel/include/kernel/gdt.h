#ifndef _KERNEL_GDT_H
#define _KERNEL_GDT_H

#include <stdint.h>

// This struct describes a GDT entry. It's 8 bytes.
// A contract that segments the memory into different parts

struct gdt_entry {
    uint16_t limit_low;           // The lower 16 bits of the limit.
    uint16_t base_low;            // The lower 16 bits of the base.
    uint8_t  base_middle;         // The next 8 bits of the base.
    uint8_t  access;              // Access flags, determine what ring this segment can be used in.
    uint8_t  granularity;
    uint8_t  base_high;           // The last 8 bits of the base.
} __attribute__((packed));

// This struct describes the GDTR pointer which we give to the CPU. Simply tells the CPU where the GDT table is and how big it is
struct gdt_ptr {
    uint16_t limit;               // The upper 16 bits of all selector limits.
    uint32_t base;                // The address of the first gdt_entry_t struct.
} __attribute__((packed));

// Function to be called from kernel_main
void gdt_install(void);

#endif