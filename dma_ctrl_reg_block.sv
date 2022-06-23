//reg [31:0] ch0_cmd_reg0; //Vector(DUT) => I am changing it to a class definition format

class ch0_cmd_reg0;
    reg [31:0] value;
    reg [31:0] rd_start_addr;
    covergroup ch0_cmd_reg0_cg;
        RD_START_ADDR_CP : coverpoint rd_start_addr {
            option.auto_bin_max = 8; //divided the whole range into 8 regions on which coverage will be done
        }
    endgroup

    function new();
        ch0_cmd_reg0_cg = new();
    endfunction

    //we can do 3 things to the register: 1. reset 2. write 3. read
    //when we apply reset to a register, its contents will become 0 (unless it is mentioned in a different manner)

    function void reset();
        rd_start_addr = 0;
    endfunction

    function void write(reg [31:0] data);
        value = data;
        rd_start_addr = data[31:0];
        ch0_cmd_reg0_cg.sample(); //whenever register write is done, sampling is also done, so that coverage collection will happen
    endfunction

    function reg [31:0] read();
        return {rd_start_addr};
    endfunction
endclass

//many classes like above one for each register

class dma_ctrl_reg_block;
//Instantiate all registers
ch0_cmd_reg0 ch0_cmd_reg0_i = new();
//Reset all registers function
function void reset_reg(); //this method is called from the reference model, all register values will get reset
    ch0_cmd_reg0_i.reset();
    //and so on
endfunction

function void write_reg(reg [31:0] addr, reg [31:0] data); //Write registers function : write_reg called from reference model
case(addr)
`CH0_CMD_REG0_ADDR : ch0_cmd_reg0_i.write(data);
//and so on
endcase
endfunction

function reg [31:0] read_reg(reg [31:0] addr); //Read registers function : read_reg called from reference model
case(addr)
`CH0_CMD_REG0_ADDR : return ch0_cmd_reg0_i.read(); //read will return register value
//and so on
endcase
endfunction

endclass