# ad9361_0
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets top_i/xabs_top_0/inst/i_ad9361/i_dev_if_0/i_clk/clk_ibuf_s]

set_property  -dict {PACKAGE_PIN  N18  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_p[4] ]    ; ## U1,K17,IO_L12_MRCC_35_DATA_CLK_P
set_property  -dict {PACKAGE_PIN  P19  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_n[4] ]    ; ## U1,K18,IO_L12_MRCC_35_DATA_CLK_N
set_property  -dict {PACKAGE_PIN  W14  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_p[0] ]    ; ## U1,M19,IO_L07_35_RX_FRAME_P
set_property  -dict {PACKAGE_PIN  Y14  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_n[0] ]    ; ## U1,M20,IO_L07_35_RX_FRAME_N
set_property  -dict {PACKAGE_PIN  T11  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_frame_in_0_p   ]    ; ## U1,F16,IO_L01_35_RX_D0_P
set_property  -dict {PACKAGE_PIN  T10  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_frame_in_0_n   ]    ; ## U1,F17,IO_L01_35_RX_D0_N
set_property  -dict {PACKAGE_PIN  V12  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_clk_in_0_p     ]    ; ## U1,E18,IO_L02_35_RX_D1_P
set_property  -dict {PACKAGE_PIN  W13  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_clk_in_0_n     ]    ; ## U1,E19,IO_L02_35_RX_D1_N
set_property  -dict {PACKAGE_PIN  T12  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_p[5] ]    ; ## U1,D19,IO_L03_35_RX_D2_P
set_property  -dict {PACKAGE_PIN  U12  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_n[5] ]    ; ## U1,D20,IO_L03_35_RX_D2_N
set_property  -dict {PACKAGE_PIN  T14  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_p[2] ]    ; ## U1,E17,IO_L04_35_RX_D3_P
set_property  -dict {PACKAGE_PIN  T15  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_n[2] ]    ; ## U1,D18,IO_L04_35_RX_D3_N
set_property  -dict {PACKAGE_PIN  Y16  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_p[1] ]    ; ## U1,B19,IO_L05_35_RX_D4_P
set_property  -dict {PACKAGE_PIN  Y17  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_n[1] ]    ; ## U1,A20,IO_L05_35_RX_D4_N
set_property  -dict {PACKAGE_PIN  P14  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_p[3] ]    ; ## U1,C20,IO_L06_35_RX_D5_P
set_property  -dict {PACKAGE_PIN  R14  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_0_n[3] ]    ; ## U1,B20,IO_L06_35_RX_D5_N
set_property  -dict {PACKAGE_PIN  T16  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_p[0]]                   ; ## U1,L19,IO_L08_35_FB_CLK_P
set_property  -dict {PACKAGE_PIN  U17  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_n[0]]                   ; ## U1,L20,IO_L08_35_FB_CLK_N
set_property  -dict {PACKAGE_PIN  V15  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_p[4]]                   ; ## U1,M17,IO_L09_35_TX_FRAME_P
set_property  -dict {PACKAGE_PIN  W15  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_n[4]]                   ; ## U1,M18,IO_L09_35_TX_FRAME_N
set_property  -dict {PACKAGE_PIN  T17  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_clk_out_0_p    ]                   ; ## U1,H16,IO_L13_35_TX_D0_P 
set_property  -dict {PACKAGE_PIN  R18  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_clk_out_0_n    ]                   ; ## U1,H17,IO_L13_35_TX_D0_N 
set_property  -dict {PACKAGE_PIN  T20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_p[5]]                   ; ## U1,J18,IO_L14_35_TX_D1_P 
set_property  -dict {PACKAGE_PIN  U20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_n[5]]                   ; ## U1,H18,IO_L14_35_TX_D1_N 
set_property  -dict {PACKAGE_PIN  V20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_p[1]]                   ; ## U1,F19,IO_L15_35_TX_D2_P 
set_property  -dict {PACKAGE_PIN  W20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_n[1]]                   ; ## U1,F20,IO_L15_35_TX_D2_N 
set_property  -dict {PACKAGE_PIN  Y18  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_p[2]]                   ; ## U1,G17,IO_L16_35_TX_D3_P 
set_property  -dict {PACKAGE_PIN  Y19  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_n[2]]                   ; ## U1,G18,IO_L16_35_TX_D3_N 
set_property  -dict {PACKAGE_PIN  R16  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_frame_out_0_p  ]                   ; ## U1,J20,IO_L17_35_TX_D4_P 
set_property  -dict {PACKAGE_PIN  R17  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_frame_out_0_n  ]                   ; ## U1,H20,IO_L17_35_TX_D4_N 
set_property  -dict {PACKAGE_PIN  V16  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_p[3]]                   ; ## U1,G19,IO_L18_35_TX_D5_P 
set_property  -dict {PACKAGE_PIN  W16  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_0_n[3]]                   ; ## U1,G20,IO_L18_35_TX_D5_N 

