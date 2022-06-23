class dma_env;
apb_env apb_env_i;
axi_env axi_env_i;
dma_ref dma_ref_i;
dma_ckr dma_ckr_i;

function new();
    apb_env_i = new();
    axi_env_i = new();
    dma_ref_i = new();
    dma_ckr_i = new();
endfunction

task run();
fork
    apb_env_i.run();
    axi_env_i.run();
    dma_ref_i.run();
    dma_ckr_i.run();
join
endtask
endclass