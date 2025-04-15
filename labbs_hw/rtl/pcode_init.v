module pcode_init (
    input           clk,
    input           rst,

    input           pcode_init,
    output          pcode_init_done,

    output          sram1_wr_valid,
    input           sram1_wr_ready,
    output reg [17:0]   sram1_wr_addr,
    output [31:0]   sram1_wr_data,
    output          sram2_wr_valid,
    input           sram2_wr_ready,
    output reg [17:0]   sram2_wr_addr,
    output [31:0]   sram2_wr_data

    // inout  [31:0]   SRAM_DATA, //高8位连接到了J18的高8位引脚
    // output [17:0]   SRAM_ADDR,
    // output          SRAM_CE_N,
    // output          SRAM_CE2_N,
    // output          SRAM_OE_N,
    // output          SRAM_SW_A_N,
    // output          SRAM_SW_B_N,
    // output          SRAM_SW_C_N,
    // output          SRAM_SW_D_N,
    // output          SRAM_WE_N,

    // inout  [31:0]   SRAM1_DATA, //高8位连接到了J18的次高8位引脚
    // output [17:0]   SRAM1_ADDR,
    // output          SRAM1_CE_N,
    // output          SRAM1_CE2_N,
    // output          SRAM1_OE_N,
    // output          SRAM1_SW_A_N,
    // output          SRAM1_SW_B_N,
    // output          SRAM1_SW_C_N,
    // output          SRAM1_SW_D_N,
    // output          SRAM1_WE_N
);


    // TODO: sram*_wr_data

    localparam S_IDLE   = 0;
    localparam S_WRITE1 = 1;
    localparam S_WRITE2 = 2;
    localparam S_DONE   = 3;

    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
        end else begin
            case (state)
                S_IDLE: begin
                    if (pcode_init) state <= S_WRITE1;
                end
                S_WRITE1: begin
                    if (sram1_wr_valid && sram1_wr_ready && sram1_wr_addr == 1000) state <= S_WRITE2;
                end
                S_WRITE2: begin
                    if (sram2_wr_valid && sram2_wr_ready && sram2_wr_addr == 1000) state <= S_DONE;
                end
                S_DONE: begin
                    state <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase

        end
    end

    always @(posedge clk) begin
        if (state != S_WRITE1) begin
            sram1_wr_addr <= 0;
        end else if (sram1_wr_valid && sram1_wr_ready) begin
            sram1_wr_addr <= sram1_wr_addr + 1;
        end
        if (state != S_WRITE2) begin
            sram2_wr_addr <= 0;
        end else if (sram2_wr_valid && sram2_wr_ready) begin
            sram2_wr_addr <= sram2_wr_addr + 1;
        end
    end

    assign sram1_wr_valid  = state == S_WRITE1;
    assign sram2_wr_valid  = state == S_WRITE2;
    assign pcode_init_done = state == S_DONE;

    assign sram1_wr_data = sram1_wr_addr * 10000000;
    assign sram2_wr_data = sram2_wr_addr * 10000000;
    // sram_wr_adapter i_sram1_wr (
    //     .clk(sys_clk),
    //     .rst(sys_rst),
    //     .wr_valid(sram1_wr_valid),
    //     .wr_ready(sram1_wr_ready),
    //     .wr_addr(sram1_wr_addr),
    //     .wr_data(sram1_wr_data),
    //     .SRAM_DATA(SRAM_DATA), //高8位连接到了J18的高8位引脚
    //     .SRAM_ADDR(SRAM_ADDR),
    //     .SRAM_CE_N(SRAM_CE_N),
    //     .SRAM_CE2_N(SRAM_CE2_N),
    //     .SRAM_OE_N(SRAM_OE_N),
    //     .SRAM_SW_A_N(SRAM_SW_A_N),
    //     .SRAM_SW_B_N(SRAM_SW_B_N),
    //     .SRAM_SW_C_N(SRAM_SW_C_N),
    //     .SRAM_SW_D_N(SRAM_SW_D_N),
    //     .SRAM_WE_N(SRAM_WE_N)
    // );

    // sram_wr_adapter i_sram2_wr (
    //     .clk(sys_clk),
    //     .rst(sys_rst),
    //     .wr_valid(sram2_wr_valid),
    //     .wr_ready(sram2_wr_ready),
    //     .wr_addr(sram2_wr_addr),
    //     .wr_data(sram2_wr_data),
    //     .SRAM_DATA(SRAM1_DATA), //高8位连接到了J18的高8位引脚
    //     .SRAM_ADDR(SRAM1_ADDR),
    //     .SRAM_CE_N(SRAM1_CE_N),
    //     .SRAM_CE2_N(SRAM1_CE2_N),
    //     .SRAM_OE_N(SRAM1_OE_N),
    //     .SRAM_SW_A_N(SRAM1_SW_A_N),
    //     .SRAM_SW_B_N(SRAM1_SW_B_N),
    //     .SRAM_SW_C_N(SRAM1_SW_C_N),
    //     .SRAM_SW_D_N(SRAM1_SW_D_N),
    //     .SRAM_WE_N(SRAM1_WE_N)
    // );

endmodule
