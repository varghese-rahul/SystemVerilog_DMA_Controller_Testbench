class apb_bfm;
apb_tx tx;
virtual apb_intf.master_mp vif;
task run();
    $display("apb_bfm::run");
    vif = dma_common::apb_vif;
    //@(negedge vif.master_cb.reset);
    wait (vif.master_cb.reset == 0);
    forever begin
        tx = new();
        dma_common::gen2bfm_mbox.get(tx);
        tx.print(); //good for debugging purposes
        drive_tx(tx); //drive this on to the design APB interface
        dma_common::total_driven_txs++;
        $display("ENTRY::3");
    end
endtask

task drive_tx(apb_tx tx);
    vif.master_cb.paddr <= tx.addr;
    vif.master_cb.pwrite <= tx.wr_rd;
    vif.master_cb.pclken <= 1;
    vif.master_cb.penable <= 0;
    vif.master_cb.psel <= 1;
    if (tx.wr_rd) vif.master_cb.pwdata <= tx.data;
    $display("ENTRY::1");
    @(vif.master_cb);
    wait (vif.master_cb.pready == 1);
    $display("ENTRY::2"); //debugging
    vif.master_cb.paddr <= 0;
    vif.master_cb.pwrite <= 0;
    vif.master_cb.pclken <= 0;
    vif.master_cb.penable <= 1;
    vif.master_cb.psel <= 0;
    if (tx.wr_rd) vif.master_cb.pwdata <= 0;
endtask
endclass