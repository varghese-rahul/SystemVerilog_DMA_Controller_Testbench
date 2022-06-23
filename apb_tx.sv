class apb_tx;
rand bit apb_or_periph_f;
rand bit [12:0] addr;
rand bit [31:0] data;
rand bit wr_rd;

function new();
endfunction

function void print();
    $display("Printing the fields of apb_tx");
    $display("addr = %h", addr);
    $display("data = %h", data);
    $display("wr_rd = %h", wr_rd);
endfunction

//function bit compare(); //no place to compare apb_txs' instead used to configure design registers
//function void copy(output apb_tx tx);

constraint apb_or_periph_c{
    soft apb_or_periph_f == 1; //by default it should be an apb_tx
}
endclass