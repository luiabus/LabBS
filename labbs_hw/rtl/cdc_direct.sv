module cdc_direct # (
    parameter int WIDTH = 1,
    parameter int LEVELS = 2,
    parameter bit [WIDTH-1:0] INIT = '0
) (
    input  logic [WIDTH-1:0] signal_in, // should be registered output
    input  logic clk,
    output logic [WIDTH-1:0] signal_out
);

    (* async_reg = "true" *)
    logic [WIDTH-1:0] signal_meta = INIT;
    logic [WIDTH-1:0] signal_sync[1:LEVELS-1] = '{default: INIT};

    always_ff @(posedge clk) begin
        signal_meta <= signal_in;
        signal_sync[1] <= signal_meta;
        for (int i = 2; i < LEVELS; i++) begin
            signal_sync[i] <= signal_sync[i-1];
        end
    end

    assign signal_out = signal_sync[LEVELS-1];
    
endmodule : cdc_direct