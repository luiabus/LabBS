module top (
    input           SYS_CLK,
    input           SYS_RST,

    output          led0,
    output          led1,

    output [7:0]    INT_CE_N, // unused

    output [3:0]    STATUS1,
    output [3:0]    STATUS2,
    output [3:0]    STATUS3,
    output [3:0]    STATUS4,
    output [3:0]    STATUS5,
    output [3:0]    STATUS6,
    output [3:0]    STATUS7,
    output [3:0]    STATUS8,

    output [1:0]    MESSAGE1,
    output [1:0]    MESSAGE2,
    output [1:0]    MESSAGE3,
    output [1:0]    MESSAGE4,
    output [1:0]    MESSAGE5,
    output [1:0]    MESSAGE6,
    output [1:0]    MESSAGE7,
    output [1:0]    MESSAGE8,
   
    output [7:0]    DA_VALID,   //[0] - 1, [1] - 2, ... , [7] - 8

    input           UTC_UART_RXD,
    output          UTC_UART_TXD,
    input           PPS_IN,

    inout  [31:0]   SRAM_DATA, //高8位连接到了J18的高8位引脚
    output [17:0]   SRAM_ADDR,
    output          SRAM_CE_N,
    output          SRAM_CE2_N,
    output          SRAM_OE_N,
    output          SRAM_SW_A_N,
    output          SRAM_SW_B_N,
    output          SRAM_SW_C_N,
    output          SRAM_SW_D_N,
    output          SRAM_WE_N,

    inout  [31:0]   SRAM1_DATA, //高8位连接到了J18的次高8位引脚
    output [17:0]   SRAM1_ADDR,
    output          SRAM1_CE_N,
    output          SRAM1_CE2_N,
    output          SRAM1_OE_N,
    output          SRAM1_SW_A_N,
    output          SRAM1_SW_B_N,
    output          SRAM1_SW_C_N,
    output          SRAM1_SW_D_N,
    output          SRAM1_WE_N,

    // ad9361
    output [3:0]    AD9361_SW,
    output [3:0]    AD9361_TX_PD1800,
    output [3:0]    AD9361_TX_PD3500,

    output          AD9361_MOSI_ADI1,
    input           AD9361_MISO_ADI1,
    output          AD9361_CLK_ADI1,
    output [1:0]    AD9361_CSB1,
    output [1:0]    AD9361_CSB2,

    output          AD9361_MOSI_ADI3,
    input           AD9361_MISO_ADI3,
    output          AD9361_CLK_ADI3,
    output [1:0]    AD9361_CSB3,
    output [1:0]    AD9361_CSB4,

    output          AD9361_MOSI_ADI5,
    input           AD9361_MISO_ADI5,
    output          AD9361_CLK_ADI5,
    output [1:0]    AD9361_CSB5,
    output [1:0]    AD9361_CSB6,

    output          AD9361_MOSI_ADI7,
    input           AD9361_MISO_ADI7,
    output          AD9361_CLK_ADI7,
    output [1:0]    AD9361_CSB7,
    output [1:0]    AD9361_CSB8,

    output [3:0]    AD9361_RESET_AD9361,
    output          AD9361_SYNC,               
    output [1:0]    AD9361_TX_FRAME_FPGA,      //用于反馈给AD9361 20.46M
    output [1:0]    AD9361_FB_CLK_FPGA         //用于寄存码字 40.92M
);

    wire sys_clk = SYS_CLK;
    wire sys_rst = SYS_RST; // TODO: syncer

    wire tx_rst;
    wire dev_conf_active;

    wire ad9361_init;
    wire ad9361_init_done;

    wire pcode_init;
    wire pcode_init_done;

    wire        sram1_wr_valid;
    wire        sram1_wr_ready;
    wire [17:0] sram1_wr_addr;
    wire [31:0] sram1_wr_data;
    wire        sram2_wr_valid;
    wire        sram2_wr_ready;
    wire [17:0] sram2_wr_addr;
    wire [31:0] sram2_wr_data;

    wire [15:0] pcode_addr_o;

    sys_ctl i_sys_ctl (
        .clk(sys_clk),
        .rst(sys_rst),
        .ad9361_init(ad9361_init),
        .ad9361_init_done(ad9361_init_done),
        .pcode_init(pcode_init),
        .pcode_init_done(pcode_init_done),
        .dev_conf_active_o(dev_conf_active),
        .tx_rst_o(tx_rst)
    );

    ad9361_init i_ad9361_init (
        .clk(sys_clk),
        .rst(sys_rst),
        .ad9361_init(ad9361_init),
        .ad9361_init_done(ad9361_init_done),
        .AD9361_SW(AD9361_SW),
        .AD9361_TX_PD1800(AD9361_TX_PD1800),
        .AD9361_TX_PD3500(AD9361_TX_PD3500),
        .AD9361_MOSI_ADI1(AD9361_MOSI_ADI1),
        .AD9361_MISO_ADI1(AD9361_MISO_ADI1),
        .AD9361_CLK_ADI1(AD9361_CLK_ADI1),
        .AD9361_CSB1(AD9361_CSB1),
        .AD9361_CSB2(AD9361_CSB2),
        .AD9361_MOSI_ADI3(AD9361_MOSI_ADI3),
        .AD9361_MISO_ADI3(AD9361_MISO_ADI3),
        .AD9361_CLK_ADI3(AD9361_CLK_ADI3),
        .AD9361_CSB3(AD9361_CSB3),
        .AD9361_CSB4(AD9361_CSB4),
        .AD9361_MOSI_ADI5(AD9361_MOSI_ADI5),
        .AD9361_MISO_ADI5(AD9361_MISO_ADI5),
        .AD9361_CLK_ADI5(AD9361_CLK_ADI5),
        .AD9361_CSB5(AD9361_CSB5),
        .AD9361_CSB6(AD9361_CSB6),
        .AD9361_MOSI_ADI7(AD9361_MOSI_ADI7),
        .AD9361_MISO_ADI7(AD9361_MISO_ADI7),
        .AD9361_CLK_ADI7(AD9361_CLK_ADI7),
        .AD9361_CSB7(AD9361_CSB7),
        .AD9361_CSB8(AD9361_CSB8),
        .AD9361_RESET_AD9361(AD9361_RESET_AD9361),
        .AD9361_SYNC(AD9361_SYNC),               
        .AD9361_TX_FRAME_FPGA(AD9361_TX_FRAME_FPGA),      //用于反馈给AD9361 20.46M
        .AD9361_FB_CLK_FPGA(AD9361_FB_CLK_FPGA)         //用于寄存码字 40.92M
    );

    pcode_init i_pcode_init (
        .clk(sys_clk),
        .rst(sys_rst),
        .pcode_init(pcode_init),
        .pcode_init_done(pcode_init_done),
        .sram1_wr_valid(sram1_wr_valid),
        .sram1_wr_ready(sram1_wr_ready),
        .sram1_wr_addr(sram1_wr_addr),
        .sram1_wr_data(sram1_wr_data),
        .sram2_wr_valid(sram2_wr_valid),
        .sram2_wr_ready(sram2_wr_ready),
        .sram2_wr_addr(sram2_wr_addr),
        .sram2_wr_data(sram2_wr_data)
    );

    message_tx i_tx (
        .clk(sys_clk),
        .rst(tx_rst),
        .PPS_IN(PPS_IN),
        .UTC_UART_RXD(UTC_UART_RXD),
        .pcode_addr_o(pcode_addr_o),
        .MESSAGE1(MESSAGE1),
        .MESSAGE2(MESSAGE2),
        .MESSAGE3(MESSAGE3),
        .MESSAGE4(MESSAGE4),
        .MESSAGE5(MESSAGE5),
        .MESSAGE6(MESSAGE6),
        .MESSAGE7(MESSAGE7),
        .MESSAGE8(MESSAGE8)
    );

    sram_controller i_sram1_ctl (
        .clk(sys_clk),
        .rst(sys_rst),
        .tx_mode(!tx_rst),
        .rd_addr(pcode_addr_o),
        .wr_valid(sram1_wr_valid),
        .wr_ready(sram1_wr_ready),
        .wr_addr(sram1_wr_addr),
        .wr_data(sram1_wr_data),
        .SRAM_DATA(SRAM_DATA), //高8位连接到了J18的高8位引脚
        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_CE_N(SRAM_CE_N),
        .SRAM_CE2_N(SRAM_CE2_N),
        .SRAM_OE_N(SRAM_OE_N),
        .SRAM_SW_A_N(SRAM_SW_A_N),
        .SRAM_SW_B_N(SRAM_SW_B_N),
        .SRAM_SW_C_N(SRAM_SW_C_N),
        .SRAM_SW_D_N(SRAM_SW_D_N),
        .SRAM_WE_N(SRAM_WE_N)
    );

    sram_controller i_sram2_ctl (
        .clk(sys_clk),
        .rst(sys_rst),
        .tx_mode(!tx_rst),
        .rd_addr(pcode_addr_o),
        .wr_valid(sram2_wr_valid),
        .wr_ready(sram2_wr_ready),
        .wr_addr(sram2_wr_addr),
        .wr_data(sram2_wr_data),
        .SRAM_DATA(SRAM1_DATA), //高8位连接到了J18的高8位引脚
        .SRAM_ADDR(SRAM1_ADDR),
        .SRAM_CE_N(SRAM1_CE_N),
        .SRAM_CE2_N(SRAM1_CE2_N),
        .SRAM_OE_N(SRAM1_OE_N),
        .SRAM_SW_A_N(SRAM1_SW_A_N),
        .SRAM_SW_B_N(SRAM1_SW_B_N),
        .SRAM_SW_C_N(SRAM1_SW_C_N),
        .SRAM_SW_D_N(SRAM1_SW_D_N),
        .SRAM_WE_N(SRAM1_WE_N)
    );

    assign INT_CE_N = 8'b0; // 

    assign STATUS1 = {3'b0, dev_conf_active == 0};
    assign STATUS2 = {3'b0, dev_conf_active == 0};
    assign STATUS3 = {3'b0, dev_conf_active == 0};
    assign STATUS4 = {3'b0, dev_conf_active == 0};
    assign STATUS5 = {3'b0, dev_conf_active == 0};
    assign STATUS6 = {3'b0, dev_conf_active == 0};
    assign STATUS7 = {3'b0, dev_conf_active == 0};
    assign STATUS8 = {3'b0, dev_conf_active == 0};
    assign UTC_UART_TXD = 1;

endmodule
