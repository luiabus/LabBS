module message_tx # (
    parameter integer PCODE_LEN = 40920,
    parameter integer PCODE_REPEATS = 10,
    parameter integer MESSAGE_LEN = 120
) (
    input clk,
    input rst,

    input                   pps_in,

    input                   utc_time_update,
    input [5:0]             utc_time_second,
    input [5:0]             utc_time_minute,
    input [4:0]             utc_time_hour,
    input [4:0]             utc_time_day,
    input [3:0]             utc_time_month,
    input [7:0]             utc_time_year,

    input                   msg_wr_clk,
    input                   msg_wr_en,
    input [3:0]             msg_wr_strb,
    input [2:0]             msg_channel,
    input [7:0]             msg_offset,
    input [31:0]            msg_data,

    input  signed [11:0]    pcode_hval,
    input  signed [11:0]    pcode_lval,

    input [7:0]             channel_enable,
    input                   tstamp_patch_en,

    input                   dac_valid,
     (* keep = "true" *) output signed [11:0]    dac0_data0_i,
     (* keep = "true" *) output signed [11:0]    dac0_data1_i,
     (* keep = "true" *) output signed [11:0]    dac0_data0_q,
     (* keep = "true" *) output signed [11:0]    dac0_data1_q,
     (* keep = "true" *) output signed [11:0]    dac1_data0_i,
     (* keep = "true" *) output signed [11:0]    dac1_data1_i,
     (* keep = "true" *) output signed [11:0]    dac1_data0_q,
     (* keep = "true" *) output signed [11:0]    dac1_data1_q,
    output reg              pps_out
);

    wire [$clog2(PCODE_LEN)-1:0]    pcode_addr_o;
    wire [$clog2(MESSAGE_LEN)-1:0]  msg_addr_o;

    wire pps_valid;

    wire       sys_time_sync_done;
    wire       sys_pps;
    wire [5:0] sys_utc_time_second;
    wire [5:0] sys_utc_time_minute;
    wire [4:0] sys_utc_time_hour; // time updated before sys_pps
    wire [4:0] sys_utc_time_day;
    wire [3:0] sys_utc_time_month;
    wire [7:0] sys_utc_time_year;

    pps_detector i_pps_det (
        .clk(clk),
        .rst(rst),
        .pps_in(pps_in),
        .pps_valid(pps_valid)
    );

    sys_utc_timer # (
        .ENABLE_PRED(0)
    ) i_sys_timer (
        .clk(clk),
        .rst(rst),
        .rx_pps_valid(pps_valid),
        .rx_utc_time_valid(utc_time_update),
        .rx_utc_time_second(utc_time_second),
        .rx_utc_time_minute(utc_time_minute),
        .rx_utc_time_hour(utc_time_hour),
        .rx_utc_time_day(utc_time_day),
        .rx_utc_time_month(utc_time_month),
        .rx_utc_time_year(utc_time_year),
        .time_sync_done(sys_time_sync_done),
        .pps_out(sys_pps),
        .utc_time_second(sys_utc_time_second),
        .utc_time_minute(sys_utc_time_minute),
        .utc_time_hour(sys_utc_time_hour),
        .utc_time_day(sys_utc_time_day),
        .utc_time_month(sys_utc_time_month),
        .utc_time_year(sys_utc_time_year)
    );

    message_ctl # (
        .PCODE_LEN(PCODE_LEN),
        .PCODE_REPEATS(PCODE_REPEATS),
        .MESSAGE_LEN(MESSAGE_LEN)
    ) i_msg_ctl (
        .clk(clk),
        .rst(rst),
        .sys_time_sync_done(sys_time_sync_done),
        .sys_pps(sys_pps),
        .dac_valid(dac_valid),
        .pcode_addr_o(pcode_addr_o), // TODO: +latency
        .msg_addr_o(msg_addr_o)
    );

    message_gen # (
        .PCODE_LEN(PCODE_LEN),
        .PCODE_REPEATS(PCODE_REPEATS),
        .MESSAGE_LEN(MESSAGE_LEN)
    ) i_msg_gen (
        .clk(clk),
        .rst(rst),
        .pcode_hval(pcode_hval),
        .pcode_lval(pcode_lval),
        .pcode_addr(pcode_addr_o),
        .msg_addr(msg_addr_o),
        .sys_time_sync_done(sys_time_sync_done),
        .sys_utc_time_second(sys_utc_time_second),
        .sys_utc_time_minute(sys_utc_time_minute),
        .sys_utc_time_hour(sys_utc_time_hour),
        .sys_utc_time_day(sys_utc_time_day),
        .sys_utc_time_month(sys_utc_time_month),
        .sys_utc_time_year(sys_utc_time_year),
        .msg_wr_clk(msg_wr_clk),
        .msg_wr_en(msg_wr_en),
        .msg_wr_strb(msg_wr_strb),
        .msg_channel(msg_channel),
        .msg_offset(msg_offset),
        .msg_data(msg_data),
        .channel_enable(channel_enable),
        .tstamp_patch_en(tstamp_patch_en),
        .dac_valid(dac_valid),
        .dac0_data0_i(dac0_data0_i),
        .dac0_data1_i(dac0_data1_i),
        .dac0_data0_q(dac0_data0_q),
        .dac0_data1_q(dac0_data1_q),
        .dac1_data0_i(dac1_data0_i),
        .dac1_data1_i(dac1_data1_i),
        .dac1_data0_q(dac1_data0_q),
        .dac1_data1_q(dac1_data1_q)
    );

    parameter PPS_POS_COUNT = 40920 * 100;
    reg [$clog2(PPS_POS_COUNT)-1:0] pps_counter;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pps_out <= 0;
            pps_counter <= PPS_POS_COUNT - 1;
        end else begin
            if (sys_pps) begin
                pps_out <= 1;
                pps_counter <= PPS_POS_COUNT - 1;
            end else if (pps_counter != 0) begin
                pps_counter <= pps_counter - 1;
            end else begin
                pps_out <= 0;
            end
        end
    end

endmodule
