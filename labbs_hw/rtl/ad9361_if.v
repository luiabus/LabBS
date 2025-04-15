`timescale 1ns / 1ps

module ad9361_if (
    input                   sys_clk,
    input                   rst,

    input [11:0]            dac0_data0_i,
    input [11:0]            dac0_data0_q,
    input [11:0]            dac0_data1_i,
    input [11:0]            dac0_data1_q,
    input [11:0]            dac1_data0_i,
    input [11:0]            dac1_data0_q,
    input [11:0]            dac1_data1_i,
    input [11:0]            dac1_data1_q,
    output                  dac_valid,
    output                  rf_clk,

    input                   rx_clk_in_0_p,
    input                   rx_clk_in_0_n,
    input                   rx_frame_in_0_p,
    input                   rx_frame_in_0_n,
    input       [ 5:0]      rx_data_in_0_p,
    input       [ 5:0]      rx_data_in_0_n,

    output                  tx_clk_out_0_p,
    output                  tx_clk_out_0_n,
    output                  tx_frame_out_0_p,
    output                  tx_frame_out_0_n,
    output      [ 5:0]      tx_data_out_0_p,
    output      [ 5:0]      tx_data_out_0_n,

    input                   rx_clk_in_1_p,
    input                   rx_clk_in_1_n,
    input                   rx_frame_in_1_p,
    input                   rx_frame_in_1_n,
    input       [ 5:0]      rx_data_in_1_p,
    input       [ 5:0]      rx_data_in_1_n,

    output                  tx_clk_out_1_p,
    output                  tx_clk_out_1_n,
    output                  tx_frame_out_1_p,
    output                  tx_frame_out_1_n,
    output      [ 5:0]      tx_data_out_1_p,
    output      [ 5:0]      tx_data_out_1_n
);

    wire l_clk;
    wire ll_clk;

    assign rf_clk = l_clk;

    reg [1:0] dac_valid_cnt = 0;
    reg dac_valid_reg = 0;
    assign dac_valid = dac_valid_reg;

    always @(posedge rf_clk) begin
        // if (rst) begin
        //     dac_valid_cnt <= '0;
        //     dac_valid_reg <= 0;
        // end else begin
            dac_valid_cnt <= dac_valid_cnt + 1;
            dac_valid_reg <= dac_valid_cnt == 'b11;
        // end
    end

    wire adc0_valid_s;
    wire [47:0] adc0_data_s;
    wire adc0_status_s;
    wire [47:0] dac0_data_s;
    wire dac0_valid_s;

    wire adc1_valid_s;
    wire [47:0] adc1_data_s;
    wire adc1_status_s_1;
    wire [47:0] dac1_data_s;
    wire dac1_valid_s;

    wire adc0_ddr_edgesel_s = 0;
    wire adc1_ddr_edgesel_s = 0;

    assign dac0_valid_s = dac_valid_reg;
    assign dac1_valid_s = dac_valid_reg;
    assign dac0_data_s = {dac0_data1_q, dac0_data1_i, dac0_data0_q, dac0_data0_i};
    assign dac1_data_s = {dac1_data1_q, dac1_data1_i, dac1_data0_q, dac1_data0_i};

    axi_ad9361_lvds_if #(
        .DEVICE_TYPE (0),
        .DAC_IODELAY_ENABLE (0),
        .IO_DELAY_GROUP ("dev_if_delay_group_0"),
        .USE_SSI_CLK (1)
    ) i_dev_if_0 (
        .rx_clk_in_p (rx_clk_in_0_p),
        .rx_clk_in_n (rx_clk_in_0_n),
        .rx_frame_in_p (rx_frame_in_0_p),
        .rx_frame_in_n (rx_frame_in_0_n),
        .rx_data_in_p (rx_data_in_0_p),
        .rx_data_in_n (rx_data_in_0_n),
        .tx_clk_out_p (tx_clk_out_0_p),
        .tx_clk_out_n (tx_clk_out_0_n),
        .tx_frame_out_p (tx_frame_out_0_p),
        .tx_frame_out_n (tx_frame_out_0_n),
        .tx_data_out_p (tx_data_out_0_p),
        .tx_data_out_n (tx_data_out_0_n),
        .enable (),
        .txnrx (),
        .rst (rst),
        .clk (l_clk),
        .l_clk (l_clk),
        .adc_valid (adc0_valid_s),
        .adc_data (adc0_data_s),
        .adc_status (adc0_status_s),
        .adc_r1_mode (1'b0),
        .adc_ddr_edgesel (adc0_ddr_edgesel_s),
        .dac_valid (dac0_valid_s),
        .dac_data (dac0_data_s),
        .dac_clksel (1'b1),// ?
        .dac_r1_mode (1'b0),
        .tdd_enable (1'b0),
        .tdd_txnrx (1'b0),
        .tdd_mode (1'b0),
        .mmcm_rst (1'b0),
        .up_clk (sys_clk),
        .up_rstn (1'b0),
        .up_enable (1'b0),
        .up_txnrx (1'b0),
        .up_adc_dld (7'b0),
        .up_adc_dwdata (35'b0),
        .up_adc_drdata (),
        .up_dac_dld (10'b0),
        .up_dac_dwdata (50'b0),
        .up_dac_drdata (),
        .delay_clk (sys_clk),
        .delay_rst (1'b0),
        .delay_locked (),
        .up_drp_sel (1'b0),
        .up_drp_wr (1'b0),
        .up_drp_addr (12'b0),
        .up_drp_wdata (32'b0),
        .up_drp_rdata (),
        .up_drp_ready (),
        .up_drp_locked()
    );
        
    axi_ad9361_lvds_if #(
        .DEVICE_TYPE (0),
        .DAC_IODELAY_ENABLE (0),
        .IO_DELAY_GROUP ("dev_if_delay_group_1"),
        .USE_SSI_CLK (0)
    ) i_dev_if_1 (
        .rx_clk_in_p (rx_clk_in_1_p),
        .rx_clk_in_n (rx_clk_in_1_n),
        .rx_frame_in_p (rx_frame_in_1_p),
        .rx_frame_in_n (rx_frame_in_1_n),
        .rx_data_in_p (rx_data_in_1_p),
        .rx_data_in_n (rx_data_in_1_n),
        .tx_clk_out_p (tx_clk_out_1_p),
        .tx_clk_out_n (tx_clk_out_1_n),
        .tx_frame_out_p (tx_frame_out_1_p),
        .tx_frame_out_n (tx_frame_out_1_n),
        .tx_data_out_p (tx_data_out_1_p),
        .tx_data_out_n (tx_data_out_1_n),
        .enable (),
        .txnrx (),
        .rst (rst),
        .clk (l_clk),
        .l_clk (ll_clk),
        .adc_valid (adc1_valid_s),
        .adc_data (adc1_data_s),
        .adc_status (adc1_status_s),
        .adc_r1_mode (1'b0),
        .adc_ddr_edgesel (adc1_ddr_edgesel_s),
        .dac_valid (dac1_valid_s),
        .dac_data (dac1_data_s),
        .dac_clksel (1'b1),// ?
        .dac_r1_mode (1'b0),
        .tdd_enable (1'b0),
        .tdd_txnrx (1'b0),
        .tdd_mode (1'b0),
        .mmcm_rst (1'b0),
        .up_clk (sys_clk),
        .up_rstn (1'b0),
        .up_enable (1'b0),
        .up_txnrx (1'b0),
        .up_adc_dld (7'b0),
        .up_adc_dwdata (35'b0),
        .up_adc_drdata (),
        .up_dac_dld (10'b0),
        .up_dac_dwdata (50'b0),
        .up_dac_drdata (),
        .delay_clk (sys_clk),
        .delay_rst (1'b0),
        .delay_locked (),
        .up_drp_sel (1'b0),
        .up_drp_wr (1'b0),
        .up_drp_addr (12'b0),
        .up_drp_wdata (32'b0),
        .up_drp_rdata (),
        .up_drp_ready (),
        .up_drp_locked()
    );

endmodule
