class axi_mon;
axi_tx tx;
virtual axi_intf.monitor_mp vif;
task run();
    $display("axi_mon::run");
    vif = dma_common::axi_vif;
    wait (vif.monitor_cb.reset == 0);
    forever begin
        @(vif.monitor_cb);
        //Below 3 if blocks are for collecting write tx information
        if (vif.monitor_cb.awvalid && vif.monitor_cb.awready) begin //Write address phase is valid => write tx is starting
            tx=new();
            tx.wr_rd = WRITE;
            tx.wr_addr = vif.monitor_cb.awaddr;
            tx.wr_len = vif.monitor_cb.awlen;
            tx.wr_size = vif.monitor_cb.awsize;
            tx.wr_id = vif.monitor_cb.awid;
        end
        if (vif.monitor_cb.wvalid && vif.monitor_cb.wready) begin
            tx.wdataQ.push_back(vif.monitor_cb.wdata);
            tx.strbQ.push_back(vif.monitor_cb.wstrb);
        end
        if (vif.monitor_cb.bvalid && vif.monitor_cb.bready) begin
            tx.wr_resp = vif.monitor_cb.bresp; //once write response happens -> write tx is over -> this tx can be given to reference model
            dma_common::aximon2ref_mbox.put(tx);
        end
        //Below 2 if blocks are for collecting read tx information
        if (vif.monitor_cb.arvalid && vif.monitor_cb.arready) begin //Read address phase is valid => read tx is starting
            tx=new();
            tx.wr_rd = READ;
            tx.rd_addr = vif.monitor_cb.araddr;
            tx.rd_len = vif.monitor_cb.arlen;
            tx.rd_size = vif.monitor_cb.arsize;
            tx.rd_id = vif.monitor_cb.arid;
        end
        if (vif.monitor_cb.rvalid && vif.monitor_cb.rready) begin
            tx.rdataQ.push_back(vif.monitor_cb.rdata);
            tx.rd_resp = vif.monitor_cb.rresp; //once read response happens -> read tx is over -> this tx can be given to reference model
            //(tricky part) read data phase happens multiple times 
            //only in last read beat(transfer), we should put in mailbox
            if (vif.monitor_cb.rlast) dma_common::aximon2ref_mbox.put(tx);
        end
    end
endtask
endclass