set_property  -dict {PACKAGE_PIN  U14  IOSTANDARD LVCMOS25} [get_ports enable_0]                            ; ## IO_L10P_T1_AD11P_35          U1,K19,IO_L10_35_ENABLE
set_property  -dict {PACKAGE_PIN  U15  IOSTANDARD LVCMOS25} [get_ports txnrx_0]                             ; ## IO_L11N_T1_SRCC_35           U1,L17,IO_L11_35_TXNRX

#set_property  -dict {PACKAGE_PIN  R16  IOSTANDARD LVCMOS25} [get_ports gpio_status_0[0]]                     ; ## IO_L19P_T3_35                U1,H15,IO_L19_35_CTRL_OUT0
#set_property  -dict {PACKAGE_PIN  R17  IOSTANDARD LVCMOS25} [get_ports gpio_status_0[1]]                     ; ## IO_L19N_T3_VREF_35           U1,G15,IO_L19_35_CTRL_OUT1
#set_property  -dict {PACKAGE_PIN  T17  IOSTANDARD LVCMOS25} [get_ports gpio_status_0[2]]                     ; ## IO_L20P_T3_AD6P_35           U1,K14,IO_L20_35_CTRL_OUT2
#set_property  -dict {PACKAGE_PIN  R18  IOSTANDARD LVCMOS25} [get_ports gpio_status_0[3]]                     ; ## IO_L20N_T3_AD6N_35           U1,J14,IO_L20_35_CTRL_OUT3
#set_property  -dict {PACKAGE_PIN  V17  IOSTANDARD LVCMOS25} [get_ports gpio_status_0[4]]                     ; ## IO_L21P_T3_DQS_AD14P_35      U1,N15,IO_L21_35_CTRL_OUT4
#set_property  -dict {PACKAGE_PIN  V18  IOSTANDARD LVCMOS25} [get_ports gpio_status_0[5]]                     ; ## IO_L21N_T3_DQS_AD14N_35      U1,N16,IO_L21_35_CTRL_OUT5
#set_property  -dict {PACKAGE_PIN  W18  IOSTANDARD LVCMOS25} [get_ports gpio_status_0[6]]                     ; ## IO_L22P_T3_AD7P_35           U1,L14,IO_L22_35_CTRL_OUT6
#set_property  -dict {PACKAGE_PIN  W19  IOSTANDARD LVCMOS25} [get_ports gpio_status_0[7]]                     ; ## IO_L22N_T3_AD7N_35           U1,L15,IO_L22_35_CTRL_OUT7
#set_property  -dict {PACKAGE_PIN  N17  IOSTANDARD LVCMOS25} [get_ports gpio_ctl_0[0]]                        ; ## IO_L23P_T3_34                U1,N17,IO_L23_34_CTRL_IN0
#set_property  -dict {PACKAGE_PIN  P18  IOSTANDARD LVCMOS25} [get_ports gpio_ctl_0[1]]                        ; ## IO_L23N_T3_34                U1,P18,IO_L23_34_CTRL_IN1
#set_property  -dict {PACKAGE_PIN  P15  IOSTANDARD LVCMOS25} [get_ports gpio_ctl_0[2]]                        ; ## IO_L24P_T3_34                U1,P15,IO_L24_34_CTRL_IN2
#set_property  -dict {PACKAGE_PIN  P16  IOSTANDARD LVCMOS25} [get_ports gpio_ctl_0[3]]                        ; ## IO_L24N_T3_34                U1,P16,IO_L24_34_CTRL_IN3
set_property  -dict {PACKAGE_PIN  U18  IOSTANDARD LVCMOS25} [get_ports gpio_en_agc_0]                        ; ## IO_L11P_T1_SRCC_35           U1,L16,IO_L11_35_EN_AGC
set_property  -dict {PACKAGE_PIN  U19  IOSTANDARD LVCMOS25} [get_ports gpio_sync_0]                          ; ## IO_L10N_T1_AD11N_35          U1,J19,IO_L10_35_SYNC_IN
set_property  -dict {PACKAGE_PIN  R19  IOSTANDARD LVCMOS25} [get_ports gpio_resetb_0]                        ; ## IO_0_35                      U1,G14,IO_00_35_AD9364_RST
set_property  -dict {PACKAGE_PIN  N20  IOSTANDARD LVCMOS25} [get_ports gpio_clksel_0]                        ; ## IO_0_34                      U1,R19,IO_00_34_AD9364_CLKSEL

