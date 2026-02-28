#include <kernel/idt.h>

struct idt_entry idt[NO_IDT_ENTRIES]; // 256 descriptors to fulfill i386 arch.
struct idt_ptr ip; // pointer to idt

extern void idt_init(uint32_t);

void idt_set_entry(int index, uint32_t base, uint16_t seg_sel, uint8_t attributes) {
    idt[index].base_low = (base & 0xFFFF);
    idt[index].base_high = (base >> 16) & 0xFFFF;
    idt[index].selector = seg_sel;
    idt[index].zero = 0;
    idt[index].type_attributes = attributes; // 0x8E interrupt gate, 0x8F trap gate, 0x85 task gate
}

void idt_install() {
    ip.limit = (sizeof(struct idt_entry) * NO_IDT_ENTRIES) - 1;
    ip.base = (uint32_t)&idt;

    // idt_set_entry here for all entries

    load_idt((uint32_t)&ip);
}