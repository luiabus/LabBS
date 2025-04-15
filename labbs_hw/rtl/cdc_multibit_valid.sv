module cdc_multibit_valid # (
    parameter int DATA_WIDTH = 1,
    parameter logic [DATA_WIDTH-1:0] DST_DATA_IDLE_VALUE = '0
) (
    input                           src_clk,
    input                           src_rst,
    input                           src_valid,
    input  [DATA_WIDTH-1:0]         src_data,
    input                           dst_clk,
    output logic                    dst_valid,
    output [DATA_WIDTH-1:0]         dst_data
);

    logic                   src_valid_q = 0;
    logic                   src_diff = 0;
    logic [DATA_WIDTH-1:0]  src_data_hold;
    logic [DATA_WIDTH-1:0]  dst_data_cdc = DST_DATA_IDLE_VALUE; // add multicycle constrain for this signal

    (* async_reg = "true" *)
    logic                   src_diff_meta = 0; // add multicycle constrain for this signal
    logic                   src_diff_sync = 0;
    logic                   src_diff_sync_q = 0;

    // TODO: src_rst is not necessary
    always_ff @(posedge src_clk) begin
        if (src_rst)
            src_valid_q <= 0;
        else
            src_valid_q <= src_valid;

        if (src_valid && !src_valid_q && !src_rst) begin // TODO: this implementation can produce wrong data if src_valid os too fast
            src_diff <= !src_diff;
            src_data_hold <= src_data;
        end
    end

    wire dst_valid_next = src_diff_sync != src_diff_sync_q;

    always_ff @(posedge dst_clk) begin
        src_diff_meta <= src_diff;
        src_diff_sync <= src_diff_meta;
        src_diff_sync_q <= src_diff_sync;

        dst_valid <= dst_valid_next;
        if (dst_valid_next) begin
            dst_data_cdc <= src_data_hold;
        end else begin
            dst_data_cdc <= DST_DATA_IDLE_VALUE;
        end
    end

    assign dst_data = dst_data_cdc;

endmodule : cdc_multibit_valid