set_property  -dict {PACKAGE_PIN  V18  IOSTANDARD LVCMOS25  PULLTYPE PULLUP} [get_ports SPI_0_CSN]           ; ## IO_L23P_T3_35                U1,M14,IO_L23_35_SPI_ENB
set_property  -dict {PACKAGE_PIN  W18  IOSTANDARD LVCMOS25} [get_ports SPI_0_CLK]                            ; ## IO_L23N_T3_35                U1,M15,IO_L23_35_SPI_CLK
set_property  -dict {PACKAGE_PIN  W19  IOSTANDARD LVCMOS25} [get_ports SPI_0_MOSI]                           ; ## IO_L24P_T3_AD15P_35          U1,K16,IO_L24_35_SPI_DI
set_property  -dict {PACKAGE_PIN  N17  IOSTANDARD LVCMOS25} [get_ports SPI_0_MISO]                           ; ## IO_L24N_T3_AD15N_35          U1,J16,IO_L24_35_SPI_DO

# ad9361_1
set_property  -dict {PACKAGE_PIN  H16  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_p[5] ]         ; ## U1,K17,IO_L12_MRCC_35_DATA_CLK_P
set_property  -dict {PACKAGE_PIN  H17  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_n[5] ]         ; ## U1,K18,IO_L12_MRCC_35_DATA_CLK_N
set_property  -dict {PACKAGE_PIN  M19  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_frame_in_1_p   ]       ; ## U1,M19,IO_L07_35_RX_FRAME_P
set_property  -dict {PACKAGE_PIN  M20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_frame_in_1_n   ]       ; ## U1,M20,IO_L07_35_RX_FRAME_N
set_property  -dict {PACKAGE_PIN  E18  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_p[0] ]     ; ## U1,F16,IO_L01_35_RX_D0_P
set_property  -dict {PACKAGE_PIN  E19  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_n[0] ]     ; ## U1,F17,IO_L01_35_RX_D0_N
set_property  -dict {PACKAGE_PIN  D19  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_p[1] ]     ; ## U1,E18,IO_L02_35_RX_D1_P
set_property  -dict {PACKAGE_PIN  D20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_n[1] ]     ; ## U1,E19,IO_L02_35_RX_D1_N
set_property  -dict {PACKAGE_PIN  C20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_p[2] ]     ; ## U1,D19,IO_L03_35_RX_D2_P
set_property  -dict {PACKAGE_PIN  B20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_n[2] ]     ; ## U1,D20,IO_L03_35_RX_D2_N
set_property  -dict {PACKAGE_PIN  B19  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_p[3] ]     ; ## U1,E17,IO_L04_35_RX_D3_P
set_property  -dict {PACKAGE_PIN  A20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_n[3] ]     ; ## U1,D18,IO_L04_35_RX_D3_N
set_property  -dict {PACKAGE_PIN  E17  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_p[4] ]     ; ## U1,B19,IO_L05_35_RX_D4_P
set_property  -dict {PACKAGE_PIN  D18  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_data_in_1_n[4] ]     ; ## U1,A20,IO_L05_35_RX_D4_N
set_property  -dict {PACKAGE_PIN  F16  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_clk_in_1_p     ]    ; ## U1,C20,IO_L06_35_RX_D5_P
set_property  -dict {PACKAGE_PIN  F17  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_clk_in_1_n     ]    ; ## U1,B20,IO_L06_35_RX_D5_N
set_property  -dict {PACKAGE_PIN  L19  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_p[3]]                   ; ## U1,L19,IO_L08_35_FB_CLK_P
set_property  -dict {PACKAGE_PIN  L20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_n[3]]                   ; ## U1,L20,IO_L08_35_FB_CLK_N
set_property  -dict {PACKAGE_PIN  M17  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_p[4]]                   ; ## U1,M17,IO_L09_35_TX_FRAME_P
set_property  -dict {PACKAGE_PIN  M18  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_n[4]]                   ; ## U1,M18,IO_L09_35_TX_FRAME_N
set_property  -dict {PACKAGE_PIN  H15  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_frame_out_1_p  ]                   ; ## U1,H16,IO_L13_35_TX_D0_P 
set_property  -dict {PACKAGE_PIN  G15  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_frame_out_1_n  ]                   ; ## U1,H17,IO_L13_35_TX_D0_N 
set_property  -dict {PACKAGE_PIN  G17  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_clk_out_1_p    ]                   ; ## U1,J18,IO_L14_35_TX_D1_P 
set_property  -dict {PACKAGE_PIN  G18  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_clk_out_1_n    ]                   ; ## U1,H18,IO_L14_35_TX_D1_N 
set_property  -dict {PACKAGE_PIN  F19  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_p[5]]                   ; ## U1,F19,IO_L15_35_TX_D2_P 
set_property  -dict {PACKAGE_PIN  F20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_n[5]]                   ; ## U1,F20,IO_L15_35_TX_D2_N 
set_property  -dict {PACKAGE_PIN  G19  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_p[0]]                   ; ## U1,G17,IO_L16_35_TX_D3_P 
set_property  -dict {PACKAGE_PIN  G20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_n[0]]                   ; ## U1,G18,IO_L16_35_TX_D3_N 
set_property  -dict {PACKAGE_PIN  J20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_p[1]]                   ; ## U1,J20,IO_L17_35_TX_D4_P 
set_property  -dict {PACKAGE_PIN  H20  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_n[1]]                   ; ## U1,H20,IO_L17_35_TX_D4_N 
set_property  -dict {PACKAGE_PIN  J18  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_p[2]]                   ; ## U1,G19,IO_L18_35_TX_D5_P 
set_property  -dict {PACKAGE_PIN  H18  IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports tx_data_out_1_n[2]]                   ; ## U1,G20,IO_L18_35_TX_D5_N 

