module message_ctl # (
    parameter integer PCODE_LEN = 40920,
    parameter integer PCODE_REPEATS = 10,
    parameter integer MESSAGE_LEN = 120
) (
    input               clk,
    input               rst,

    input               pps_sync_en,
    input               pps_sync_mode, // 0: once, 1: always

    input               sys_time_sync_done,
    input               sys_pps,
    input               dac_valid,

    output                          dbg_resync_valid,
    output [$clog2(PCODE_LEN)-1:0]  dbg_resync_pcode_addr_o,

    output [$clog2(PCODE_LEN)-1:0]       pcode_addr_o,
    output [$clog2(MESSAGE_LEN)-1:0]     msg_addr_o
);

    reg tx_active;
    reg [3:0] pcode_rep_ctr;

    reg frame_end;

    reg [$clog2(PCODE_LEN)-1:0]     pcode_addr;
    reg [$clog2(PCODE_REPEATS)-1:0] bit_index; // 
    reg [$clog2(MESSAGE_LEN)-1:0]   msg_addr;  // 0 - 119
    reg         pcode_addr_last = 0;
    reg         bit_index_last = 0;
    reg         msg_addr_last = 0;

    always @(posedge clk) begin
        if (!sys_time_sync_done || (frame_end && dac_valid) || sys_pps) begin
            pcode_addr <= 0;
            pcode_addr_last <= 0;
        end else begin
            if (dac_valid) begin
                if (pcode_addr_last) begin
                    pcode_addr <= 0;
                end else begin
                    pcode_addr <= pcode_addr + 1;
                end
                pcode_addr_last <= pcode_addr == PCODE_LEN - 2;
            end
        end
    end

    always @(posedge clk) begin
        if (!sys_time_sync_done || (frame_end && dac_valid) || sys_pps) begin
            bit_index <= 0;
            bit_index_last <= 0;
        end else begin
            if (dac_valid && pcode_addr_last) begin
                if (bit_index_last) begin
                    bit_index <= 0;
                end else begin
                    bit_index <= bit_index + 1;
                end
                bit_index_last <= bit_index == PCODE_REPEATS - 2;
            end
        end
    end

    always @(posedge clk) begin
        if (!sys_time_sync_done || (frame_end && dac_valid) || sys_pps) begin
            msg_addr <= 0;
            msg_addr_last <= 0;
        end else begin
            if (dac_valid && pcode_addr_last && bit_index_last) begin
                if (msg_addr_last) begin
                    msg_addr <= msg_addr; // keep
                end else begin
                    msg_addr <= msg_addr + 1;
                end
                msg_addr_last <= msg_addr == MESSAGE_LEN - 2;
            end
        end
    end

    always @(posedge clk) begin
        if (!sys_time_sync_done) begin
            frame_end <= 0;
        end else begin
            // TODO: sync w/ pps
            if (dac_valid) begin
                frame_end <= /*pcode_addr_last*/ pcode_addr == PCODE_LEN - 2 && bit_index_last && msg_addr_last;
            end
        end
    end

    assign msg_addr_o = msg_addr;
    assign pcode_addr_o = pcode_addr;

endmodule
