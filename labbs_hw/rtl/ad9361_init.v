module ad9361_init (
    input clk,
    input rst,

    input           ad9361_init,
    output reg      ad9361_init_done,

    output [3:0]    AD9361_SW,
    output [3:0]    AD9361_TX_PD1800,
    output [3:0]    AD9361_TX_PD3500,

    output          AD9361_MOSI_ADI1,
    input           AD9361_MISO_ADI1,
    output          AD9361_CLK_ADI1,
    output [1:0]    AD9361_CSB1,
    output [1:0]    AD9361_CSB2,
    output          AD9361_MOSI_ADI3,
    input           AD9361_MISO_ADI3,
    output          AD9361_CLK_ADI3,
    output [1:0]    AD9361_CSB3,
    output [1:0]    AD9361_CSB4,
    output          AD9361_MOSI_ADI5,
    input           AD9361_MISO_ADI5,
    output          AD9361_CLK_ADI5,
    output [1:0]    AD9361_CSB5,
    output [1:0]    AD9361_CSB6,
    output          AD9361_MOSI_ADI7,
    input           AD9361_MISO_ADI7,
    output          AD9361_CLK_ADI7,
    output [1:0]    AD9361_CSB7,
    output [1:0]    AD9361_CSB8,

    output [3:0]    AD9361_RESET_AD9361,
    output          AD9361_SYNC,               
    output [1:0]    AD9361_TX_FRAME_FPGA,      //用于反馈给AD9361 20.46M
    output [1:0]    AD9361_FB_CLK_FPGA         //用于寄存码字 40.92M
);

    reg [7:0] delay;

    always @(posedge clk or posedge rst) begin : proc_
        if (rst) begin
            delay <= 0;
            ad9361_init_done <= 0;
        end else begin
            if (ad9361_init) begin
                if (delay < 100) begin
                    ad9361_init_done <= 0;
                    delay <= delay + 1;
                end else begin
                    ad9361_init_done <= 1;
                    delay <= 0;
                end
            end else begin
                ad9361_init_done <= 0;
            end
        end
    end

endmodule