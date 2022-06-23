class dma_common;
// define macros for each register's address instead of hardcoding values in different files
//CH0 registers
`define CH0_CMD_REG0_ADDR   13h'0 
static virtual axi_intf axi_vif;
static virtual apb_intf apb_vif;
static virtual periph_intf periph_vif;
static mailbox gen2bfm_mbox = new();
static mailbox mon2cov_mbox = new();
static mailbox apbmon2ref_mbox = new();
static mailbox aximon2ref_mbox = new();
static string testname;
static bit dut_reset_applied;
static int total_generated_txs = -1;
static int total_driven_txs = 0;
static int number_of_ch_testing = 1;
static int reg_error_count = 0;
static int data_mismatch = 0;
static int data_match = 0;

//declare and define default values (using function new()) for registers needed to configure start channel, except enable and start channel
//which can be configured in gen file itself

static bit [3:0] total_channels = 1; 
static bit [7:0] ch_active = 8'b0000_0001;
endclass