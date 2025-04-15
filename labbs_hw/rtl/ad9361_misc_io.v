module ad9361_misc_io (
    input  [63:0]           gpio_o,
    
    output                  enable_0,
    output                  txnrx_0,
    output                  gpio_resetb_0,
    output                  gpio_sync_0,
    output                  gpio_en_agc_0,
    //  output      [ 3:0]      gpio_ctl_0,
    //  input       [ 7:0]      gpio_status_0,
    input                   gpio_clksel_0,
  
    output                  enable_1,
    output                  txnrx_1,
    output                  gpio_resetb_1,
    output                  gpio_sync_1,
    output                  gpio_en_agc_1,
    //  output      [ 3:0]      gpio_ctl_1,
    //  input       [ 7:0]      gpio_status_1,
    input                   gpio_clksel_1
);

    wire sync = 0;

    // assign gpio_ctl_0 = 0;
    assign gpio_en_agc_0 = 1;
    assign gpio_sync_0 = sync;
    assign gpio_resetb_0 = gpio_o[0];
    
    assign enable_0 = 0;
    assign txnrx_0  = 0;
    
    // assign gpio_ctl_1 = 0;
    assign gpio_en_agc_1 = 1;
    assign gpio_sync_1 = sync;
    assign gpio_resetb_1 = gpio_o[1];
    
    assign enable_1 = 0;
    assign txnrx_1  = 0;

endmodule : ad9361_misc_io