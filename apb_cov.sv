class apb_cov;
apb_tx tx;

covergroup apb_cg;
    //don't do coverage on tx.data since it is random so its coverage won't have any significance 
    CP_ADDR : coverpoint tx.addr {
        bins CH0_CMD_REG0 = {`CH0_CMD_REG0_ADDR};
    }

    CP_WR_RD : coverpoint tx.wr_rd {
        bins WR = {1'b1};
        bins RD = {1'b0};
    }

    cross CP_ADDR, CP_WR_RD;
endgroup

function new();
    apb_cg = new();
endfunction

task run();
$display("apb_cov::run");
forever begin
    dma_common::mon2cov_mbox.get(tx);
    apb_cg.sample();
end
endtask
endclass