set_property  -dict {PACKAGE_PIN  K19  IOSTANDARD LVCMOS25} [get_ports enable_1]                            ; ## IO_L10P_T1_AD11P_35          U1,K19,IO_L10_35_ENABLE
set_property  -dict {PACKAGE_PIN  J19  IOSTANDARD LVCMOS25} [get_ports txnrx_1]                             ; ## IO_L11N_T1_SRCC_35           U1,L17,IO_L11_35_TXNRX

#set_property  -dict {PACKAGE_PIN  R16  IOSTANDARD LVCMOS25} [get_ports gpio_status_1[0]]                     ; ## IO_L19P_T3_35                U1,H15,IO_L19_35_CTRL_OUT0
#set_property  -dict {PACKAGE_PIN  R17  IOSTANDARD LVCMOS25} [get_ports gpio_status_1[1]]                     ; ## IO_L19N_T3_VREF_35           U1,G15,IO_L19_35_CTRL_OUT1
#set_property  -dict {PACKAGE_PIN  T17  IOSTANDARD LVCMOS25} [get_ports gpio_status_1[2]]                     ; ## IO_L20P_T3_AD6P_35           U1,K14,IO_L20_35_CTRL_OUT2
#set_property  -dict {PACKAGE_PIN  R18  IOSTANDARD LVCMOS25} [get_ports gpio_status_1[3]]                     ; ## IO_L20N_T3_AD6N_35           U1,J14,IO_L20_35_CTRL_OUT3
#set_property  -dict {PACKAGE_PIN  V17  IOSTANDARD LVCMOS25} [get_ports gpio_status_1[4]]                     ; ## IO_L21P_T3_DQS_AD14P_35      U1,N15,IO_L21_35_CTRL_OUT4
#set_property  -dict {PACKAGE_PIN  V18  IOSTANDARD LVCMOS25} [get_ports gpio_status_1[5]]                     ; ## IO_L21N_T3_DQS_AD14N_35      U1,N16,IO_L21_35_CTRL_OUT5
#set_property  -dict {PACKAGE_PIN  W18  IOSTANDARD LVCMOS25} [get_ports gpio_status_1[6]]                     ; ## IO_L22P_T3_AD7P_35           U1,L14,IO_L22_35_CTRL_OUT6
#set_property  -dict {PACKAGE_PIN  W19  IOSTANDARD LVCMOS25} [get_ports gpio_status_1[7]]                     ; ## IO_L22N_T3_AD7N_35           U1,L15,IO_L22_35_CTRL_OUT7
#set_property  -dict {PACKAGE_PIN  N17  IOSTANDARD LVCMOS25} [get_ports gpio_ctl_1[0]]                        ; ## IO_L23P_T3_34                U1,N17,IO_L23_34_CTRL_IN0
#set_property  -dict {PACKAGE_PIN  P18  IOSTANDARD LVCMOS25} [get_ports gpio_ctl_1[1]]                        ; ## IO_L23N_T3_34                U1,P18,IO_L23_34_CTRL_IN1
#set_property  -dict {PACKAGE_PIN  P15  IOSTANDARD LVCMOS25} [get_ports gpio_ctl_1[2]]                        ; ## IO_L24P_T3_34                U1,P15,IO_L24_34_CTRL_IN2
#set_property  -dict {PACKAGE_PIN  P16  IOSTANDARD LVCMOS25} [get_ports gpio_ctl_1[3]]                        ; ## IO_L24N_T3_34                U1,P16,IO_L24_34_CTRL_IN3
set_property  -dict {PACKAGE_PIN  K17  IOSTANDARD LVCMOS25} [get_ports gpio_en_agc_1]                        ; ## IO_L11P_T1_SRCC_35           U1,L16,IO_L11_35_EN_AGC
set_property  -dict {PACKAGE_PIN  K18  IOSTANDARD LVCMOS25} [get_ports gpio_sync_1]                          ; ## IO_L10N_T1_AD11N_35          U1,J19,IO_L10_35_SYNC_IN
set_property  -dict {PACKAGE_PIN  G14  IOSTANDARD LVCMOS25} [get_ports gpio_resetb_1]                        ; ## IO_0_35                      U1,G14,IO_00_35_AD9364_RST
set_property  -dict {PACKAGE_PIN  L16  IOSTANDARD LVCMOS25} [get_ports gpio_clksel_1]                        ; ## IO_0_34                      U1,R19,IO_00_34_AD9364_CLKSEL

