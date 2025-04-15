module sys_ctl (
    input clk,
    input rst,

    output reg ad9361_init,
    input  ad9361_init_done,

    output reg pcode_init,
    input  pcode_init_done,

    output reg dev_conf_active_o,
    output reg tx_rst_o
);

    localparam S_IDLE = 0;
    localparam S_AD9361_INIT = 1;
    localparam S_PCODE_INIT = 2;
    localparam S_TX = 3;

    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
            tx_rst_o <= 1;
        end else begin
            case (state)
                S_IDLE: begin
                    state <= S_AD9361_INIT;
                end
                S_AD9361_INIT: begin
                    if (ad9361_init_done)
                        state <= S_PCODE_INIT;
                end
                S_PCODE_INIT: begin
                    if (pcode_init_done)
                        state <= S_TX;
                end
                S_TX: begin
                    state <= S_TX;
                end
                default : state <= S_IDLE;
            endcase
            tx_rst_o <= state != S_TX;
        end
    end

    always @(*) begin
        ad9361_init = state == S_AD9361_INIT;
        pcode_init  = state == S_PCODE_INIT;
    end

    assign dev_conf_active = tx_rst_o;

endmodule
