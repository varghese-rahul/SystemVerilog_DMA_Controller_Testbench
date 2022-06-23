//generally developed as module

//Developing assertions: Sequence or property 
//APB (check interface for signals)

property pslverr_prop;
//@(posedge clk) antecedent |-> consequent;
//at every posedge of clk, pslverr should be 0
@(posedge clk) 1 |-> (pslverr == 0);
endproperty

PSLVERR_PROP : assert property (pslverr_prop);

//penable and pready handshaking
property penable_pready_handshake_prop;
//whenever penable=0 and psel=1, design should drive pready=1 within 5 clock cycles
@(posedge clk) (penable == 0 && psel == 1) |=> ##[0:5] (pready == 1);
endproperty

PENABLE_PREADY_HANDSHAKE_PROP : assert property (penable_pready_handshake_prop);

//AXI
property AW_HANDSHAKE_PROP;
    @(posedge clk) (AWVALID0) |-> ##[0:5] (AWREADY == 1)
endproperty
property W_HANDSHAKE_PROP;
    @(posedge clk) (WVALID0) |-> ##[0:5] (WREADY == 1)
endproperty
property B_HANDSHAKE_PROP;
    @(posedge clk) (BVALID0) |-> ##[0:5] (BREADY == 1)
endproperty
property AR_HANDSHAKE_PROP;
    @(posedge clk) (ARVALID0) |-> ##[0:5] (ARREADY == 1)
endproperty
property R_HANDSHAKE_PROP;
    @(posedge clk) (RVALID0) |-> ##[0:5] (RREADY == 1)
endproperty
property BRESP_PROP;
    @(posedge clk) 1 |-> (BRESP0 == 0)
endproperty
property RRESP_PROP;
    @(posedge clk) 1 |-> (RRESP == 0)
endproperty

AW_HANDSHAKE_PROP_CHK : assert property (AW_HANDSHAKE_PROP);
W_HANDSHAKE_PROP_CHK : assert property (W_HANDSHAKE_PROP);
B_HANDSHAKE_PROP_CHK : assert property (B_HANDSHAKE_PROP);
AR_HANDSHAKE_PROP_CHK : assert property (AR_HANDSHAKE_PROP);
R_HANDSHAKE_PROP_CHK : assert property (R_HANDSHAKE_PROP;
BRESP_PROP_CHK : assert property (BRESP_PROP);
RRESP_PROP_CHK : assert property (RRESP_PROP);

//Periph interface
