#include <stdint.h>
#include <xpseudo_asm.h>
#include "bs_ctrl.h"

void bs_enable_channel(void *bs, int channel) {
    volatile uint32_t *bs_ptr = (volatile uint32_t *) bs;
    volatile uint32_t *reg3 = &bs_ptr[3];
    printf("before: 0x%x, channel = %d\n", *reg3, channel);
    *reg3 = *reg3 | (1 << channel);
    dmb();
    dsb();
    usleep(10);
    printf("after: 0x%x\n", *reg3);
}

void bs_disable_channel(void *bs, int channel) {
    volatile uint32_t *bs_ptr = (volatile uint32_t *) bs;
    volatile uint32_t *reg3 = &bs_ptr[3];
    *reg3 = *reg3 & ~(1 << channel);
}

void bs_update_utc_time(void *bs, int year, int month, int day, int hour, int minute, int second) {
    volatile uint32_t *bs_ptr = (volatile uint32_t *) bs;
    volatile uint32_t *reg0 = &bs_ptr[0];
    volatile uint32_t *reg1 = &bs_ptr[1];
    volatile uint32_t *reg2 = &bs_ptr[2];

    uint32_t reg0_data = (hour << 16) | (minute << 8) | second;
    uint32_t reg1_data = (year << 16) | (month << 8) | day;

    *reg0 = reg0_data;
    *reg1 = reg1_data;
    *reg2 = 1 << 31;
}

void bs_set_channel_message(void *bs, int channel, void *buffer, int length) {
    volatile char *bs_ptr = (volatile char *) bs;
    volatile uint32_t *bs_buf_ptr = (volatile uint32_t *) (bs_ptr + 0x1000 + 0x100 * channel);
    uint32_t *buf_ptr = (uint32_t *) buffer;
    for (int i = 0; i < length; i += sizeof(uint32_t)) {
        *bs_buf_ptr++ = *buf_ptr++;
    }
}

void bs_set_channel_pcode(void *bs, int channel, void *buffer, int length) {
    volatile char *bs_ptr = (volatile char *) bs;
    volatile uint32_t *bs_buf_ptr = (volatile uint32_t *) (bs_ptr + 0x10000 + 0x2000 * channel);
    uint32_t *buf_ptr = (uint32_t *) buffer;
    for (int i = 0; i < length; i += sizeof(uint32_t)) {
        *bs_buf_ptr++ = *buf_ptr++;
    }
}


void bs_enable_tx_timestamp(void *bs) {
    volatile uint32_t *bs_ptr = (volatile uint32_t *) bs;
    volatile uint32_t *reg4 = &bs_ptr[4];
    *reg4 = *reg4 | (1 << 0);
}

void bs_disable_tx_timestamp(void *bs) {
    volatile uint32_t *bs_ptr = (volatile uint32_t *) bs;
    volatile uint32_t *reg4 = &bs_ptr[4];
    *reg4 = *reg4 & ~(1 << 0);
}