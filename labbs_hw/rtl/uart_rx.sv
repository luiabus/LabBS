module uart_rx # (
    parameter CLK_DIV_WIDTH = 10
) (
    input                       clk,
    input                       rst,

    input [CLK_DIV_WIDTH-1:0]   clk_div, ///< baud rate = clk freq / (clk_div + 1)

    output logic                rx_data_valid,
    output logic  [7:0]         rx_data,

    input                       uart_rx_data
);

    logic [CLK_DIV_WIDTH-1:0] baud_counter;
    logic                     baud_counter_fire;

    logic [7:0]               shreg;
    (* async_reg = "true" *)
    logic                     uart_rx_data_meta = 1;
    logic                     uart_rx_data_meta2 = 1;
    logic                     uart_rx_data_sync = 1;
    logic                     uart_rx_data_q = 1;

    enum logic [1:0] {
        S_IDLE,
        S_START,
        S_DATA,
        S_STOP
    } state;

    logic [2:0] bit_count;

    always_ff @(posedge clk) begin
        uart_rx_data_meta  <= uart_rx_data;
        uart_rx_data_meta2 <= uart_rx_data_meta;
        uart_rx_data_sync  <= uart_rx_data_meta2;
        uart_rx_data_q     <= uart_rx_data_sync;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
        end else begin
            unique case (state)
                S_IDLE: begin
                    if (uart_rx_data_q == 1 && uart_rx_data_sync == 0) begin
                        state <= S_START;
                    end
                end
                S_START: begin
                    if (baud_counter_fire) begin
                        state <= S_DATA;
                    end
                end
                S_DATA: begin
                    if (baud_counter_fire && bit_count == 'd7) begin
                        state <= S_STOP;
                    end
                end
                S_STOP: begin
                    if (baud_counter_fire) begin
                        state <= S_IDLE;
                    end
                end
                default:
                    state <= S_IDLE;
            endcase
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_counter <= 'x;
            baud_counter_fire <= 0;
        end else begin
            if (state == S_IDLE) begin
                baud_counter <= clk_div >> 1;
            end else if ((state == S_START || state == S_DATA || state == S_STOP) && baud_counter_fire) begin
                baud_counter <= clk_div;
            end else begin
                baud_counter <= baud_counter - 1;
            end
            baud_counter_fire <= baud_counter == 1;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            bit_count <= 'x;
        end else begin
            if (state != S_DATA) begin
                bit_count <= '0;
            end else if (baud_counter_fire) begin
                bit_count <= bit_count + 1'b1;
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            shreg <= 'x;
            rx_data_valid <= 0;
        end else begin
            rx_data_valid <= 0;
            if (state == S_DATA && baud_counter_fire) begin
                shreg <= {uart_rx_data, shreg[7:1]};
                if (bit_count == 'd7) begin
                    rx_data_valid <= 1;
                end
            end
        end
    end

    assign rx_data = rx_data_valid ? shreg : 'x;

endmodule : uart_rx