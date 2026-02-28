#include <kernel/gdt.h>

struct gdt_entry gdt[5]; // Initialize the list of gdt entries
struct gdt_ptr gp; // Initialize the 'entry point' of the gdt

extern void gdt_init(uint32_t);

void gdt_set_gate(int index, uint32_t base, uint32_t limit, uint8_t access, uint8_t gran) {
    gdt[index].base_low    = (base & 0xFFFF);
    gdt[index].base_middle = (base >> 16) & 0xFF;
    gdt[index].base_high   = (base >> 24) & 0xFF;

    gdt[index].limit_low   = (limit & 0xFFFF);
    gdt[index].granularity = (limit >> 16) & 0x0F;

    gdt[index].granularity |= gran & 0xF0;
    gdt[index].access      = access;
}

void gdt_install() { // sets up the gdt table and flushes it to the CPU
    gp.limit = (sizeof(struct gdt_entry) * 5) - 1;
    gp.base  = (uint32_t)&gdt;

    // 0x00: Null descriptor
    gdt_set_gate(0, 0, 0, 0, 0);
    // 0x08: Kernel Code Segment (Access: 0x9A, Granularity: 0xCF)
    gdt_set_gate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);
    // 0x10: Kernel Data Segment (Access: 0x92, Granularity: 0xCF)
    gdt_set_gate(2, 0, 0xFFFFFFFF, 0x92, 0xCF);
    // 0x18: User Code Segment (Access: 0xFA, Granularity: 0xCF)
    gdt_set_gate(3, 0, 0xFFFFFFFF, 0xFA, 0xCF);
    // 0x20: User Data Segment (Access: 0xF2, Granularity: 0xCF)
    gdt_set_gate(4, 0, 0xFFFFFFFF, 0xF2, 0xCF);

    gdt_init((uint32_t)&gp); // pass the pointer to the gdt table so gdt_init can load it properly
}