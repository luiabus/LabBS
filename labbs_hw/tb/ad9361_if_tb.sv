`timescale 1ns/1ps

// vsim -voptargs=+acc glbl ad9361_if_tb -L unisims_ver

module ad9361_if_tb;
    logic                   sys_clk = 0; // input
    logic                   rst = 1; // input

    logic [11:0]            dac0_data0_i = '0; // input
    logic [11:0]            dac0_data0_q = 'h555; // input
    logic [11:0]            dac0_data1_i = '0; // input
    logic [11:0]            dac0_data1_q = '0; // input
    logic [11:0]            dac1_data0_i = '0; // input
    logic [11:0]            dac1_data0_q = '0; // input
    logic [11:0]            dac1_data1_i = '0; // input
    logic [11:0]            dac1_data1_q = '0; // input

    logic                   rx_clk_in_0_p = 0; // input
    wire                    rx_clk_in_0_n = ~rx_clk_in_0_p; // input
    logic                   rx_frame_in_0_p; // input
    logic                   rx_frame_in_0_n; // input
    logic [5:0]             rx_data_in_0_p; // input
    logic [5:0]             rx_data_in_0_n; // input

    logic                   tx_clk_out_0_p; // output
    logic                   tx_clk_out_0_n; // output
    logic                   tx_frame_out_0_p; // output
    logic                   tx_frame_out_0_n; // output
    logic [5:0]             tx_data_out_0_p; // output
    logic [5:0]             tx_data_out_0_n; // output

    logic                   rx_clk_in_1_p; // input
    logic                   rx_clk_in_1_n; // input
    logic                   rx_frame_in_1_p; // input
    logic                   rx_frame_in_1_n; // input
    logic [5:0]             rx_data_in_1_p; // input
    logic [5:0]             rx_data_in_1_n; // input

    logic                   tx_clk_out_1_p; // output
    logic                   tx_clk_out_1_n; // output
    logic                   tx_frame_out_1_p; // output
    logic                   tx_frame_out_1_n; // output
    logic [5:0]             tx_data_out_1_p; // output
    logic [5:0]             tx_data_out_1_n; // output

    ad9361_if dut (
        .sys_clk,
        .rst,
        .dac0_data0_i,
        .dac0_data0_q,
        .dac0_data1_i,
        .dac0_data1_q,
        .dac1_data0_i,
        .dac1_data0_q,
        .dac1_data1_i,
        .dac1_data1_q,
        .rx_clk_in_0_p,
        .rx_clk_in_0_n,
        .rx_frame_in_0_p,
        .rx_frame_in_0_n,
        .rx_data_in_0_p,
        .rx_data_in_0_n,
        .tx_clk_out_0_p,
        .tx_clk_out_0_n,
        .tx_frame_out_0_p,
        .tx_frame_out_0_n,
        .tx_data_out_0_p,
        .tx_data_out_0_n,
        .rx_clk_in_1_p,
        .rx_clk_in_1_n,
        .rx_frame_in_1_p,
        .rx_frame_in_1_n,
        .rx_data_in_1_p,
        .rx_data_in_1_n,
        .tx_clk_out_1_p,
        .tx_clk_out_1_n,
        .tx_frame_out_1_p,
        .tx_frame_out_1_n,
        .tx_data_out_1_p,
        .tx_data_out_1_n
    );

    // assign rx_clk_in_0_p = tx_clk_out_0_p;
    // assign rx_clk_in_0_n = tx_clk_out_0_n;
    assign rx_frame_in_0_p = tx_frame_out_0_p;
    assign rx_frame_in_0_n = tx_frame_out_0_n;
    assign rx_data_in_0_p = tx_data_out_0_p;
    assign rx_data_in_0_n = tx_data_out_0_n;

    assign rx_clk_in_1_p = rx_clk_in_0_p;
    assign rx_clk_in_1_n = rx_clk_in_0_n;
    assign rx_frame_in_1_p = tx_frame_out_1_p;
    assign rx_frame_in_1_n = tx_frame_out_1_n;
    assign rx_data_in_1_p = tx_data_out_1_p;
    assign rx_data_in_1_n = tx_data_out_1_n;


    initial forever #10ns rx_clk_in_0_p = !rx_clk_in_0_p;
    initial forever #5ns sys_clk = !sys_clk;

    initial begin
        #100ns;
        @(posedge sys_clk);
        rst <= 0;
    end

endmodule : ad9361_if_tb