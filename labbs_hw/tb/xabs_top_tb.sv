`timescale 1ns/1ps

// vsim -voptargs=+acc glbl xabs_top_tb -L unisims_ver

// vopt +acc glbl xabs_top_tb -L unisims_ver -o x

module xabs_top_tb;
    // parameter integer PCODE_LEN = 40920;
    // parameter integer PCODE_REPEATS = 10;
    // parameter integer MESSAGE_LEN = 120;
    parameter integer PCODE_LEN = 120;
    parameter integer PCODE_REPEATS = 5;
    parameter integer MESSAGE_LEN = 100;

    localparam int C_S_AXI_DATA_WIDTH = 32;
    localparam int C_S_AXI_ADDR_WIDTH = 16;

    logic                               S_AXI_ACLK = 0; // input
    logic                               S_AXI_ARESETN = 0; // input

    logic [C_S_AXI_ADDR_WIDTH-1:0]      S_AXI_AWADDR; // input
    logic                               S_AXI_AWVALID = 0; // input
    logic                               S_AXI_AWREADY; // output

    logic [C_S_AXI_DATA_WIDTH-1:0]      S_AXI_WDATA;    // input
    logic [(C_S_AXI_DATA_WIDTH/8)-1:0]  S_AXI_WSTRB; // input
    logic                               S_AXI_WVALID = 0; // input
    logic                               S_AXI_WREADY; // output

    logic [1:0]                         S_AXI_BRESP; // output
    logic                               S_AXI_BVALID; // output
    logic                               S_AXI_BREADY = 0; // input

    logic [C_S_AXI_ADDR_WIDTH-1:0]      S_AXI_ARADDR; // input
    logic                               S_AXI_ARVALID = 0; // input
    logic                               S_AXI_ARREADY; // output
    
    logic [C_S_AXI_DATA_WIDTH-1:0]      S_AXI_RDATA; // output
    logic [1:0]                         S_AXI_RRESP; // output
    logic                               S_AXI_RVALID; // output
    logic                               S_AXI_RREADY = 0; // input

    logic                   pps_in = 0; // input
    logic signed [11:0]     pcode_hval = 2047; // input
    logic signed [11:0]     pcode_lval = -2047; // input

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

    wire                    rx_clk_in_1_p = rx_clk_in_0_p; // input
    wire                    rx_clk_in_1_n = rx_clk_in_0_n; // input
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

    logic                   dbg_rf_clk;
    logic [7:0]             dbg_dac_data_sel = 0;
    logic [11:0]            dbg_dac_data;

    assign rx_frame_in_0_p = tx_frame_out_0_p;
    assign rx_frame_in_0_n = tx_frame_out_0_n;
    assign rx_data_in_0_p = tx_data_out_0_p;
    assign rx_data_in_0_n = tx_data_out_0_n;
    assign rx_frame_in_1_p = tx_frame_out_1_p;
    assign rx_frame_in_1_n = tx_frame_out_1_n;
    assign rx_data_in_1_p = tx_data_out_1_p;
    assign rx_data_in_1_n = tx_data_out_1_n;

    xabs_top # (
        .PCODE_LEN(PCODE_LEN),
        .PCODE_REPEATS(PCODE_REPEATS),
        .MESSAGE_LEN(MESSAGE_LEN)
    ) dut (
        .S_AXI_ACLK,
        .S_AXI_ARESETN,
        .S_AXI_AWADDR,
        .S_AXI_AWVALID,
        .S_AXI_AWREADY,
        .S_AXI_WDATA,   
        .S_AXI_WSTRB,
        .S_AXI_WVALID,
        .S_AXI_WREADY,
        .S_AXI_BRESP,
        .S_AXI_BVALID,
        .S_AXI_BREADY,
        .S_AXI_ARADDR,
        .S_AXI_ARVALID,
        .S_AXI_ARREADY,
        .S_AXI_RDATA,
        .S_AXI_RRESP,
        .S_AXI_RVALID,
        .S_AXI_RREADY,
        .pps_in,
        .pcode_hval,
        .pcode_lval,
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
        .tx_data_out_1_n,
        .dbg_rf_clk,
        .dbg_dac_data_sel,
        .dbg_dac_data
    );

    task read_axi_reg(input  int unsigned offset,
                      output int unsigned rd_data); // TODO: size
        @(posedge S_AXI_ACLK);
        S_AXI_ARVALID <= 1;
        S_AXI_ARADDR  <= offset;
        S_AXI_RREADY  <= 1;
        do begin
            @(posedge S_AXI_ACLK);
        end while (S_AXI_ARREADY == 0);
        S_AXI_ARVALID <= 0;
        do begin
            @(posedge S_AXI_ACLK);
        end while (S_AXI_RVALID == 0);
        S_AXI_RREADY  <= 0;
        if (S_AXI_RRESP != 0) begin
            $error("read response from AXI4-Lite interface is unexpected");
        end
        rd_data = S_AXI_RDATA;
    endtask : read_axi_reg

    task write_axi_reg(input int unsigned offset,
                       input int unsigned wr_data); // TODO: size
        // @(posedge S_AXI_ACLK);
        fork
            begin
                S_AXI_AWVALID <= 1;
                S_AXI_AWADDR  <= offset;
                @(posedge S_AXI_ACLK iff S_AXI_AWREADY);
                S_AXI_AWVALID <= 0;
            end
            begin
                S_AXI_WVALID  <= 1;
                S_AXI_WDATA   <= wr_data;
                S_AXI_WSTRB   <= '1;
                @(posedge S_AXI_ACLK iff S_AXI_WREADY);
                S_AXI_WVALID  <= 0;
            end
        join

        S_AXI_BREADY  <= 1;
        @(posedge S_AXI_ACLK iff S_AXI_BVALID);
        S_AXI_BREADY  <= 0;

        if (S_AXI_BRESP != 0) begin
            $error("write response from AXI4-Lite interface is unexpected");
        end
    endtask : write_axi_reg


    // initial forever #(1s/(40.92e6 * 4)/2) rx_clk_in_0_p = !rx_clk_in_0_p;
    initial forever #3050ps rx_clk_in_0_p = !rx_clk_in_0_p;
    initial forever #3.33ns S_AXI_ACLK = !S_AXI_ACLK;

    initial begin
        #200ns;
        @(posedge S_AXI_ACLK);
        S_AXI_ARESETN <= 1;

        #100ns;
        @(posedge S_AXI_ACLK);
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 256 / 4; j++) begin
                write_axi_reg(32'h1000 + i * 'h100 + j * 4, {16'hf550, j[7:0], 8'h50}); // message
            end
        end
        write_axi_reg(32'h0, {8'd0, 8'd12, 8'd34, 8'd56}); // UTC time
        write_axi_reg(32'h4, {8'd0, 8'd24, 8'd11, 8'd22});
        write_axi_reg(32'h8, {1'b1, 31'h0});
        write_axi_reg(32'hc, {32'b111}); // channel enable
    end

    initial begin
        #12us;
        forever begin
            pps_in = 1;
            #0.1s;
            pps_in = 0;
            #0.9s;
        end
    end

endmodule : xabs_top_tb
