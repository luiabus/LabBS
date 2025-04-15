module message_gen # (
    parameter integer PCODE_LEN = 40920,
    parameter integer PCODE_REPEATS = 10,
    parameter integer MESSAGE_LEN = 120
) (
    input           clk,
    input           rst,

    input  signed [11:0]        pcode_hval,
    input  signed [11:0]        pcode_lval,

    input [$clog2(PCODE_LEN)-1:0]   pcode_addr,
    input [$clog2(MESSAGE_LEN)-1:0] msg_addr,

    input               sys_time_sync_done,
    input [5:0]         sys_utc_time_second,
    input [5:0]         sys_utc_time_minute,
    input [4:0]         sys_utc_time_hour,
    input [4:0]         sys_utc_time_day,
    input [3:0]         sys_utc_time_month,
    input [7:0]         sys_utc_time_year,

    input               msg_wr_clk,
    input               msg_wr_en,
    input [3:0]         msg_wr_strb,
    input [2:0]         msg_channel,
    input [7:0]         msg_offset,
    input [31:0]        msg_data,

    input [7:0]         channel_enable,
    input               tstamp_patch_en,

    input                       dac_valid,
    output reg signed [11:0]    dac0_data0_i,
    output reg signed [11:0]    dac0_data1_i,
    output reg signed [11:0]    dac0_data0_q,
    output reg signed [11:0]    dac0_data1_q,
    output reg signed [11:0]    dac1_data0_i,
    output reg signed [11:0]    dac1_data1_i,
    output reg signed [11:0]    dac1_data0_q,
    output reg signed [11:0]    dac1_data1_q
);

    wire [15:0] pcode_addr_ext = pcode_addr;

    logic pcode_i[8];
    wire  pcode_q[8] = '{default: 0};

    pcode_rom i_pcode_rom (
        .clk,
        .rst,
        .pcode_addr(pcode_addr_ext),
        .pcode_0(pcode_i[0]),
        .pcode_1(pcode_i[1]),
        .pcode_2(pcode_i[2]),
        .pcode_3(pcode_i[3]),
        .pcode_4(pcode_i[4]),
        .pcode_5(pcode_i[5]),
        .pcode_6(pcode_i[6]),
        .pcode_7(pcode_i[7])
    );

    logic signed [11:0]    dac_data_i[8];
    logic signed [11:0]    dac_data_q[8];

    for (genvar i = 0; i < 8; i++) begin
        message_gen_channel # (
            .PCODE_LEN(PCODE_LEN),
            .PCODE_REPEATS(PCODE_REPEATS),
            .MESSAGE_LEN(MESSAGE_LEN)
        ) i_ch (
            .clk,
            .rst,
            .pcode_hval,
            .pcode_lval,
            .msg_addr,    // d0
            .pcode_val_i(pcode_i[i]), // d1
            .pcode_val_q(pcode_q[i]), // d1
            .sys_time_sync_done,
            .sys_utc_time_second,
            .sys_utc_time_minute,
            .sys_utc_time_hour,
            .sys_utc_time_day,
            .sys_utc_time_month,
            .sys_utc_time_year,
            .msg_wr_clk,
            .msg_wr_en(msg_wr_en && msg_channel == i),
            .msg_wr_strb,
            .msg_offset,
            .msg_data,
            .tstamp_patch_en(tstamp_patch_en),
            .message_i_enable(channel_enable[i]),
            .message_q_enable(1'b0),
            .dac_valid,
            .dac_data_i(dac_data_i[i]),
            .dac_data_q(dac_data_q[i])
        );
    end

    //此处修改四路输出的weil码号
    assign dac0_data0_i = dac_data_i[0];
    assign dac0_data0_q = dac_data_q[0];
    assign dac0_data1_i = dac_data_i[1];
    assign dac0_data1_q = dac_data_q[1];
    assign dac1_data0_i = dac_data_i[2];
    assign dac1_data0_q = dac_data_q[2];
    assign dac1_data1_i = dac_data_i[3];
    assign dac1_data1_q = dac_data_q[3];

endmodule : message_gen