set_property  -dict {PACKAGE_PIN  J14  IOSTANDARD LVCMOS25  PULLTYPE PULLUP} [get_ports SPI_1_CSN]           ; ## IO_L23P_T3_35                U1,M14,IO_L23_35_SPI_ENB
set_property  -dict {PACKAGE_PIN  N15  IOSTANDARD LVCMOS25} [get_ports SPI_1_CLK]                            ; ## IO_L23N_T3_35                U1,M15,IO_L23_35_SPI_CLK
set_property  -dict {PACKAGE_PIN  N16  IOSTANDARD LVCMOS25} [get_ports SPI_1_MOSI]                           ; ## IO_L24P_T3_AD15P_35          U1,K16,IO_L24_35_SPI_DI
set_property  -dict {PACKAGE_PIN  L14  IOSTANDARD LVCMOS25} [get_ports SPI_1_MISO]                           ; ## IO_L24N_T3_AD15N_35          U1,J16,IO_L24_35_SPI_DO

create_clock -period 6.10948 -name rx_clk [get_ports rx_clk_in_0_p]

## led
#set_property  -dict {PACKAGE_PIN  J16  IOSTANDARD  LVCMOS25} [get_ports  led[0]]                       ; ## LED1
#set_property  -dict {PACKAGE_PIN  J15  IOSTANDARD  LVCMOS25} [get_ports  led[1]]                       ; ## LED2


