`timescale 1ns/1ps

// vsim -voptargs=+acc sram_test_top_tb

module sram_test_top_tb;
    logic           SYS_CLK = 0; // input
    logic           SYS_RST = 1; // input

    logic          led0; // output
    logic          led1; // output

    logic [7:0]    INT_CE_N; // output

    logic [3:0]    STATUS1; // output
    logic [3:0]    STATUS2; // output
    logic [3:0]    STATUS3; // output
    logic [3:0]    STATUS4; // output
    logic [3:0]    STATUS5; // output
    logic [3:0]    STATUS6; // output
    logic [3:0]    STATUS7; // output
    logic [3:0]    STATUS8; // output

    logic [1:0]    MESSAGE1; // output
    logic [1:0]    MESSAGE2; // output
    logic [1:0]    MESSAGE3; // output
    logic [1:0]    MESSAGE4; // output
    logic [1:0]    MESSAGE5; // output
    logic [1:0]    MESSAGE6; // output
    logic [1:0]    MESSAGE7; // output
    logic [1:0]    MESSAGE8; // output
   
    logic [7:0]    DA_VALID; // output

    logic           UTC_UART_RXD = 1; // input
    logic           UTC_UART_TXD; // output
    logic           PPS_IN = 0; // input

    wire  [31:0]   SRAM_DATA;
    logic [17:0]   SRAM_ADDR; // output
    logic          SRAM_CE_N; // output
    logic          SRAM_CE2_N; // output
    logic          SRAM_OE_N; // output
    logic          SRAM_SW_A_N; // output
    logic          SRAM_SW_B_N; // output
    logic          SRAM_SW_C_N; // output
    logic          SRAM_SW_D_N; // output
    logic          SRAM_WE_N; // output

    wire  [31:0]   SRAM1_DATA;
    logic [17:0]   SRAM1_ADDR; // output
    logic          SRAM1_CE_N; // output
    logic          SRAM1_CE2_N; // output
    logic          SRAM1_OE_N; // output
    logic          SRAM1_SW_A_N; // output
    logic          SRAM1_SW_B_N; // output
    logic          SRAM1_SW_C_N; // output
    logic          SRAM1_SW_D_N; // output
    logic          SRAM1_WE_N; // output

    sram_test_top dut (
        .SYS_CLK,
        .SYS_RST,
        .led0,
        .led1,
        .INT_CE_N, // unused
        .STATUS1,
        .STATUS2,
        .STATUS3,
        .STATUS4,
        .STATUS5,
        .STATUS6,
        .STATUS7,
        .STATUS8,
        .MESSAGE1,
        .MESSAGE2,
        .MESSAGE3,
        .MESSAGE4,
        .MESSAGE5,
        .MESSAGE6,
        .MESSAGE7,
        .MESSAGE8,
        .DA_VALID,   //[0] - 1, [1] - 2, ... , [7] - 8
        .UTC_UART_RXD,
        .UTC_UART_TXD,
        .PPS_IN,
        .SRAM_DATA, //高8位连接到了J18的高8位引脚
        .SRAM_ADDR,
        .SRAM_CE_N,
        .SRAM_CE2_N,
        .SRAM_OE_N,
        .SRAM_SW_A_N,
        .SRAM_SW_B_N,
        .SRAM_SW_C_N,
        .SRAM_SW_D_N,
        .SRAM_WE_N,
        .SRAM1_DATA, //高8位连接到了J18的次高8位引脚
        .SRAM1_ADDR,
        .SRAM1_CE_N,
        .SRAM1_CE2_N,
        .SRAM1_OE_N,
        .SRAM1_SW_A_N,
        .SRAM1_SW_B_N,
        .SRAM1_SW_C_N,
        .SRAM1_SW_D_N,
        .SRAM1_WE_N
    );

    initial forever #(1s/40.92e6/2) SYS_CLK = !SYS_CLK;

    initial begin
        #1us;
        @(posedge SYS_CLK) SYS_RST <= 0;
        #1us
        dut.i_probes.source_reg = 'h11223344;
        dut.i_probes2.source_reg = 1;
        #1us
        dut.i_probes2.source_reg = 0;
        #1us
        dut.i_probes2.source_reg = 2;

        #1us
        dut.i_probes.source_reg = 'h11223344;

        #1us
        dut.i_probes.source_reg = 'h00112233;
    end

endmodule : sram_test_top_tb


module sram_test_probes (
    input  [31:0] probe,
    output [31:0] source
);
    logic [31:0] source_reg = 0;
    assign source = source_reg;
endmodule

module sram_test_probes2 (
    input  [7:0] probe,
    output [7:0] source
);
    logic [7:0] source_reg = 0;
    assign source = source_reg;
endmodule
