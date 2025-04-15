module bs_axi_if # (
    localparam integer C_S_AXI_DATA_WIDTH = 32,
    localparam integer C_S_AXI_ADDR_WIDTH = 16
) (
    input wire                                  s_axi_aclk,
    input wire                                  s_axi_aresetn,

    input wire [C_S_AXI_ADDR_WIDTH-1:0]         s_axi_awaddr,
    input wire                                  s_axi_awvalid,
    output logic                                s_axi_awready,

    input wire [C_S_AXI_DATA_WIDTH-1:0]         s_axi_wdata,   
    input wire [(C_S_AXI_DATA_WIDTH/8)-1:0]     s_axi_wstrb,
    input wire                                  s_axi_wvalid,
    output logic                                s_axi_wready,

    output logic [1:0]                          s_axi_bresp,
    output logic                                s_axi_bvalid,
    input wire                                  s_axi_bready,

    input wire [C_S_AXI_ADDR_WIDTH-1:0]         s_axi_araddr,
    input wire                                  s_axi_arvalid,
    output logic                                s_axi_arready,
    
    output logic [C_S_AXI_DATA_WIDTH-1:0]       s_axi_rdata,
    output logic [1:0]                          s_axi_rresp,
    output logic                                s_axi_rvalid,
    input wire                                  s_axi_rready,

    output logic            utc_time_update,
    output [5:0]            utc_time_second,
    output [5:0]            utc_time_minute,
    output [4:0]            utc_time_hour,
    output [4:0]            utc_time_day,
    output [3:0]            utc_time_month,
    output [7:0]            utc_time_year,

    output logic [7:0]      channel_enable,
    output logic            tstamp_patch_en,

    output logic            msg_wr_en,
    output logic [3:0]      msg_wr_strb,
    output logic [2:0]      msg_channel,
    output logic [7:0]      msg_offset,
    output logic [31:0]     msg_data
);

    /// Register map
    ///
    /// 0x00:
    ///     bit 7:0   utc_sec
    ///     bit 15:8  utc_min
    ///     bit 23:16 utc_hour
    ///
    /// 0x01:
    ///     bit 4:0   utc_day,
    ///     bit 11:8  utc_month,
    ///     bit 23:16 utc_year (2000+n)
    ///
    /// 0x02:
    ///     bit 31    utc_update
    ///
    /// 0x03:
    ///     bit 7:0   channel_enable
    ///
    /// 0x04:
    ///     bit 0     tstamp_patch_en
    ///
    /// 0x1000-0x10ff:
    ///     Message buffer for channel 0 (LSB first)
    /// 0x1100-0x11ff:
    ///     Message buffer for channel 1 (LSB first)
    /// ...
    /// 0x1700-0x17ff:
    ///     Message buffer for channel 7 (LSB first)
    ///
    /// 0x10000-0x11fff:
    ///     Pseudo code buffer for channel 0 (LSB first)
    /// 0x12000-0x13fff:
    ///     Pseudo code buffer for channel 1 (LSB first)
    /// ...
    /// 0x1e000-0x1ffff:
    ///     Pseudo code buffer for channel 7 (LSB first)


    //// AXI-Lite interface
    wire            axi_wr_en = /*s_axi_wvalid && */s_axi_wready;
    wire [C_S_AXI_ADDR_WIDTH-1:0]     axi_waddr = s_axi_awaddr;
    wire [31:0]     axi_wdata = s_axi_wdata;
    wire            reg_wr_en = axi_wr_en;
    wire [C_S_AXI_ADDR_WIDTH-1:2]     reg_wr_index = axi_waddr[C_S_AXI_ADDR_WIDTH-1:2];
    wire [31:0]     reg_wr_data = axi_wdata;

    wire            axi_rd_en = s_axi_arvalid && s_axi_arready;
    wire [C_S_AXI_ADDR_WIDTH-1:0]     axi_raddr = s_axi_araddr;
    wire [C_S_AXI_ADDR_WIDTH-1:2]     reg_rd_index = axi_raddr[C_S_AXI_ADDR_WIDTH-1:2];
    logic [31:0]    axi_rdata;
    logic [31:0]    reg_rd_data;
    assign          s_axi_rdata = axi_rdata;

    wire reg_0_wen = axi_wr_en && reg_wr_index == 0;
    wire reg_1_wen = axi_wr_en && reg_wr_index == 1;
    wire reg_3_wen = axi_wr_en && reg_wr_index == 3;
    wire reg_4_wen = axi_wr_en && reg_wr_index == 4;
    // wire sys_ctrl_reg_wen           = axi_wr_en && reg_wr_index == SYS_CTRL_REG_INDEX;

    // aw, w and b channel
    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (~s_axi_aresetn) begin
            s_axi_awready <= 0;
            s_axi_wready  <= 0;
            s_axi_bvalid  <= 0;
        end else begin
            if ((s_axi_awvalid && s_axi_wvalid) && !s_axi_awready && !(s_axi_bvalid && !s_axi_bready)) begin // aw&w valid and no pending write response // TODO: pending write
                s_axi_awready <= 1;
                s_axi_wready <= 1;
            end else begin
                s_axi_awready <= 0;
                s_axi_wready <= 0;
            end
            if (axi_wr_en) begin
                s_axi_bvalid <= 1;
            end else if (s_axi_bready) begin
                s_axi_bvalid <= 0;
            end
        end
    end

    assign s_axi_bresp = '0;

    // ar and r channel
    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (~s_axi_aresetn) begin
            s_axi_arready <= 0;
            s_axi_rvalid  <= 0;
            axi_rdata     <= 'x;
        end else begin
            if (s_axi_rvalid && !s_axi_rready) begin // pending read response
                s_axi_arready <= 0;
            end else if (s_axi_arvalid) begin
                s_axi_arready <= 0;
            end else begin
                s_axi_arready <= 1;
            end

            if (axi_rd_en) begin
                s_axi_rvalid <= 1;
                // (* parallel_case *)
                // case (1)
                //     reg_ren:       axi_rdata <= reg_rd_data;
                //     tx_buffer_ren: axi_rdata <= '0;
                //     rx_buffer_ren: axi_rdata <= rx_buffer_raddr;
                // endcase
                axi_rdata <= reg_rd_data;
            end else if (s_axi_rready) begin
                s_axi_rvalid <= 0;
            end
        end
    end

    assign s_axi_rresp = '0;


    //// System registers

    logic [31:0] reg_0; // (rw)
    logic [31:0] reg_1; // (rw)
    logic [31:0] reg_3; // (rw)
    logic [31:0] reg_4; // (rw)

    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (~s_axi_aresetn) begin
            reg_0 <= '0;
            reg_1 <= '0;
            reg_3 <= '0;
            reg_4 <= '0;
        end else begin
            if (reg_0_wen) begin
                reg_0 <= reg_wr_data;
            end
            if (reg_1_wen) begin
                reg_1 <= reg_wr_data;
            end
            if (reg_3_wen) begin
                reg_3 <= reg_wr_data;
            end
            if (reg_4_wen) begin
                reg_4 <= reg_wr_data;
            end
        end
    end

    always_ff @(posedge s_axi_aclk) begin
        if (axi_rd_en) begin
            case (axi_raddr[11:2])
                'h00: reg_rd_data <= reg_0;
                'h01: reg_rd_data <= reg_1;
                'h03: reg_rd_data <= reg_3;
                'h04: reg_rd_data <= reg_4;
                default:
                    reg_rd_data <= '0;
            endcase
        end
    end

    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (~s_axi_aresetn) begin
            utc_time_update <= 0;
        end else begin
            utc_time_update <= axi_wr_en && reg_wr_index == 2 && reg_wr_data[31];
        end
    end

    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (~s_axi_aresetn) begin
            msg_wr_en   <= 0;
            msg_wr_strb <= 'x;
            msg_channel <= 'x;
            msg_offset  <= 'x;
            msg_data    <= 'x;
        end else begin
            if (s_axi_awvalid && s_axi_awready && s_axi_awaddr[15:12] == 1) begin
                msg_wr_en   <= 1;
                msg_wr_strb <= s_axi_wstrb;
                msg_channel <= s_axi_awaddr[10:8]; // 2:0
                msg_offset  <= {2'b0, s_axi_awaddr[7:2]}; // 7:0
                msg_data    <= s_axi_wdata;
            end else begin
                msg_wr_en   <= 0;
            end
        end
    end

    assign utc_time_second = reg_0[0+:6];
    assign utc_time_minute = reg_0[8+:6];
    assign utc_time_hour   = reg_0[16+:5];
    assign utc_time_day    = reg_1[0+:5];
    assign utc_time_month  = reg_1[8+:4];
    assign utc_time_year   = reg_1[16+:8];

    assign channel_enable  = reg_3[0+:8];

    assign tstamp_patch_en = reg_4[0];

endmodule : bs_axi_if
