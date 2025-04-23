#include <stdio.h>
#include <string.h>

#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xuartps.h"

#include "ad9361/ad9361.h"
#include "bs_ctrl.h"
#include "nmea_parser.h"

// XUartPs uart_dbg;        /* Instance of the UART Device */
XUartPs uart_gps; /* Instance of the UART Device */

void *bs_ptr = (void *)XPAR_XABS_TOP_0_BASEADDR;

int bs_init()
{
    char msg_buffer[256] = {};
    for (int channel = 0; channel < 8; channel++)
    {
        memset(msg_buffer, 0, sizeof(msg_buffer));

        // 配置同步头（其实是同步尾）
        // if (channel == 0)
        // {
        // msg_buffer[8] = 0xf0;
        // msg_buffer[9] = 0x0f;
        // msg_buffer[10] = 0xf0;
        // msg_buffer[11] = 0x5f;
        // msg_buffer[12] = 0x05;
        // }
        bs_enable_channel(bs_ptr, channel);
        bs_set_channel_message(bs_ptr, channel, msg_buffer, sizeof(msg_buffer));
        //    	}
        //    	if (channel == 0) {
        //    		memset(msg_buffer, 0xff, sizeof(msg_buffer));
        //    		bs_enable_channel(bs_ptr, channel);
        //    	}
        //    	if (channel == 0) {
        //    		memset(msg_buffer, 0xff, sizeof(msg_buffer));
        //    		bs_enable_channel(bs_ptr, channel);
        //    	}
    }
    bs_enable_tx_timestamp(bs_ptr);

    return 0;
}

int gps_uart_init()
{
    int Status;
    XUartPs_Config *Config;

    Config = XUartPs_LookupConfig(XPAR_XUARTPS_0_DEVICE_ID);
    if (NULL == Config)
    {
        return XST_FAILURE;
    }

    Status = XUartPs_CfgInitialize(&uart_gps, Config, Config->BaseAddress);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    XUartPs_SetBaudRate(&uart_gps, 9600);

    return 0;
}

int nmea_recv_line(char *buffer, int length)
{
    int recv_ptr = 0;
    while (recv_ptr < length - 1)
    {
        u8 recv_ch;
        int res = (int)XUartPs_Recv(&uart_gps, &recv_ch, 1);
        if (res <= 0)
            continue;

        if (recv_ch == '\r' || recv_ch == '\n')
        {
            if (recv_ptr == 0)
            {
                continue;
            }
            else
            {
                buffer[recv_ptr] = '\0';
                break;
            }
        }
        else
        {
            buffer[recv_ptr++] = recv_ch;
        }
    }
    return recv_ptr;
}

int nmea_recv()
{
    char buffer[256] = {};
    nmeaGPRMC gprmc_pack = {};

    while (1)
    {
        int line_len = nmea_recv_line(buffer, sizeof(buffer));

        char *pos = strstr(buffer, "$GNRMC");
        if (pos == buffer)
        {
            puts(buffer);

            int res = nmea_parse_GPRMC(buffer, line_len + 1, &gprmc_pack);
            printf("  res = %d\n", res);
            printf("  year = %d\n", gprmc_pack.utc.year); /**< Years since 1900 */
            printf("  mon = %d\n", gprmc_pack.utc.mon);   /**< Months since January - [0,11] */
            printf("  day = %d\n", gprmc_pack.utc.day);   /**< Day of the month - [1,31] */
            printf("  hour = %d\n", gprmc_pack.utc.hour); /**< Hours since midnight - [0,23] */
            printf("  min = %d\n", gprmc_pack.utc.min);   /**< Minutes after the hour - [0,59] */
            printf("  sec = %d\n", gprmc_pack.utc.sec);   /**< Seconds after the minute - [0,59] */
            printf("  hsec = %d\n", gprmc_pack.utc.hsec); /**< Hundredth part of second - [0,99] */

            if (gprmc_pack.utc.year != 0 && gprmc_pack.utc.mon != 0 && gprmc_pack.utc.day != 0)
            {
                bs_update_utc_time(bs_ptr, gprmc_pack.utc.year, gprmc_pack.utc.mon, gprmc_pack.utc.day, gprmc_pack.utc.hour, gprmc_pack.utc.min, gprmc_pack.utc.sec);
            }
        }
    }
    return 0;
}

int main()
{
    init_platform();

    //    while (1){printf("wwwwwww...\n");}
    printf("Initializing AD9361...\n");
    ad9361_init();

    bs_init();
    gps_uart_init();
    bs_update_utc_time(bs_ptr, 0, 0, 0, 0, 0, 0);   // 上电后的默认时间戳
    printf("Initialization done...\n");
    nmea_recv();

    cleanup_platform();
    return 0;
}
