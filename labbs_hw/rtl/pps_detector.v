module pps_detector (
    input clk,
    input rst,

    input pps_in,
    output reg pps_valid
);

    reg pps_in_meta;
    reg pps_in_meta2;
    reg pps_in_sync;
    reg pps_in_q;

    always @(posedge clk or posedge rst) begin
        if  (rst) begin
            pps_in_meta <= 0;
            pps_in_meta2 <= 0;
            pps_in_sync <= 0;
            pps_in_q <= 0;
            pps_valid <= 0;
        end else begin
            pps_in_meta <= pps_in;
            pps_in_meta2 <= pps_in_meta;
            pps_in_sync <= pps_in_meta2;
            pps_in_q <= pps_in_sync;
            pps_valid <= !pps_in_q && pps_in_sync;
        end
    end

endmodule
