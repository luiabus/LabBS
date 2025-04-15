module message_gen_channel # (
    parameter integer PCODE_LEN = 40920,
    parameter integer PCODE_REPEATS = 10,
    parameter integer MESSAGE_LEN = 120
) (
    input           clk,
    input           rst,

    input  signed [11:0]        pcode_hval,
    input  signed [11:0]        pcode_lval,

    // input [$clog2(PCODE_LEN)-1:0]   pcode_addr,
    input [$clog2(MESSAGE_LEN)-1:0] msg_addr,    // d0
    input                           pcode_val_i, // d1
    input                           pcode_val_q, // d1

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
    input [7:0]         msg_offset,
    input [31:0]        msg_data,
    input               tstamp_patch_en,

    input               message_i_enable,
    input               message_q_enable,

    input                       dac_valid,
    output reg signed [11:0]    dac_data_i,
    output reg signed [11:0]    dac_data_q
);

    logic [$clog2(MESSAGE_LEN)-1:0] msg_addr_d1; // d0
    logic [7:0]  msg_rd_data; // d1
    logic [7:0]  msg_tstamp_patch; // d1
    logic [7:0]  msg_tstamp_patch_ena; // d1
    logic [7:0]  msg_parallel; // d1

    assign msg_parallel = (msg_tstamp_patch_ena & msg_tstamp_patch) | (~msg_tstamp_patch_ena & msg_rd_data);

    message_memory i_msg_mem (
        .msg_wr_clk,
        .clk,
        .rst,
        .msg_wr_en,
        .msg_wr_strb,
        .msg_offset,
        .msg_data,
        .rd_addr({4'b0, msg_addr[6:3]}),
        .rd_data(msg_rd_data)
    );

    wire [1:0] message = {1'b0, msg_parallel[msg_addr_d1[2:0]]}; // d1

    // bit 0-5:   second (6 bits)
    // bit 6-11:  minute (6 bits)
    // bit 12-16: hour (5 bits)
    // bit 17-21: day (5 bits)
    // bit 22-25: month (4 bits)
    // bit 26-33: year (8 bits)

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            msg_tstamp_patch <= 0;
            msg_tstamp_patch_ena <= 0;
        end else begin
            if (tstamp_patch_en) begin
                case (msg_addr[6:3])
                    0: begin
                        msg_tstamp_patch <= {sys_utc_time_minute[0+:2], sys_utc_time_second[0+:6]};
                        msg_tstamp_patch_ena <= 8'hff;
                    end
                    1: begin
                        msg_tstamp_patch <= {sys_utc_time_hour[0+:4], sys_utc_time_minute[2+:4]};
                        msg_tstamp_patch_ena <= 8'hff;
                    end
                    2: begin
                        msg_tstamp_patch <= {sys_utc_time_month[0+:2], sys_utc_time_day[0+:5], sys_utc_time_hour[4]};
                        msg_tstamp_patch_ena <= 8'hff;
                    end
                    3: begin
                        msg_tstamp_patch <= {sys_utc_time_year[0+:6], sys_utc_time_month[2+:2]};
                        msg_tstamp_patch_ena <= 8'hff;
                    end
                    4: begin
                        msg_tstamp_patch <= {6'b0, sys_utc_time_year[6+:2]};
                        msg_tstamp_patch_ena <= 8'b00000011;
                    end
                    default: begin
                        msg_tstamp_patch <= 0;
                        msg_tstamp_patch_ena <= 0;
                    end
                endcase // msg_addr[6:3]
            end else begin
                msg_tstamp_patch <= '0;
                msg_tstamp_patch_ena <= 8'h00;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            msg_addr_d1 <= 0;
        end else begin
            msg_addr_d1 <= msg_addr;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dac_data_i <= 0;
            dac_data_q <= 0;
        end else begin
            if (message_i_enable) begin
                if (message[0] ^ pcode_val_i) begin
                    dac_data_i <= pcode_hval;
                end else begin
                    dac_data_i <= pcode_lval;
                end
            end else begin
                dac_data_i <= 0;
            end
            if (message_q_enable) begin
                if (message[1] ^ pcode_val_q) begin
                    dac_data_q <= pcode_hval;
                end else begin
                    dac_data_q <= pcode_lval;
                end
            end else begin
                dac_data_q <= 0;
            end
        end
    end

endmodule : message_gen_channel
