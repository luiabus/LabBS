module sys_utc_timer #(
    parameter ENABLE_PRED = 1
) (
    input               clk,
    input               rst,

    input               rx_pps_valid,
    input               rx_utc_time_valid,
    input [5:0]         rx_utc_time_second,
    input [5:0]         rx_utc_time_minute,
    input [4:0]         rx_utc_time_hour,
    input [4:0]         rx_utc_time_day,
    input [3:0]         rx_utc_time_month,
    input [7:0]         rx_utc_time_year,

    output reg          time_sync_done,
    output reg          pps_out,
    output reg [5:0]    utc_time_second,
    output reg [5:0]    utc_time_minute,
    output reg [4:0]    utc_time_hour,
    output reg [4:0]    utc_time_day,
    output reg [3:0]    utc_time_month,
    output reg [7:0]    utc_time_year
);

    if (ENABLE_PRED) begin
        
    reg pps_received;
    reg utc_received;
    reg pps_q;

    reg [4:0] last_rx_utc_time_hour;
    reg [5:0] last_rx_utc_time_minute;
    reg [5:0] last_rx_utc_time_second;

    reg       next_rx_utc_time_valid;
    reg [4:0] next_rx_utc_time_hour;
    reg [5:0] next_rx_utc_time_minute;
    reg [5:0] next_rx_utc_time_second;

    reg carry_hour;
    reg carry_min;
    reg carry_sec;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pps_received <= 0;
            utc_received <= 0;
            time_sync_done <= 0;
            pps_q <= 0;
            pps_out <= 0;
        end else begin
            if (rx_pps_valid) pps_received <= 1;
            if (rx_utc_time_valid) utc_received <= 1;
            time_sync_done <= pps_received && utc_received;
            pps_q   <= rx_pps_valid;
            pps_out <= pps_q;
        end
    end

    always @(*) begin
        carry_hour = 0;
        carry_min = 0;
        carry_sec = 0;
        next_rx_utc_time_second = last_rx_utc_time_second + 1;
        if (next_rx_utc_time_second >= 60) begin
            next_rx_utc_time_second = 0;
            carry_sec = 1;
        end
        next_rx_utc_time_minute = last_rx_utc_time_minute + carry_sec;
        if (next_rx_utc_time_minute >= 60) begin
            next_rx_utc_time_minute = 0;
            carry_min = 1;
        end
        next_rx_utc_time_hour = last_rx_utc_time_hour + carry_min;
        if (next_rx_utc_time_hour >= 24) begin
            next_rx_utc_time_hour = 0;
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            utc_time_hour <= 'bx;
            utc_time_minute <= 'bx;
            utc_time_second <= 'bx;
            last_rx_utc_time_hour <= 'bx;
            last_rx_utc_time_minute <= 'bx;
            last_rx_utc_time_second <= 'bx;
        end else begin
            if (rx_pps_valid) begin
                utc_time_hour <= next_rx_utc_time_hour;
                utc_time_minute <= next_rx_utc_time_minute;
                utc_time_second <= next_rx_utc_time_second;
                last_rx_utc_time_hour  <= next_rx_utc_time_hour;
                last_rx_utc_time_minute <= next_rx_utc_time_minute;
                last_rx_utc_time_second <= next_rx_utc_time_second;
            end else if (rx_utc_time_valid) begin
                last_rx_utc_time_hour  <= rx_utc_time_hour;
                last_rx_utc_time_minute <= rx_utc_time_minute;
                last_rx_utc_time_second <= rx_utc_time_second;
            end
        end
    end

    end else begin
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            time_sync_done <= 0;
            utc_time_second <= 0;
            utc_time_minute <= 0;
            utc_time_hour <= 0;
            utc_time_day <= 0;
            utc_time_month <= 0;
            utc_time_year <= 0;
        end else begin
            if (rx_utc_time_valid) begin
                time_sync_done <= 1;
                utc_time_second <= rx_utc_time_second;
                utc_time_minute <= rx_utc_time_minute;
                utc_time_hour <= rx_utc_time_hour;
                utc_time_day <= rx_utc_time_day;
                utc_time_month <= rx_utc_time_month;
                utc_time_year <= rx_utc_time_year;
            end
        end
    end

    always @(*) pps_out = rx_pps_valid;
        
    end

endmodule : sys_utc_timer
