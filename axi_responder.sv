class axi_responder; //AXI slave is a memory with AXI interface, requests will come from DMA controller
virtual axi_intf.slave_mp vif;
byte mem[int]; //for * you can't do all operations of associative array
bit [`ID_BITS-1:0] awid_t;
bit [32-1:0] awaddr_t;
bit [`LEN_BITS-1:0] awlen_t;
bit [`SIZE_BITS-1:0] awsize_t;
bit [`ID_BITS-1:0] arid_t;
bit [32-1:0] araddr_t;
bit [`LEN_BITS-1:0] arlen_t;
bit [`SIZE_BITS-1:0] arsize_t;

task initialize_memory();
    //if we don't initialize memory, memory address locations(32'h1000_0000) will not be there
    for (int i = 0; i < 1024; i++) begin
        mem[32'h1000_0000+i] = $random;
    end
endtask

task run();
    $display("axi_responder::run");
    vif = dma_common::axi_vif;
    wait (vif.slave_cb.reset == 0);
    initialize_memory();
    forever begin
        //Write Address request
        if (vif.slave_cb.awvalid == 1) begin
            vif.slave_cb.awready <= 1;
            awid_t = vif.slave_cb.awid;
            awaddr_t = vif.slave_cb.awaddr;
            awlen_t = vif.slave_cb.awlen;
            awsize_t = vif.slave_cb.awsize;
        end
        else begin
            vif.slave_cb.awready <= 0;
        end
        //Write Data request
        if (vif.slave_cb.awvalid == 1) begin
            vif.slave_cb.wready <= 1;
            //64 bit data bus
            mem[awaddr_t] = vif.slave_cb.wdata[7:0];
            mem[awaddr_t+1] = vif.slave_cb.wdata[15:8];
            mem[awaddr_t+2] = vif.slave_cb.wdata[23:16];
            mem[awaddr_t+3] = vif.slave_cb.wdata[31:24];
            mem[awaddr_t+4] = vif.slave_cb.wdata[39:32];
            mem[awaddr_t+5] = vif.slave_cb.wdata[47:40];
            mem[awaddr_t+6] = vif.slave_cb.wdata[55:48];
            mem[awaddr_t+7] = vif.slave_cb.wdata[63:56];
            awaddr_t = awaddr_t + 4; //if fixed you don't increment
            if (vif.slave_cb.wlast == 1) begin
                write_response_phase();
            end
        end
        else begin
            vif.slave_cb.wready <= 0;
        end
        //Read Address request
        if (vif.slave_cb.arvalid == 1) begin
            vif.slave_cb.arready <= 1;
            arid_t = vif.slave_cb.arid;
            araddr_t = vif.slave_cb.araddr;
            arlen_t = vif.slave_cb.arlen;
            arsize_t = vif.slave_cb.arsize;
            read_data_phase();
        end
        else begin
            vif.slave_cb.arready <= 0;
        end
    end
endtask

task write_response_phase();
    vif.slave_cb.bresp <= 2'b00;
    vif.slave_cb.bvalid <= 1;
    vif.slave_cb.bid <= awid_t;
    @(vif.slave_cb);
    wait (vif.slave_cb.bready == 1);
    vif.slave_cb.bresp <= 2'b00;
    vif.slave_cb.bvalid <= 0;
    vif.slave_cb.bid <= 0;
endtask
task read_data_phase();
for (int i = 0; i<= arlen_t; i++) begin
    @(vif.slave_cb);
    vif.slave_cb.rdata <= {mem[araddr_t+7], mem[araddr_t+6] ,mem[araddr_t+5], mem[araddr_t+4], mem[araddr_t+3], mem[araddr_t+2], mem[araddr_t+1], mem[araddr_t]};
    vif.slave_cb.rvalid <= 1;
    vif.slave_cb.rresp <= 2'b00; //OKAY response
    if (i == arlen_t) vif.slave_cb.rlast <= 1;
    vif.slave_cb.rid <= arid_t;
    @(vif.slave_cb);
    wait (vif.slave_cb.rready == 1);
    araddr_t += 4;
end
    vif.slave_cb.rdata <= 0;
    vif.slave_cb.rvalid <= 0;
    vif.slave_cb.rlast <= 0;
    vif.slave_cb.rid <= 0;
endtask

endclass
