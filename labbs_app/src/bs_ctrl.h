#ifndef BS_CTRL_H
#define BS_CTRL_H

void bs_enable_channel(void *bs, int channel);

void bs_disable_channel(void *bs, int channel);

void bs_update_utc_time(void *bs, int year, int month, int day, int hour, int minute, int second);

void bs_set_channel_message(void *bs, int channel, void *buffer, int length);

void bs_enable_tx_timestamp(void *bs);

void bs_disable_tx_timestamp(void *bs);

// void bs_set_channel_pcode(void *bs, int channel, void *buffer, int length);

#endif