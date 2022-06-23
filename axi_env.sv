class axi_env;
axi_responder axi_responder_i;
axi_mon axi_mon_i;

function new();
    axi_responder_i = new();
    axi_mon_i = new();
endfunction

task run();
fork
    axi_responder_i.run();
    axi_mon_i.run();
join
endtask
endclass