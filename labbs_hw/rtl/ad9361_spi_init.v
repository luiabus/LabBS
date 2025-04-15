`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BUPT
// Engineer: GYH
// 
// Create Date: 2019/12/16 09:35:46
// Design Name: 
// Module Name: ad9361_spi_init
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ad9361_spi_init(
    input                    sys_clk_40,
    input                    sys_clk_200,
    output                   spi_csn,
    output                   spi_clk,
    output                   spi_mosi,
    input                    spi_miso,
    input                    sync_f,
    output                   sync,
    output                   ad_init_finish,
    output                   enable,
    output                   txnrx,
    output                   resetb,
    output          [7:0]    readback
    );

    wire clk;
    wire mosi,miso;
    reg set_stb = 0;
    reg [7:0] set_addr = 8'd2;
    wire [31:0] set_data;
    wire readback_stb,spi_ready,sclk;
    wire [31:0] spi_readback;
    wire [7:0] sen;
    wire cat_ce,cat_mosi,cat_sclk;
    reg [7:0] readback_t;
    reg rst = 0;
    reg reset = 1;
    reg  [15:0] index = -12'd2;//12'd2569;//
    wire [7:0] out_data;
    wire [23:0] cmd_data;
    reg ready = 0;
    reg finish = 0; 
    reg sync_t = 0;
    reg enable_t = 0;
    reg txnrx_t = 0;
    reg [31:0] wait_cnt = 0;
    
    assign spi_csn  = sen[0];
    assign spi_mosi = ~sen[0] & mosi;
    assign spi_clk  = ~sen[0] & sclk;
    assign miso     = spi_miso;
    assign ad_init_finish = finish;
    assign enable = 0;
    assign txnrx = 0;
    assign readback = readback_t;
    assign set_data = {cmd_data,8'b0};
    assign sync = sync_t;
    assign resetb = reset;
    
    ad9361_reg_test ad_reg (
         .clk(sys_clk_40),
         .rst_n(1'b1),
         .index(index),
         .cmd_datao(cmd_data) 
         );

    spi_core #(
         .BASE(8'd0),
         .WIDTH(8),
         .CLK_IDLE(0),
         .SEN_IDLE(8'hFF)) 
    misc_spi(
         .clock(sys_clk_200),
         .reset(rst),
         .set_stb(set_stb),
         .set_addr(set_addr),
         .set_data(set_data),
         .readback(spi_readback),
         .readback_stb(readback_stb),
         .ready(spi_ready),
         .sen(sen),
         .sclk(sclk),
         .mosi(mosi),
         .miso(miso),
         .debug()
         );
         
    always @ (posedge sys_clk_200) 
        begin
            if(readback_stb)
                begin
                  readback_t <= spi_readback[7:0];
                end
            else
                begin
                    readback_t <= readback_t;
                end
        end
           
    always @ (posedge sys_clk_200) 
        begin
            if(index == -12'd2 && wait_cnt >= 32'd100000 && wait_cnt <= 32'd200000)
                begin
                    reset <= 0;
                end
            else
                begin
                    reset <= 1;
                end
        end
   
    always @ (posedge sys_clk_40)
        begin
            ready <= spi_ready;
            if (ready & ~set_stb) 
                begin                                
                   if (index == 12'd1024) 
                       begin              
                          index <= 12'd1024;
                          finish <= 1;
//                          enable_t <= finish;
//                          txnrx_t <= enable_t;
                       end 
                   else  
                       begin
                          case(cmd_data)
                              {1'b0,5'b11111,10'hFFF,8'hFF}:
                                begin
                                    if(wait_cnt>=32'd400000)
                                        begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1;
                                            index <= index;
                                        end
                                end
                              {1'b0,5'b00000,10'h017,8'h00}:
                                begin
                                    if(wait_cnt>=32'd40000)
                                        begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1;
                                            index <= index;
                                        end
                                end
                             {1'b0,5'b00000,10'h05E,8'h00}:
                                begin
                                    if(readback[7]==1 & wait_cnt>=32'd10000)
                                        begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1; 
                                            index <= index;
                                        end
                                end
                              {1'b0,5'b00000,10'h244,8'h00}:
                                begin
                                    if(readback[7]==1 & wait_cnt>=32'd10000)
                                        begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1; 
                                            index <= index;
                                        end
                                end
                             {1'b0,5'b00000,10'h284,8'h00}:
                                begin
                                    if(readback[7]==1 & wait_cnt>=32'd10000)
                                        begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1; 
                                            index <= index;
                                        end
                                end  
                             {1'b0,5'b00000,10'h247,8'h00}:
                                begin
                                    if(readback[1]==1 & wait_cnt>=32'd10000)
                                        begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1; 
                                            index <= index;
                                        end
                                end
                             {1'b0,5'b00000,10'h287,8'h00}:
                                begin
                                    if(readback[1]==1 & wait_cnt>=32'd10000)
                                        begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1; 
                                            index <= index;
                                        end
                                end
                             {1'b0,5'b00000,10'h016,8'h00}:
                                begin
                                    if(readback[7]==0 & wait_cnt>=32'd10000)
                                        begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1; 
                                            index <= index;
                                        end
                                end
                             {1'b0,5'b00000,10'h016,8'h01}:
                                begin
                                    if(readback[6]==0 & wait_cnt>=32'd10000)
                                        begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1; 
                                            index <= index;
                                        end
                                end
                             {1'b0,5'b00000,10'h016,8'h02}:
                                begin
                                    if(readback[0]==0 & wait_cnt>=32'd10000)
                                        begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1; 
                                            index <= index;
                                        end
                                end
                             {1'b0,5'b00000,10'h016,8'h03}:
                                begin
                                    if(readback[4]==0 & wait_cnt>=32'd10000)
                                         begin
                                            wait_cnt <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            wait_cnt <= wait_cnt + 1; 
                                            index <= index;
                                        end
                                end
                                {1'b0,5'b00000,10'h047,8'h00}:
                                begin
                                    if(sync_f == 1)
                                        begin
                                            sync_t <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            sync_t <= 1;
                                            index <= index;
                                        end
                                end
                                {1'b0,5'b00000,10'h001,8'h00}:
                                begin
                                    if(sync_f == 1)
                                        begin
                                            sync_t <= 0;
                                            index <= index + 1;
                                        end
                                    else
                                        begin
                                            sync_t <= 1;
                                            index <= index;
                                        end
                                end
                             default:
                                begin
                                    index <= index + 1;
                                end
                          endcase
                       end
                   set_stb <= 1; 
                end
            else if(~ready & set_stb)
                begin
                    set_stb <= 0;
                end
            else
                begin
                    set_stb <= set_stb;
                end
        end

endmodule
