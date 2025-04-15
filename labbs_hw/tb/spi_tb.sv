`timescale 1ns/1ps

module spi_tb;
    logic       sys_clk_40 = 1;
    logic       sys_clk_200 = 1;
    logic       spi_csn;
    logic       spi_clk;
    logic       spi_mosi;
    logic       spi_miso = 1;
    logic       sync_f = 1;
    logic       sync;
    logic       ad_init_finish;
    logic       enable;
    logic       txnrx;
    logic       resetb;
    logic [7:0] readback;

    ad9361_spi_init dut (
        .sys_clk_40,
        .sys_clk_200,
        .spi_csn,
        .spi_clk,
        .spi_mosi,
        .spi_miso,
        .sync_f,
        .sync,
        .ad_init_finish,
        .enable,
        .txnrx,
        .resetb,
        .readback
    );

    initial forever #(25ns/2) sys_clk_40 = !sys_clk_40;
    initial forever #(5ns/2) sys_clk_200 = !sys_clk_200;

endmodule : spi_tb