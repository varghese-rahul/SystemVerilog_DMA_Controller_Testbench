class apb_mon;
apb_tx tx;
virtual apb_intf.monitor_mp vif;
task run();
    $display("apb_mon::run");
    vif = dma_common::apb_vif;
    wait (vif.monitor_cb.reset == 0);
    forever begin
        @(vif.monitor_cb);
        //check enable and ready signals to see transaction valid
        if (vif.monitor_cb.penable == 0 && vif.monitor_cb.pready == 1) begin
            //monitor should collect the tx
            tx = new();
            tx.addr = vif.monitor_cb.paddr;
            tx.wr_rd = vif.monitor_cb.pwrite;
            tx.apb_or_periph_f = 1;

            fork
            begin
                if (vif.monitor_cb.pwrite == 1) begin
                    tx.data = vif.monitor_cb.pwdata;
                    dma_common::mon2cov_mbox.put(tx);
                    dma_common::apbmon2ref_mbox.put(tx);
                end
            end
            join_none

            fork
            begin
                @(vif.monitor_cb);
                if (vif.monitor_cb.pwrite == 0) begin
                    tx.data = vif.monitor_cb.prdata;
                    dma_common::mon2cov_mbox.put(tx);
                    dma_common::apbmon2ref_mbox.put(tx);
                end
            end
            join_none

        end
    end
endtask
endclass