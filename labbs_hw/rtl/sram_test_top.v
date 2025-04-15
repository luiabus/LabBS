module sram_test_top (
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
    output          SRAM1_WE_N
);

    assign led0 = 0;
    assign led1 = 1;

    assign INT_CE_N = 8'b1111_1110;

    assign STATUS1 = 1;
    assign STATUS2 = 1;
    assign STATUS3 = 1;
    assign STATUS4 = 1;
    assign STATUS5 = 1;
    assign STATUS6 = 1;
    assign STATUS7 = 1;
    assign STATUS8 = 1;

    assign MESSAGE1 = 0;
    assign MESSAGE2 = 0;
    assign MESSAGE3 = 0;
    assign MESSAGE4 = 0;
    assign MESSAGE5 = 0;
    assign MESSAGE6 = 0;
    assign MESSAGE7 = 0;
    assign MESSAGE8 = 0;
    assign DA_VALID = 8'b1;
    assign UTC_UART_TXD = 1;


    // wire clk = SYS_CLK;
    wire clk;
    wire rst = SYS_RST; // TODO: syncer

    sys_pll pll1_inst(
        .inclk0(SYS_CLK),               //40.92M
        .c0(clk),     //40.92M
        .c1()    //40.92M
    );


    wire [31:0] probe_sig = SRAM_DATA;
    wire [31:0] source_sig;
    wire [7:0]  probe2_sig;
    wire [7:0]  source2_sig; // 0: write enable, 1: read mode

    reg vio_wr_enable_meta;
    reg vio_wr_enable_sync;
    reg vio_wr_enable_sync2;

    wire        sram_tx_mode = source2_sig[1];

    reg         sram1_wr_valid;
    wire        sram1_wr_ready;
    wire [17:0] sram1_wr_addr = source_sig;
    wire [31:0] sram1_wr_data = {4{source_sig[31:24]}};

    reg         sram2_wr_valid = 0;
    wire        sram2_wr_ready;
    wire [17:0] sram2_wr_addr = 0;
    wire [31:0] sram2_wr_data = source_sig;

    wire [15:0] sram1_rd_addr = source_sig;
    wire [15:0] sram2_rd_addr = source_sig;


    assign probe2_sig = {4'b0, sram1_wr_valid, sram1_wr_ready, sram2_wr_valid, sram2_wr_ready};

    sram_controller i_sram1_ctl (
        .clk(clk),
        .rst(rst),
        .tx_mode(sram_tx_mode),
        .rd_addr(sram1_rd_addr),
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
        .clk(clk),
        .rst(rst),
        .tx_mode(sram_tx_mode),
        .rd_addr(sram2_rd_addr),
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

    sram_test_probes i_probes (
        .probe(probe_sig),
        .source(source_sig)
    );

    sram_test_probes2 i_probes2 (
        .probe(probe2_sig),
        .source(source2_sig)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            vio_wr_enable_meta <= 0;
            vio_wr_enable_sync <= 0;
            vio_wr_enable_sync2 <= 0;
            sram1_wr_valid <= 0;
        end else begin
            vio_wr_enable_meta <= source2_sig[0];
            vio_wr_enable_sync <= vio_wr_enable_meta;
            vio_wr_enable_sync2 <= vio_wr_enable_sync;
            if (vio_wr_enable_sync && !vio_wr_enable_sync2)
                sram1_wr_valid <= 1;
            else if (sram1_wr_ready)
                sram1_wr_valid <= 0;
        end
    end

endmodule
