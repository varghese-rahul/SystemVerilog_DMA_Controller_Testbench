typedef enum{
NO_OP, //0
READ, //1
WRITE, //4
WRITE_READ //3
} wr_rd_t;

class axi_tx;
    //req + rsp
    rand wr_rd_t wr_rd;
    //WRITE
    rand bit [31:0] wr_addr;
    rand bit [63:0] wdataQ[$]; //belongs to write data channel
    rand bit [7:0] strbQ[$]; //belongs to write data channel
    rand bit [3:0] wr_len;
    rand bit [2:0] wr_size;
    rand bit [3:0] wr_id; //awid, wid, bid
    rand bit [1:0] wr_resp;  //belongs to write response channel
    //READ
    rand bit [31:0] rd_addr;
    rand bit [63:0] rdataQ[$];
    rand bit [3:0] rd_len;
    rand bit [2:0] rd_size;
    rand bit [3:0] rd_id; //awid, wid, bid
    rand bit [1:0] rd_resp; 

    //methods : print, compare, copy
    function void print();
        if (wr_rd == WRITE) begin
            $display("axi_tx :: Write tx");
            $display("wr_id = %h", wr_id);
            $display("wr_addr = %h", wr_addr);
            foreach (wdataQ[i]) $display("wdataQ[%0d] = %0h", i, wdataQ[i]);
            $display("strbQ = %p", strbQ);
            $display("wr_len = %h", wr_len);
            $display("wr_size = %h", wr_size);
        end
        if (wr_rd == READ) begin
            $display("axi_tx :: Read tx");
            $display("rd_id = %h", rd_id);
            $display("rd_addr = %h", rd_addr);
            foreach (rdataQ[i]) $display("rdataQ[%0d] = %0h", i, rdataQ[i]);
            $display("rd_len = %h", rd_len);
            $display("rd_size = %h", rd_size);
        end
        if (wr_rd == WRITE_READ) begin
            $display("axi_tx :: Write & Read tx");
            $display("wr_id = %h", wr_id);
            $display("wr_addr = %h", wr_addr);
            foreach (wdataQ[i]) $display("wdataQ[%0d] = %0h", i, wdataQ[i]);
            $display("strbQ = %p", strbQ);
            $display("wr_len = %h", wr_len);
            $display("wr_size = %h", wr_size);
            $display("rd_id = %h", rd_id);
            $display("rd_addr = %h", rd_addr);
            foreach (rdataQ[i]) $display("rdataQ[%0d] = %0h", i, rdataQ[i]);
            $display("rd_len = %h", rd_len);
            $display("rd_size = %h", rd_size);
        end
    endfunction

    function bit compare(axi_tx tx);
    endfunction
    
    function bit copy(output axi_tx tx);
        tx = new this;
    endfunction

    //constraints
    constraint wr_rd_c{
        wr_rd != NO_OP;
    }

    constraint len_c {
        wdataQ.size() == wr_len + 1;
        rdataQ.size() == rd_len + 1;
    }

    //temporary
    function void cleanup_tc();
        bit [63:0] rd_dummy;
        while (rdataQ.size() > rd_len+1) begin
            rd_dummy = rdataQ.popfront();
        end
    endfunction
endclass