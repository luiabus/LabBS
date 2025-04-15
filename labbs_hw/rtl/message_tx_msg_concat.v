module message_tx_msg_concat (
    input           clk,
    input           rst,

    input [4:0]     sys_utc_time_hour,
    input [5:0]     sys_utc_time_minute,
    input [5:0]     sys_utc_time_second,

    // output reg [15:0]  pcode_addr, // TODO: +laterncy
    // input [6:0]     message_addr, // 7 bit addr
    output [119:0]  message_o
    // output reg      data_o
);

    assign message_o = {
        103'h5a5a5a5a_5a5a5a5a,
        sys_utc_time_hour,
        sys_utc_time_minute,
        sys_utc_time_second
    };

endmodule
