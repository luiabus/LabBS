module message_memory (
    input           msg_wr_clk,
    input           clk,
    input           rst,

    input               msg_wr_en,
    input [3:0]         msg_wr_strb,
    // input [2:0]         msg_channel,
    input [7:0]         msg_offset,
    input [31:0]        msg_data,

    input [7:0]         rd_addr,
    output logic [7:0]  rd_data
);

    logic [7:0]         memory[256];

    always_ff @(posedge msg_wr_clk) begin
        if (msg_wr_en) begin
            for (int i = 0; i < 4; i++) begin
                memory[{msg_offset, i[1:0]}] <= msg_data[i*8+:8];
            end
        end
    end

    always_ff @(posedge clk) begin
        rd_data <= memory[rd_addr];
    end

endmodule : message_memory