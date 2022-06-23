class apb_gen;
apb_tx tx;
bit [31:0] data_t;

task general_config();
    //we don't have CLKDIV => so skip the register
    tx = new();
    tx.randomize() with {addr == `CORE0_JOINT_MODE_ADDR; wr_rd == 1; data == 32'h0;};
    dma_common::gen2bfm_mbox.put(tx);
endtask

task configure_static_registers();
   for (int i = 0; i <= 7; i ++) begin 
    //static_reg0
    tx = new();
    data_t = {1'b1, 1'b0, 2'b0, 4'h4, 2'b0, 6'h1, 2'b0, 1'b1, 1'b0, 2'b0, 10'd128};
    tx.randomize() with {addr == `CH0_STATIC_REG0_ADDR + 32'h100*i; wr_rd == 1; data == data_t;};
    dma_common::gen2bfm_mbox.put(tx);

    //static_reg1
    tx = new();
    data_t = {1'b1, 1'b0, 2'b0, 4'h4, 2'b0, 6'h1, 2'b0, 1'b1, 1'b0, 2'b0, 10'd128};
    tx.randomize() with {addr == `CH0_STATIC_REG1_ADDR + 32'h100*i; wr_rd == 1; data == data_t;};
    dma_common::gen2bfm_mbox.put(tx);

    //static_reg2
    tx = new();
    data_t = {9'b0, 3'b0, 2'b0, 1'b0, 1'b0, 1'b0, 3'h0, 12'h0};
    tx.randomize() with {addr == `CH0_STATIC_REG2_ADDR + 32'h100*i; wr_rd == 1; data == data_t;};
    dma_common::gen2bfm_mbox.put(tx);
   
    //static_reg3 and static_reg4 programming is not required for sanity testing
   end
endtask

task configure_interrupt_controller();
    //program int_enable-reg (by default 1)

    tx = new();
    data_t = 32'hFFFFFFFF;
    tx.randomize() with {addr == `CH0_INT_ENABLE_REG_ADDR; wr_rd == 1; data == data_t;};
    dma_common::gen2bfm_mbox.put(tx);

        //interrupt registers is 3 types
        //interrupt status register (read only unless "raw")
            //what is the cause of the interrupt?
        //interrupt enable register
            //gives option to enable or disable some interrupts
        //interrupt clear register (read only)
            //interrupt has been serviced, now we need to drop the interrupt
endtask

task configure_command();
    //CMD_REG0
    tx = new();
    tx.randomize() with {addr == `CH0_CMD_REG0_ADDR; wr_rd == 1; data == 32'h1000_0000;};
    dma_common::gen2bfm_mbox.put(tx);
     //CMD_REG1
    tx = new();
    tx.randomize() with {addr == `CH0_CMD_REG1_ADDR; wr_rd == 1; data == 32'h2000_0000;};
    dma_common::gen2bfm_mbox.put(tx);
     //CMD_REG2
    tx = new();
    tx.randomize() with {addr == `CH0_CMD_REG2_ADDR; wr_rd == 1; data == 32'd128;};
    dma_common::gen2bfm_mbox.put(tx);
     //CMD_REG3
    tx = new();
    data_t = {28'b0, 2'b0, 1'b1, 1'b1};
    tx.randomize() with {addr == `CH0_CMD_REG3_ADDR; wr_rd == 1; data == data_t;};
    dma_common::gen2bfm_mbox.put(tx);
endtask

task enable_channel();
    tx = new();
    tx.randomize() with {addr == `CH0_CH_ENABLE_REG_ADDR; wr_rd == 1; data == 32'h1;};
    dma_common::gen2bfm_mbox.put(tx);
endtask

task start_channel();
    tx = new();
    tx.randomize() with {addr == `CH1_CH_START_REG_ADDR; wr_rd == 1; data == 32'h1;};
    dma_common::gen2bfm_mbox.put(tx);
endtask

task configure_start_channel();
    //Configure static registers
    configure_static_registers();
    //Configure interrupt controller
    configure_interrupt_controller();
    //Configure command
    configure_command(); //command "list" is used for back to back transfers
    //Enable the channel
    //Start the channel
endtask

task run();
    $display("apb_gen::run");
    //basic test
    case (dma_common::testname)
        "test_core0_all_channels" : begin
            general_config();
            configure_start_channel();
        end
        "test_core0_ch0_sanity" : begin
            //reset, configuration, traffic(scenario) generation
            //reset is done in top most module
            //Configuration: We need to program CORE_CH0 registers so that it does transfers
            //traffic(scenario) generation: DMA controller does it

            //configuration flows section of spec
            //to start transfers on CH0:
            //general configuration
            general_config();
            //configure and start a channel
            configure_start_channel();
        end
        "test_reg_reset" : begin
            //dma_common::total_generated_txs = 216;
            dma_common::total_generated_txs = 24*dma_common::number_of_ch_testing + 24;
            //reading all the registers
            //CH0_CMD_REG0_ADDR till CH0_COUNT_REG_ADDR
            for (int j = 0; j < dma_common::number_of_ch_testing; j++) begin
                for (int i = 0; i <= 20; i++) begin
                    if (i == 19 || i == 9 || i == 10) continue;
                    tx = new();
                    tx.randomize() with {addr == 13'h100*j + 4*i; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);
                end
                // A0 to AC
                for (int i = 40; i <= 43; i++) begin
                    if (i == 19) continue;
                    tx = new();
                    tx.randomize() with {addr == 13'h100*j + 4*i; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);
                end
            end

                //Shared registers
                for (int i = 0; i <= 0; i++) begin //interrupt 1 to 7 don't exist
                    tx = new();
                    tx.randomize() with {addr == 13'h1000 + 4*i; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);
                end
                for (int i = 12; i <= 21; i++) begin
                    tx = new();
                    tx.randomize() with {addr == 13'h1000 + 4*i; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);
                end
                    //D0
                    tx = new();
                    tx.randomize() with {addr == 13'h10D0; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);
                    //E0
                    tx = new();
                    tx.randomize() with {addr == 13'h10E0 + 4*i; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);

                for (int i = 60; i <= 63; i++) begin
                    if (i == 62 || i == 63) continue;
                    tx = new();
                    tx.randomize() with {addr == 13'h1000 + 4*i; wr_rd == 0;}
                    dma_common::gen2bfm_mbox.put(tx);
                end
        end
        "test_reg_wr_rd" : begin
            dma_common::total_generated_txs = 2*(24*dma_common::number_of_ch_testing + 24)
            //writing all the registers
            //CH0_CMD_REG0_ADDR till CH0_COUNT_REG_ADDR
            for (int j = 0; j < dma_common::number_of_ch_testing; j++) begin
                for (int i = 0; i <= 20; i++) begin
                    if (i == 19 || i == 9 || i == 10) continue;
                    if (i >= 11 && i <= 15) continue; //skip read only registers from 2C to 3C
                    if (i == 18) continue; //read only register
                    if (i == 20) continue; //read only register
                    tx = new();
                    tx.randomize() with {addr == 13'h100*j + 4*i; wr_rd == 1;};
                    if (i == 16) tx.data[0] = 0;
                    if (i == 17) tx.data[0] = 0; //Don't want test_reg_wr_rd test to trigger a transfer (this results in unwanted behavior a register mismatch in this case)
                    dma_common::gen2bfm_mbox.put(tx);
                end
                // A0 to AC
                for (int i = 40; i <= 43; i++) begin
                    if (i == 43) continue; //read only register
                    tx = new();
                    tx.randomize() with {addr == 13'h100*j + 4*i; wr_rd == 1;};
                    if (i == 41) tx.data == 0; //don't clear any interrupt registers since design is not functioning | disabling the clearing of int_clr_ch_end so that int_count should not decrement
                    dma_common::gen2bfm_mbox.put(tx);
                end
            end

                //Shared registers
                //registers below are all read only
                /*for (int i = 0; i <= 0; i++) begin //int 1 to 7 don't exist
                    tx = new();
                    tx.randomize() with {addr == 13'h1000 + 4*i; wr_rd == 1;};
                    dma_common::gen2bfm_mbox.put(tx);
                end*/
                for (int i = 12; i <= 21; i++) begin
                    if (i ==13 || i == 15 || i == 17 || i == 19) continue; //CORE1 registers don't exist
                    tx = new();
                    tx.randomize() with {addr == 13'h1000 + 4*i; wr_rd == 1;};
                    dma_common::gen2bfm_mbox.put(tx);
                end
                //Read only registers
                /*    //D0
                    tx = new();
                    tx.randomize() with {addr == 13'h10D0; wr_rd == 1;};
                    dma_common::gen2bfm_mbox.put(tx);
                    //E0
                    tx = new();
                    tx.randomize() with {addr == 13'h10E0 + 4*i; wr_rd == 1;};
                    dma_common::gen2bfm_mbox.put(tx);

                for (int i = 60; i <= 63; i++) begin
                    if (i == 62 || i == 63) continue;
                    tx = new();
                    tx.randomize() with {addr == 13'h1000 + 4*i; wr_rd == 1;}
                    dma_common::gen2bfm_mbox.put(tx);
                end */

            //reading all the registers
            //CH0_CMD_REG0_ADDR till CH0_COUNT_REG_ADDR
            for (int j = 0; j < dma_common::number_of_ch_testing; j++) begin
                for (int i = 0; i <= 20; i++) begin
                    if (i == 19 || i == 9 || i == 10) continue;
                    if (i == 17) continue; //write only register
                    tx = new();
                    tx.randomize() with {addr == 13'h100*j + 4*i; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);
                end
                // A0 to AC
                for (int i = 40; i <= 43; i++) begin
                    if (i == 41) continue; //write only register
                    tx = new();
                    tx.randomize() with {addr == 13'h100*j + 4*i; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);
                end
            end

                //Shared registers
                for (int i = 0; i <= 0; i++) begin //int 1 to 7 don't exist
                    tx = new();
                    tx.randomize() with {addr == 13'h1000 + 4*i; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);
                end
                for (int i = 12; i <= 21; i++) begin
                    if (i ==13 || i == 15 || i == 17 || i= == 18 || i == 19) continue;
                    tx = new();
                    tx.randomize() with {addr == 13'h1000 + 4*i; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);
                end
                    //D0
                    tx = new();
                    tx.randomize() with {addr == 13'h10D0; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);
                    //E0
                    tx = new();
                    tx.randomize() with {addr == 13'h10E0 + 4*i; wr_rd == 0;};
                    dma_common::gen2bfm_mbox.put(tx);

                for (int i = 60; i <= 63; i++) begin
                    if (i == 62 || i == 63) continue;
                    tx = new();
                    tx.randomize() with {addr == 13'h1000 + 4*i; wr_rd == 0;}
                    dma_common::gen2bfm_mbox.put(tx);
                end
        end
    endcase
endtask
endclass