## GPS (DATA-UART)
## U1,C5,PS_MIO14_500_JX4,JX4,93,GPS_TXD1_1V8
## U1,C8,PS_MIO15_500_JX4,JX4,85,GPS_RXD1_1V8
#set_property  -dict {PACKAGE_PIN  Y9  IOSTANDARD  LVCMOS18} [get_ports  ocxo_clk]                           ; ## GPS_PPS
set_property  -dict {PACKAGE_PIN  Y8  IOSTANDARD  LVCMOS18} [get_ports  pps_in]                            ; ## GPS_PPS

set_property  -dict {PACKAGE_PIN  T9  IOSTANDARD  LVCMOS18} [get_ports  PS_UART_1_rxd]                        ; ## PL_UART_RXD
set_property  -dict {PACKAGE_PIN  V7  IOSTANDARD  LVCMOS18} [get_ports  PS_UART_1_txd]                        ; ## PL_UART_TXD

set_property  -dict {PACKAGE_PIN  W10  IOSTANDARD  LVCMOS18} [get_ports  pps_out]         ;#IDSEL_OUT3
set_property  -dict {PACKAGE_PIN  W9   IOSTANDARD  LVCMOS18} [get_ports  pps_lpbk_in]     ;#IDSEL_OUT4
set_property  -dict {PACKAGE_PIN  U9   IOSTANDARD  LVCMOS18} [get_ports  pps_lpbk_out]    ;#IDSEL_OUT5



set_max_delay -from [get_pins -of [get_cells -hier -filter {name =~ top_i/xabs_top_0/inst/i_axi/reg_*}] -filter {name =~ *C}] \
    -to [get_pins -of [get_cells -hier -filter {name =~ top_i/xabs_top_0/inst/i_*_cdc/signal_meta_reg*}] -filter {name =~ *D}] \
    3.000 -datapath_only -quiet
set_max_delay -from [get_pins -of [get_cells -hier -filter {name =~ top_i/xabs_top_0/inst/i_utc_cdc/src_diff_reg*}] -filter {name =~ *C}] \
    3.000 -datapath_only -quiet
set_max_delay -from [get_pins -of [get_cells -hier -filter {name =~ top_i/xabs_top_0/inst/i_utc_cdc/src_data_hold_reg*}] -filter {name =~ *C}] \
    3.000 -datapath_only -quiet
set_max_delay -from [get_pins -of [get_cells -hier -filter {name =~ top_i/xabs_top_0/inst/i_tx/*.i_ch/i_msg_mem/memory_reg*}] -filter {name =~ *CLK}] \
    3.000 -datapath_only -quiet
set_false_path -to [get_pins -of [get_cells -hier -filter {name =~ top_i/xabs_top_0/inst/i_rf_rst/reset_meta_cdc_reg*}] -filter {name =~ *D}] -quiet

set_max_delay -from [get_pins -of [get_cells -hier -filter {name =~ top_i/xabs_top_0/inst/dbg_dac_valid_ctr_reg*}] -filter {name =~ *C} ] \
    5.00 -datapath_only -quiet

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets top_i/xabs_top_0/inst/i_ad9361/i_dev_if_0/i_clk/i_rx_clk_ibuf]