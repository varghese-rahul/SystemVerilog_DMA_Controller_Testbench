class apb_env;
apb_bfm apb_bfm_i;
apb_gen apb_gen_i;
apb_mon apb_mon_i;
apb_cov apb_cov_i;

function new();
    apb_bfm_i = new();
    apb_gen_i = new();
    apb_mon_i = new();
    apb_cov_i = new();
endfunction

task run();
$display("apb_env::ENTRY-1");
fork
    apb_bfm_i.run();
    apb_gen_i.run();
    apb_mon_i.run();
    apb_cov_i.run();
join
$display("apb_env::ENTRY-2");
endtask
endclass