module message_ctl_channel (
    input clk,
    input rst,

    // input frame_start,
    input tx_active,
    input [119:0] message_in,
    input [6:0] message_addr,
    
    output reg [1:0] message_out
);

    always @(posedge clk) begin
        if (rst || !tx_active) begin
            message_out[0] <= 0;
            message_out[1] <= 0;
        end else begin
            message_out[0] <= message_in[message_addr];
            message_out[1] <= 0;
        end
    end

endmodule
