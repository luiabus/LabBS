module cdc_reset # ( // TODO: minumium reset_out width
    parameter bit ACTIVE_HIGH = 1,
    parameter int STAGES = 3
) (
    input  logic reset_in, // should be registered output
    input  logic clk, ///< clock for reset_out output
    output logic reset_out
);

    (* async_reg = "true" *)
    logic               reset_meta_cdc = ACTIVE_HIGH;
    (* async_reg = "true" *)
    logic [STAGES-2:0]  reset_meta = '{default: ACTIVE_HIGH};
    logic               reset_sync = ACTIVE_HIGH;

    always_ff @(posedge clk) begin
        {reset_sync, reset_meta, reset_meta_cdc} <= {reset_meta[STAGES-2:0], reset_meta_cdc, reset_in};
    end

    assign reset_out = reset_sync;
    
endmodule : cdc_reset