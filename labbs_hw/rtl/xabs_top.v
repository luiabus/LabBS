module xabs_top #(
    parameter integer PCODE_LEN = 40920,
    parameter integer PCODE_REPEATS = 10,
    parameter integer MESSAGE_LEN = 120,
    parameter integer CYCLES_500uS = 81840,

    localparam integer C_S_AXI_DATA_WIDTH = 32,
    localparam integer C_S_AXI_ADDR_WIDTH = 16
) (
    input wire S_AXI_ACLK,
    input wire S_AXI_ARESETN,

    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    // input wire [2:0]                            S_AXI_AWPROT,
    input  wire                          S_AXI_AWVALID,
    output wire                          S_AXI_AWREADY,

    input  wire [    C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  wire                              S_AXI_WVALID,
    output wire                              S_AXI_WREADY,

    output wire [1:0] S_AXI_BRESP,
    output wire       S_AXI_BVALID,
    input  wire       S_AXI_BREADY,

    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    // input wire [2:0]                            S_AXI_ARPROT,
    input  wire                          S_AXI_ARVALID,
    output wire                          S_AXI_ARREADY,

    output wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output wire [                   1:0] S_AXI_RRESP,
    output wire                          S_AXI_RVALID,
    input  wire                          S_AXI_RREADY,

    // input                   sys_clk,
    // input                   rst,
    input pps_in,
    // input                   ad_init_finish,

    input signed [11:0] pcode_hval,
    input signed [11:0] pcode_lval,

    input       rx_clk_in_0_p,
    input       rx_clk_in_0_n,
    input       rx_frame_in_0_p,
    input       rx_frame_in_0_n,
    input [5:0] rx_data_in_0_p,
    input [5:0] rx_data_in_0_n,

    output       tx_clk_out_0_p,
    output       tx_clk_out_0_n,
    output       tx_frame_out_0_p,
    output       tx_frame_out_0_n,
    output [5:0] tx_data_out_0_p,
    output [5:0] tx_data_out_0_n,

    input       rx_clk_in_1_p,
    input       rx_clk_in_1_n,
    input       rx_frame_in_1_p,
    input       rx_frame_in_1_n,
    input [5:0] rx_data_in_1_p,
    input [5:0] rx_data_in_1_n,

    output       tx_clk_out_1_p,
    output       tx_clk_out_1_n,
    output       tx_frame_out_1_p,
    output       tx_frame_out_1_n,
    output [5:0] tx_data_out_1_p,
    output [5:0] tx_data_out_1_n,

    output pps_out,

    output reg [ 3:0] dbg_dac_valid_ctr,
    output            dbg_rf_clk,
    input      [ 7:0] dbg_dac_data_sel,
    output reg [11:0] dbg_dac_data
);

    wire rf_clk;
    wire rf_rst;

    cdc_reset #(
        .ACTIVE_HIGH(1)
    ) i_rf_rst (
        .reset_in(!S_AXI_ARESETN),
        .clk(rf_clk),
        .reset_out(rf_rst)
    );

    //无效：后续模块可以实现相同功??
    //   wire pps_in_p;
    //   // wire pps_ext_in_n;
    //   //PPS探测状???机
    //   parameter IDLE = 3'b100, DTCT = 3'b010, WAITLOW = 3'b001;
    //   reg [ 2:0] state;
    //   reg [30:0] waitCntr;
    //   always @(posedge rf_clk) begin
    //     case (state)
    //       IDLE: begin  // 空闲状???，等待PPS触发
    //         if (delay[2]) begin
    //           state <= DTCT;
    //         end else begin
    //           state <= IDLE;
    //         end
    //       end
    //       DTCT: begin  // 探测到PPS触发，锁??10ms抑制毛刺
    //         if (waitCntr < 20 * CYCLES_500uS) begin
    //           // state    <= DTCT;
    //           waitCntr <= waitCntr + 1;
    //         end else begin
    //           state <= WAITLOW;
    //           // waitCntr <= waitCntr - 1;
    //         end
    //       end
    //       WAITLOW: begin  // 等待至少10ms的低电平，回归空闲状??
    //         if (!pps_in) begin
    //           if (waitCntr > 0) begin
    //             waitCntr <= waitCntr - 1;
    //             // state    <= WAITLOW;
    //           end else begin
    //             state <= IDLE;
    //           end
    //         end else begin
    //           waitCntr <= 20 * CYCLES_500uS;
    //           // state    <= WAITLOW;
    //         end
    //       end
    //       default: begin
    //         state    <= IDLE;
    //         waitCntr <= 0;
    //       end
    //     endcase
    //   end

    //   //抓取上升沿，https://blog.csdn.net/phenixyf/article/details/46634257
    //   reg [2:0] delay;
    //   always @(posedge rf_clk or posedge rf_rst_front) begin
    //     if (rf_rst_front) begin
    //       delay <= 0;
    //     end else begin
    //       delay <= {delay[1:0], pps_in};  // ori_signal是原信号
    //     end
    //   end
    //   assign pps_in_p = state[2] && delay[1] && (~delay[2]);  // 原信号（外部PPS）上升沿位置处产生的pulse信号，仅在IDLE状态下有效
    //   // assign pps_ext_in_n = (~delay[1]) && delay[2];  // 无效：未加入状态机 原信号（外部PPS）下降沿位置处产生的pulse信号




    wire        utc_time_update;
    wire [ 4:0] utc_time_hour;
    wire [ 5:0] utc_time_minute;
    wire [ 5:0] utc_time_second;
    wire [ 4:0] utc_time_day;
    wire [ 3:0] utc_time_month;
    wire [ 7:0] utc_time_year;
    wire        utc_time_update_cdc;
    wire [ 4:0] utc_time_hour_cdc;
    wire [ 5:0] utc_time_minute_cdc;
    wire [ 5:0] utc_time_second_cdc;
    wire [ 4:0] utc_time_day_cdc;
    wire [ 3:0] utc_time_month_cdc;
    wire [ 7:0] utc_time_year_cdc;
    wire [ 7:0] channel_enable;
    wire        tstamp_patch_en;
    wire [ 7:0] channel_enable_cdc;
    wire        tstamp_patch_en_cdc;
    wire        msg_wr_en;
    wire [ 3:0] msg_wr_strb;
    wire [ 2:0] msg_channel;
    wire [ 7:0] msg_offset;
    wire [31:0] msg_data;

    bs_axi_if i_axi (
        .s_axi_aclk(S_AXI_ACLK),
        .s_axi_aresetn(S_AXI_ARESETN),
        .s_axi_awaddr(S_AXI_AWADDR),
        .s_axi_awvalid(S_AXI_AWVALID),
        .s_axi_awready(S_AXI_AWREADY),
        .s_axi_wdata(S_AXI_WDATA),
        .s_axi_wstrb(S_AXI_WSTRB),
        .s_axi_wvalid(S_AXI_WVALID),
        .s_axi_wready(S_AXI_WREADY),
        .s_axi_bresp(S_AXI_BRESP),
        .s_axi_bvalid(S_AXI_BVALID),
        .s_axi_bready(S_AXI_BREADY),
        .s_axi_araddr(S_AXI_ARADDR),
        .s_axi_arvalid(S_AXI_ARVALID),
        .s_axi_arready(S_AXI_ARREADY),
        .s_axi_rdata(S_AXI_RDATA),
        .s_axi_rresp(S_AXI_RRESP),
        .s_axi_rvalid(S_AXI_RVALID),
        .s_axi_rready(S_AXI_RREADY),
        .utc_time_update(utc_time_update),
        .utc_time_hour(utc_time_hour),
        .utc_time_minute(utc_time_minute),
        .utc_time_second(utc_time_second),
        .utc_time_day(utc_time_day),
        .utc_time_month(utc_time_month),
        .utc_time_year(utc_time_year),
        .channel_enable(channel_enable),
        .tstamp_patch_en(tstamp_patch_en),
        .msg_wr_en(msg_wr_en),
        .msg_wr_strb(msg_wr_strb),
        .msg_channel(msg_channel),
        .msg_offset(msg_offset),
        .msg_data(msg_data)
    );

    // parameter integer UTC_CDC_WIDTH = $bits(utc_time_year) + $bits(utc_time_month) + $bits(utc_time_day) + $bits(utc_time_second) + $bits(utc_time_minute) + $bits(utc_time_hour);
    localparam integer UTC_CDC_WIDTH = 34;

    cdc_multibit_valid #(
        .DATA_WIDTH(UTC_CDC_WIDTH)
    ) i_utc_cdc (
        .src_clk(S_AXI_ACLK),
        .src_rst(!S_AXI_ARESETN),
        .src_valid(utc_time_update),
        .src_data({
            utc_time_year,
            utc_time_month,
            utc_time_day,
            utc_time_second,
            utc_time_minute,
            utc_time_hour
        }),
        .dst_clk(rf_clk),
        .dst_valid(utc_time_update_cdc),
        .dst_data({
            utc_time_year_cdc,
            utc_time_month_cdc,
            utc_time_day_cdc,
            utc_time_second_cdc,
            utc_time_minute_cdc,
            utc_time_hour_cdc
        })
    );

    cdc_direct #(
        .WIDTH(8)
    ) i_chena_cdc (
        .signal_in(channel_enable),
        .clk(rf_clk),
        .signal_out(channel_enable_cdc)
    );

    cdc_direct #(
        .WIDTH(1)
    ) i_tspatch_cdc (
        .signal_in(tstamp_patch_en),
        .clk(rf_clk),
        .signal_out(tstamp_patch_en_cdc)
    );

    wire dac_valid;
    wire signed [11:0] dac0_data0_i;
    wire signed [11:0] dac0_data1_i;
    wire signed [11:0] dac0_data0_q;
    wire signed [11:0] dac0_data1_q;
    wire signed [11:0] dac1_data0_i;
    wire signed [11:0] dac1_data1_i;
    wire signed [11:0] dac1_data0_q;
    wire signed [11:0] dac1_data1_q;

    message_tx #(
        .PCODE_LEN(PCODE_LEN),
        .PCODE_REPEATS(PCODE_REPEATS),
        .MESSAGE_LEN(MESSAGE_LEN)
    ) i_tx (
        .msg_wr_clk(S_AXI_ACLK),
        .clk(rf_clk),
        .rst(rf_rst),
        .pps_in(pps_in),
        .utc_time_update(utc_time_update_cdc),
        .utc_time_hour(utc_time_hour_cdc),
        .utc_time_minute(utc_time_minute_cdc),
        .utc_time_second(utc_time_second_cdc),
        .utc_time_day(utc_time_day_cdc),
        .utc_time_month(utc_time_month_cdc),
        .utc_time_year(utc_time_year_cdc),
        .msg_wr_en(msg_wr_en),
        .msg_wr_strb(msg_wr_strb),
        .msg_channel(msg_channel),
        .msg_offset(msg_offset),
        .msg_data(msg_data),
        .pcode_hval(pcode_hval),
        .pcode_lval(pcode_lval),
        .channel_enable(channel_enable_cdc),
        .tstamp_patch_en(tstamp_patch_en_cdc),
        .dac_valid(dac_valid),
        .dac0_data0_i(dac0_data0_i),
        .dac0_data1_i(dac0_data1_i),
        .dac0_data0_q(dac0_data0_q),
        .dac0_data1_q(dac0_data1_q),
        .dac1_data0_i(dac1_data0_i),
        .dac1_data1_i(dac1_data1_i),
        .dac1_data0_q(dac1_data0_q),
        .dac1_data1_q(dac1_data1_q),
        .pps_out(pps_out)
    );

    ad9361_if i_ad9361 (
        .sys_clk(S_AXI_ACLK),
        .rst(S_AXI_ARESETN),
        .dac0_data0_i(dac0_data0_i),
        .dac0_data0_q(dac0_data0_q),
        .dac0_data1_i(dac0_data1_i),
        .dac0_data1_q(dac0_data1_q),
        .dac1_data0_i(dac1_data0_i),
        .dac1_data0_q(dac1_data0_q),
        .dac1_data1_i(dac1_data1_i),
        .dac1_data1_q(dac1_data1_q),
        .dac_valid(dac_valid),
        .rf_clk(rf_clk),
        .rx_clk_in_0_p(rx_clk_in_0_p),
        .rx_clk_in_0_n(rx_clk_in_0_n),
        .rx_frame_in_0_p(rx_frame_in_0_p),
        .rx_frame_in_0_n(rx_frame_in_0_n),
        .rx_data_in_0_p(rx_data_in_0_p),
        .rx_data_in_0_n(rx_data_in_0_n),
        .tx_clk_out_0_p(tx_clk_out_0_p),
        .tx_clk_out_0_n(tx_clk_out_0_n),
        .tx_frame_out_0_p(tx_frame_out_0_p),
        .tx_frame_out_0_n(tx_frame_out_0_n),
        .tx_data_out_0_p(tx_data_out_0_p),
        .tx_data_out_0_n(tx_data_out_0_n),
        .rx_clk_in_1_p(rx_clk_in_1_p),
        .rx_clk_in_1_n(rx_clk_in_1_n),
        .rx_frame_in_1_p(rx_frame_in_1_p),
        .rx_frame_in_1_n(rx_frame_in_1_n),
        .rx_data_in_1_p(rx_data_in_1_p),
        .rx_data_in_1_n(rx_data_in_1_n),
        .tx_clk_out_1_p(tx_clk_out_1_p),
        .tx_clk_out_1_n(tx_clk_out_1_n),
        .tx_frame_out_1_p(tx_frame_out_1_p),
        .tx_frame_out_1_n(tx_frame_out_1_n),
        .tx_data_out_1_p(tx_data_out_1_p),
        .tx_data_out_1_n(tx_data_out_1_n)
    );


    reg [7:0] pps_ctr;
    assign dbg_rf_clk = rf_clk;

    always @(posedge rf_clk or posedge rf_rst) begin
        if (rf_rst) begin
            dbg_dac_valid_ctr <= 0;
            dbg_dac_data <= 0;
            pps_ctr <= 0;
        end else begin
            if (dac_valid) dbg_dac_valid_ctr <= dbg_dac_valid_ctr + 1;
            if (i_tx.sys_pps) pps_ctr <= pps_ctr + 1;

            case (dbg_dac_data_sel)
                0: dbg_dac_data <= dac0_data0_i;
                1: dbg_dac_data <= dac0_data0_q;
                2: dbg_dac_data <= dac0_data1_i;
                3: dbg_dac_data <= dac0_data1_q;
                4: dbg_dac_data <= dac1_data0_i;
                5: dbg_dac_data <= dac1_data0_q;
                6: dbg_dac_data <= dac1_data1_i;
                7: dbg_dac_data <= dac1_data1_q;
                8: dbg_dac_data <= {dac0_data0_i[11],dac0_data0_q[11],dac0_data1_i[11],dac0_data1_q[11],dac1_data0_i[11],dac1_data0_q[11],dac1_data1_i[11],dac1_data1_q[11]};

                100: dbg_dac_data <= i_tx.pcode_addr_o;
                101: dbg_dac_data <= i_tx.msg_addr_o;
                102: dbg_dac_data <= channel_enable_cdc;
                103: dbg_dac_data <= tstamp_patch_en_cdc;
                104: dbg_dac_data <= pps_ctr;

                110: dbg_dac_data <= rf_rst;
                111: dbg_dac_data <= i_tx.sys_pps;
                112: dbg_dac_data <= i_tx.sys_time_sync_done;
                113: dbg_dac_data <= i_tx.sys_utc_time_year;
                114: dbg_dac_data <= i_tx.sys_utc_time_month;
                115: dbg_dac_data <= i_tx.sys_utc_time_day;
                116: dbg_dac_data <= i_tx.sys_utc_time_hour;
                117: dbg_dac_data <= i_tx.sys_utc_time_minute;
                118: dbg_dac_data <= i_tx.sys_utc_time_second;

                200: dbg_dac_data <= 'hca;
                default: dbg_dac_data <= 10;
            endcase
        end
    end
endmodule : xabs_top
