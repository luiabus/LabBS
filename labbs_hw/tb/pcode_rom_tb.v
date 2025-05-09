//~ `New testbench
`timescale  1ns / 1ps

module tb_pcode_rom;

// pcode_rom Parameters
parameter PERIOD  = 10;


// pcode_rom Inputs
reg   clk                                  = 0 ;
reg   rst                                  = 1 ;
reg   [15:0]  pcode_addr                   = 0 ;

// pcode_rom Outputs
wire  pcode_0                              ;
wire  pcode_1                              ;
wire  pcode_2                              ;
wire  pcode_3                              ;
wire  pcode_4                              ;
wire  pcode_5                              ;
wire  pcode_6                              ;
wire  pcode_7                              ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst  =  0;
end

pcode_rom  u_pcode_rom (
    .clk                     ( clk                ),
    .rst                     ( rst                ),
    .pcode_addr              ( pcode_addr  [15:0] ),

    .pcode_0                 ( pcode_0            ),
    .pcode_1                 ( pcode_1            ),
    .pcode_2                 ( pcode_2            ),
    .pcode_3                 ( pcode_3            ),
    .pcode_4                 ( pcode_4            ),
    .pcode_5                 ( pcode_5            ),
    .pcode_6                 ( pcode_6            ),
    .pcode_7                 ( pcode_7            )
);

always @(posedge clk ) begin
    if (pcode_addr<20459) begin
        pcode_addr<=pcode_addr+1;
    end else begin
        pcode_addr<=16'b0;
    end
end

initial
begin

    $finish;
end

endmodule