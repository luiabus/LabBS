module pcode_rom #(
    parameter integer PCODE_LEN = 40920
) (
    input           clk,
    input           rst,

    input [15:0]    pcode_addr,
    output reg      pcode_0,
    output reg      pcode_1,
    output reg      pcode_2,
    output reg      pcode_3,
    output reg      pcode_4,
    output reg      pcode_5,
    output reg      pcode_6,
    output reg      pcode_7
);

    reg [7:0] memory[0:PCODE_LEN-1];

    initial begin
        $readmemh("D:/CodingHotCache/LabBS/labbs_hw/local/pcode.txt", memory);
    end

    always @(posedge clk) begin
        {pcode_7, pcode_6, pcode_5, pcode_4, pcode_3, pcode_2, pcode_1, pcode_0} <= memory[pcode_addr];
    end

endmodule
