module zynq_spi_mux (
    input [1:0] cs,
    // xilinx.com:interface:spi_rtl:1.0
    input SPI_CSN,
    input SPI_CLK,
    input SPI_MOSI,
    output SPI_MISO,

    output SPI_0_CSN,
    output SPI_0_CLK,
    output SPI_0_MOSI,
    input SPI_0_MISO,

    output SPI_1_CSN,
    output SPI_1_CLK,
    output SPI_1_MOSI,
    input SPI_1_MISO
);


    assign SPI_0_CSN = cs[0] || SPI_CSN; // gpio_o[3] 57 AD_0
    assign SPI_0_CLK = ~SPI_0_CSN && SPI_CLK;
    assign SPI_0_MOSI = ~SPI_0_CSN && SPI_MOSI;
    
    assign SPI_1_CSN = cs[1] || SPI_CSN; // gpio_o[4] 58 AD_1
    assign SPI_1_CLK = ~SPI_1_CSN && SPI_CLK;
    assign SPI_1_MOSI = ~SPI_1_CSN && SPI_MOSI;
    
    assign SPI_MISO = (~SPI_0_CSN) ? SPI_0_MISO : 
                      (~SPI_1_CSN) ? SPI_1_MISO : 0;

endmodule
