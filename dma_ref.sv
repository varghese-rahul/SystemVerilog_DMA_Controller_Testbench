class dma_ref;
dma_ctrl_reg_block reg_block_i = new();
apb_tx ptx;
axi_tx atx;
bit [31:0] rd_data_from_reg_model;
byte rdbyteAQ[7:0][$];
byte wrbyteAQ[7:0][$];
bit [3:0] rd_active_channel;
bit [3:0] wr_active_channel;
byte wr_byte;
byte rd_byte;

task run();
    $display("dma_ref::run");
fork
    //applying reset to the register model, whenever DUT is resetted 
    forever begin
        @(posedge clk dma_common::dut_reset_applied)
        reg_block_i.reset_reg(); //Resetting all the register model register values
    end
    //handling the APB txs coming from APB monitor
    forever begin
        dma_common::apbmon2ref_mbox.get(ptx);
        if (ptx.wr_rd == 1) begin
            reg_block_i.write_reg(ptx.addr, ptx.data);
            //APB BFM is configuring the DUT registers, this configuration is deciding how the AXI txs are going to happen
            //so need to collect the complete field information from register programming
            //above not required because register model has all fields getting updated, so we can access from register model
        end
        else begin
            rd_data_from_reg_model = reg_block_i.read_reg(ptx.addr);
            if(rd_data_from_reg_model != ptx.data) begin
                $display("ERROR-REG_DATA_MISMATCH");
                $display("Register address = %h, DUT read data = %h, Register model read data = %h", ptx.addr, ptx.data, rd_data_from_reg_model);
                dma_common::reg_error_count++;
            end
        end
    end
    //handling the AXI txs coming from AXI monitor
    forever begin
        dma_common::aximon2ref_mbox.get(atx);
        atx.print();
        if (atx.wr_rd == READ) begin
            //DMA controller is reading from slave, so save this data into a queue for future comparison
            //rd_addr will indicate which channel is transferring, register polling doesn't help here
            if (atx.rd_addr inside {[32'h1000_0000 : 32'h1001_0000]}) rd_active_channel = 0;
            if (atx.rd_addr inside {[32'h1001_0000 : 32'h1002_0000]}) rd_active_channel = 1;
            if (atx.rd_addr inside {[32'h1002_0000 : 32'h1003_0000]}) rd_active_channel = 2;
            if (atx.rd_addr inside {[32'h1003_0000 : 32'h1004_0000]}) rd_active_channel = 3;
            if (atx.rd_addr inside {[32'h1004_0000 : 32'h1005_0000]}) rd_active_channel = 4;
            if (atx.rd_addr inside {[32'h1005_0000 : 32'h1006_0000]}) rd_active_channel = 5;
            if (atx.rd_addr inside {[32'h1006_0000 : 32'h1007_0000]}) rd_active_channel = 6;
            if (atx.rd_addr inside {[32'h1007_0000 : 32'h1008_0000]}) rd_active_channel = 7;
            //
            for (int j = 0; j <= atx.rd_len; j ++) begin
                for (int k = 0; k <= 7; k++) begin
                    rdbyteAQ[rd_active_channel].push_back(atx.rdataQ[j][7:0]);  //8 queues should be there, one for each channel, queue should be filled based on which channel is currently active, rd_addr will indicate this
                    atx.rdataQ[j] >>= 8;
                end
            end
        end
        if (atx.wr_rd == WRITE) begin
            if (atx.wr_addr inside {[32'h2000_0000 : 32'h2001_0000]}) wr_active_channel = 0;
            if (atx.wr_addr inside {[32'h2001_0000 : 32'h2002_0000]}) wr_active_channel = 1;
            if (atx.wr_addr inside {[32'h2002_0000 : 32'h2003_0000]}) wr_active_channel = 2;
            if (atx.wr_addr inside {[32'h2003_0000 : 32'h2004_0000]}) wr_active_channel = 3;
            if (atx.wr_addr inside {[32'h2004_0000 : 32'h2005_0000]}) wr_active_channel = 4;
            if (atx.wr_addr inside {[32'h2005_0000 : 32'h2006_0000]}) wr_active_channel = 5;
            if (atx.wr_addr inside {[32'h2006_0000 : 32'h2007_0000]}) wr_active_channel = 6;
            if (atx.wr_addr inside {[32'h2007_0000 : 32'h2008_0000]}) wr_active_channel = 7;
            //
            for (int j = 0; j <= atx.wr_len; j ++) begin
                for (int k = 0; k <= 7; k++) begin
                    wrbyteAQ[wr_active_channel].push_back(atx.wdataQ[j][7:0]);  //8 queues should be there, one for each channel, queue should be filled based on which channel is currently active, rd_addr will indicate this
                    atx.wdataQ[j] >>= 8;
                end
            end
        end
    end
    //comparison purposes
    forever begin
        #1; //need to replace this temporary solution
        $display("buffer_size = %0d", reg_block_i.ch0_cmd_reg2_i.buffer_size);
        wait (wrbyteAQ[wr_active_channel].size() == reg_block_i.ch0_cmd_reg2_i.buffer_size); //buffer size in this example is 128
        wait (rdbyteAQ[rd_active_channel].size() == reg_block_i.ch0_cmd_reg2_i.buffer_size);
        //above two waits' ensure that write and read transfers have completed

        foreach (wrbyteAQ[wr_active_channel]) begin
            wr_byte = wrbyteAQ[wr_active_channel].pop_front();
            rd_byte = rdbyteAQ[rd_active_channel].pop_front();
            if (wr_byte != rd_byte) begin
                dma_common::data_mismatch++;
                $display("ERROR : DATA _MISMATCH - wr_byte = %h, rd_byte = %h", wr_byte, rd_byte);
            end
            else begin
                dma_common:data_match++;
            end
        end
        wrbyteAQ[wr_active_channel].delete();
        rdbyteAQ[rd_active_channel].delete();
    end
join
endtask
endclass