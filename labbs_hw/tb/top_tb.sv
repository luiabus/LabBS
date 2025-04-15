`timescale 1ns/1ps

// vsim -voptargs=+acc top_tb

module top_tb;
    logic          SYS_CLK = 0; // input 
    logic          SYS_RST = 1; // input 

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

    logic          UTC_UART_RXD = 1; // input 
    logic          UTC_UART_TXD; // output
    logic          PPS_IN = 0; // input 

    wire  [31:0]   SRAM_DATA; //高8位连接到了J18的高8位引脚
    logic [17:0]   SRAM_ADDR; // output
    logic          SRAM_CE_N; // output
    logic          SRAM_CE2_N; // output
    logic          SRAM_OE_N; // output
    logic          SRAM_SW_A_N; // output
    logic          SRAM_SW_B_N; // output
    logic          SRAM_SW_C_N; // output
    logic          SRAM_SW_D_N; // output
    logic          SRAM_WE_N; // output

    wire  [31:0]   SRAM1_DATA; //高8位连接到了J18的次高8位引脚
    logic [17:0]   SRAM1_ADDR; // output
    logic          SRAM1_CE_N; // output
    logic          SRAM1_CE2_N; // output
    logic          SRAM1_OE_N; // output
    logic          SRAM1_SW_A_N; // output
    logic          SRAM1_SW_B_N; // output
    logic          SRAM1_SW_C_N; // output
    logic          SRAM1_SW_D_N; // output
    logic          SRAM1_WE_N; // output

    // ad9361
    logic [3:0]    AD9361_SW; // output
    logic [3:0]    AD9361_TX_PD1800; // output
    logic [3:0]    AD9361_TX_PD3500; // output

    logic          AD9361_MOSI_ADI1; // output
    logic          AD9361_MISO_ADI1; // input 
    logic          AD9361_CLK_ADI1; // output
    logic [1:0]    AD9361_CSB1; // output
    logic [1:0]    AD9361_CSB2; // output

    logic          AD9361_MOSI_ADI3; // output
    logic          AD9361_MISO_ADI3; // input 
    logic          AD9361_CLK_ADI3; // output
    logic [1:0]    AD9361_CSB3; // output
    logic [1:0]    AD9361_CSB4; // output

    logic          AD9361_MOSI_ADI5; // output
    logic          AD9361_MISO_ADI5; // input 
    logic          AD9361_CLK_ADI5; // output
    logic [1:0]    AD9361_CSB5; // output
    logic [1:0]    AD9361_CSB6; // output

    logic          AD9361_MOSI_ADI7; // output
    logic          AD9361_MISO_ADI7; // input 
    logic          AD9361_CLK_ADI7; // output
    logic [1:0]    AD9361_CSB7; // output
    logic [1:0]    AD9361_CSB8; // output

    logic [3:0]    AD9361_RESET_AD9361; // output
    logic          AD9361_SYNC; // output
    logic [1:0]    AD9361_TX_FRAME_FPGA; // output
    logic [1:0]    AD9361_FB_CLK_FPGA; // output

    top dut (
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
        .SRAM1_WE_N,

        // ad9361
        .AD9361_SW,
        .AD9361_TX_PD1800,
        .AD9361_TX_PD3500,

        .AD9361_MOSI_ADI1,
        .AD9361_MISO_ADI1,
        .AD9361_CLK_ADI1,
        .AD9361_CSB1,
        .AD9361_CSB2,

        .AD9361_MOSI_ADI3,
        .AD9361_MISO_ADI3,
        .AD9361_CLK_ADI3,
        .AD9361_CSB3,
        .AD9361_CSB4,

        .AD9361_MOSI_ADI5,
        .AD9361_MISO_ADI5,
        .AD9361_CLK_ADI5,
        .AD9361_CSB5,
        .AD9361_CSB6,

        .AD9361_MOSI_ADI7,
        .AD9361_MISO_ADI7,
        .AD9361_CLK_ADI7,
        .AD9361_CSB7,
        .AD9361_CSB8,

        .AD9361_RESET_AD9361,
        .AD9361_SYNC,
        .AD9361_TX_FRAME_FPGA,      //用于反馈给AD9361 20.46M
        .AD9361_FB_CLK_FPGA         //用于寄存码字 40.92M
    );

    initial forever #(1s/40.92e6/2) SYS_CLK = !SYS_CLK;

    initial begin
        #1us;
        @(posedge SYS_CLK) SYS_RST <= 0;
    end

    initial begin
        AD9361_MISO_ADI1 = 0;
        AD9361_MISO_ADI3 = 0;
        AD9361_MISO_ADI5 = 0;
        AD9361_MISO_ADI7 = 0;
    end

    int clk_div = 355;

    task automatic uart_send_string(input string str/*input byte unsigned char*/);
        // $info("tx");
        foreach (str[i]) begin
            byte unsigned char = str[i];
            // $info("send char $%0d", i);

            // tx_mb.put(char);
            // send_count++;
            @(posedge SYS_CLK);
            UTC_UART_RXD <= 0;
            for (int i = 0; i < 8; i++) begin
                repeat (clk_div + 1) @(posedge SYS_CLK);
                UTC_UART_RXD <= char;
                char >>= 1;
            end
            repeat (clk_div + 1) @(posedge SYS_CLK);
            UTC_UART_RXD <= 1;
            repeat (clk_div + 1) @(posedge SYS_CLK);
        end
    endtask : uart_send_string

    initial begin
        automatic int hh = 10, mm = 20, ss = 15;
        automatic time last_time;
        automatic time current_time;
        #0.1us;
        @(posedge SYS_CLK iff !dut.tx_rst);
        #1us;
        forever begin
            automatic string tx_str;
            last_time = $time;
            tx_str = $sformatf("$GPGGA,%02d%02d%02d.00,4717.11399,N,00833.91590,E,1,08,1.01,499.6,M,48.0,M,,*5B\r\n", hh, mm, ss);
            uart_send_string(tx_str);
            current_time = $time;

            fork
                begin
                    #0.1s;
                    PPS_IN = 1;
                    #0.1s;
                    PPS_IN = 0;
                end
                #(1s - (current_time - last_time));
            join

            ss++;
            if (ss >= 60) begin
                ss = 0;
                mm++;
            end
            if (mm >= 60) begin
                mm = 0;
                hh++;
            end
            if (hh >= 24) begin
                hh = 0;
            end
        end
    end

endmodule : top_tb
