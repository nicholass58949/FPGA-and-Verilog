`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/10 18:52:35
// Design Name: 
// Module Name: pci9054_interf
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////




module pci9054_interf#
(
		// Users to add parameters here
	
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Carries the upper 30 bits of physical Address Bus.
		parameter  integer C_PCI_ADDR_WIDTH	= 8
)
(
	// Users to add ports here
	
	// Unix signal
	input [3:0] fifo_rst_i,           // usedw ----> fifo_rst_i --> fifo_back_rst1_o --->fifo rst 2

	// input fifo_rst_i,

	// System startup flag
	input sys_flag_i,          ////usedw ----> address
	// Module reset signal
	//output reg [3:0] rst_n_o,

	output reg rst_n_o,             // add --> rst_n_o --> fifo rst 1

	// Set receive enable
	output reg [3:0] rxd_ena_o,
	// Set receive edge
	// output reg [3:0] rxd_edge_o,
	// Allocate memory size
	output reg [31:0] alloc_mem_o,
	// Read mode
	output reg [3:0] rd_mode_o,
		


	// Read data interface 1
	input [12:0] fifo_wr_usedw1_i, 		//the front end fifo usedw 
	input [13:0] fifo_rd_usedw1_i, 		//the back end fifo usedw 
	input [63:0] fifo_usedw1_i, 		//nvme usedw + ddr usedw + front end usedw + back end fifo usedw
	output fifo_rd_req1_o, 				//fifo data read request
	output fifo_tx_req1_o,
	output reg [31:0] fifo_tx_data1_i, 		//fifo data read data

	
	input clk100M,	

	
	// Converted back end FIFO reset signal
	output reg fifo_back_rst1_o,


	// output reg fifo_rst2_o,

	output reg [15:0] txd_frame_o,
	output reg [15:0] txd_width_o,
	output reg [15:0] txd_height_o,
	// User ports ends
	// Do not modify the ports beyond this line	

	// PCI9054 Clock Signal
	input p_clk_i,
	// PCI9054 Reset Signal. This Signal is Active LOW
	input p_rst_n_i,
	// Address Bus
	input [C_PCI_ADDR_WIDTH-1 : 0] p_addr_i,
	// Data Bus, Carries 8-, 16-, or 32-bit data quantities, depending upon bus-width configuration.
	inout [31 : 0] p_data_io,
	// Hold Request, Asserted to request use of the Local Bus.
	input p_lhold_i,
	// Write/Read, Asserted low for reads and high for writes.
	input p_lwr_i,
	// Address Strobe, Indicates valid address and start of new Bus access. Asserted for first clock of Bus access.
	input p_ads_n_i,
	// Burst Last, Signal driven by the current Local Bus Master to indicate the last transfer in a Bus access.
	input p_blast_i,
	// Burst Terminate
	output p_bterm_o,
	// Hold Acknowledge, Asserted by the Local Bus arbiter when control is granted in response to LHOLD.
	output reg p_lholda_o,
	// Ready Input/Output
	output reg p_ready_n_o
);
// IOBUF control
genvar i;
wire lwr_sel;
wire [31 : 0] ldata_i;
wire [31 : 0] ldata_o;

BUFG BUFG_inst(.O(lwr_sel),.I(p_lwr_i));
// function called IOBUF_loop, Used for inout type data
generate 
    for(i = 0;i < 32;i = i + 1)
    begin : IOBUF_loop
        IOBUF IOBUF_inst(.I(ldata_i[i]),.IO(p_data_io[i]),.O(ldata_o[i]),.T(lwr_sel));
    end    
endgenerate	

// Register define
// State variable
reg [1 : 0] cstate;
reg [1 : 0] nstate;
// Control read or write operate. low valid
reg data_ctrl;
// Initiates write operate
wire w_operate;
// Initiates read operate
wire r_operate;
// Test register
reg [31 : 0]test_reg; 



reg [12:0] wr_number_o;
reg [13:0] rd_number_o;

// // Sync unix signal
// wire [3:0] fifo_rst_sig;

wire fifo_rst_sig;
// wire sync_flag1;


// Define the states of state machine
parameter	s_idle    = 2'b01, // Idle 
			s_operate = 2'b10; // Read or write

// Control state machine implementation
always @(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) cstate <= s_idle;
	else cstate <= nstate;
end
always @(*) begin
	case(cstate)
		s_idle    : begin if(!p_ads_n_i) nstate = s_operate;
					      else nstate = s_idle; end
		s_operate : begin if(p_blast_i) nstate = s_operate;
					      else nstate = s_idle; end
		default   : begin nstate = s_idle; end
	endcase
end
always @(*) begin
	case(cstate)
		s_idle    :begin p_ready_n_o  = 1'b1; end
		s_operate :begin p_ready_n_o  = 1'b0; end
		default   :begin p_ready_n_o  = 1'b1; end
	endcase
end
always @(*) begin
    case(cstate)
        s_idle    :begin data_ctrl= 1'b1; end
        s_operate :begin data_ctrl= 1'b0; end
        default   :begin data_ctrl= 1'b1; end
    endcase
end
always @(posedge p_clk_i or negedge p_rst_n_i)begin
	if(!p_rst_n_i) p_lholda_o <= 1'b1;
	else if(!p_lhold_i) p_lholda_o <= 1'b0;
	else p_lholda_o <= 1'b1;
end
// Burst Terminate is disabled
assign p_bterm_o = 1'b1;
// Generate a pulse to initiate write operate.
assign w_operate = (p_lwr_i) && (!data_ctrl);
// Generate a pulse to initiate read operate.
assign r_operate = (!p_lwr_i) && (!data_ctrl);

	// Add user logic here
// Reset sync
xpm_cdc_array_single #(
	.DEST_SYNC_FF(4),				// DECIMAL; range: 2-10
	.INIT_SYNC_FF(0),				// DECIMAL; 0=disable simulation init values, 1=enable simulation init values
	.SIM_ASSERT_CHK(0),				// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	.SRC_INPUT_REG(0), 				// DECIMAL; 0=do not register input, 1=register input
	.WIDTH(4) 						// DECIMAL; range: 1-1024
)
xpm_cdc_array_single_inst (

	.dest_out(fifo_rst_sig),		// WIDTH-bit output: src_in synchronized to the destination clock domain. This output is registered.
	.dest_clk(p_clk_i),				// 1-bit input: Clock signal for the destination clock domain.
	.src_clk(0),					// 1-bit input: optional; required when SRC_INPUT_REG = 1
	.src_in(fifo_rst_i)				// WIDTH-bit input: Input single-bit array to be synchronized to destination clock
									// domain. It is assumed that each bit of the array is unrelated to the others. This
									// is reflected in the constraints applied to this macro. To transfer a binary value
									// losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.
);
// always@(posedge p_clk_i or negedge p_rst_n_i) begin
// 	if(!p_rst_n_i) {fifo_back_rst4_o,fifo_back_rst3_o,fifo_back_rst2_o,fifo_back_rst1_o} <= 4'h0; //high reset
// 	else {fifo_back_rst4_o,fifo_back_rst3_o,fifo_back_rst2_o,fifo_back_rst1_o} <= fifo_rst_sig;
// end


always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) {fifo_back_rst1_o} <= 1'h0; //high reset
	else {fifo_back_rst1_o} <= fifo_rst_sig;
end


// Pci write operate
always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) test_reg <= 32'h2024_0321; //change the date of the logic
	else if((p_addr_i == 0) && (w_operate)) test_reg <= ldata_o; //test register
	else test_reg <= test_reg;
end
always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) rst_n_o <= 4'hf;
	else if((p_addr_i == 1) && (w_operate)) rst_n_o <= ldata_o; //reset signal
	else rst_n_o <= rst_n_o;
end
// always@(posedge p_clk_i or negedge p_rst_n_i) begin
// 	if(!p_rst_n_i) {pud_sel_o,tr_sel_o,lp_sel_o} <= 11'h0;
// 	else if((p_addr_i == 2) && (w_operate)) {pud_sel_o,tr_sel_o,lp_sel_o} <= ldata_o; //interface matching
// 	else {pud_sel_o,tr_sel_o,lp_sel_o} <= {pud_sel_o,tr_sel_o,lp_sel_o};
// end
always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) rxd_ena_o <= 4'h0; //disable
	else if((p_addr_i == 3) && (w_operate)) rxd_ena_o <= ldata_o;
	else rxd_ena_o <= rxd_ena_o;
end
// always@(posedge p_clk_i or negedge p_rst_n_i) begin
// 	if(!p_rst_n_i) rxd_edge_o <= 4'h0; //negedge
// 	else if((p_addr_i == 4) && (w_operate)) rxd_edge_o <= ldata_o;
// 	else rxd_edge_o <= rxd_edge_o;
// end
always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) alloc_mem_o <= 32'h0; //equal distribution
	else if((p_addr_i == 5) && (w_operate)) alloc_mem_o <= ldata_o;
	else alloc_mem_o <= alloc_mem_o;
end
always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) rd_mode_o <= 4'h0; //normal
	else if((p_addr_i == 6) && (w_operate)) rd_mode_o <= ldata_o;
	else rd_mode_o <= rd_mode_o;
end

always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) fifo_tx_data1_i <= 32'b0; //initial
	else if((p_addr_i == 7) && (w_operate)) fifo_tx_data1_i <= ldata_o;
	else fifo_tx_data1_i <= fifo_tx_data1_i;
end


// always@(posedge p_clk_i or negedge p_rst_n_i) begin
// 	if(!p_rst_n_i) txd_send_time_o <= 32'b0; //initial
// 	else if((p_addr_i == 8) && (w_operate)) txd_send_time_o <= ldata_o;
// 	else txd_send_time_o <= txd_send_time_o;
// end

always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) wr_number_o<= 13'b0; //initial
	else if((p_addr_i == 9) && (w_operate)) wr_number_o <= ldata_o;
	else wr_number_o <= wr_number_o;
end

always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) rd_number_o <= 14'b0; //initial
	else if((p_addr_i == 10) && (w_operate)) rd_number_o <= ldata_o;
	else rd_number_o <= rd_number_o;
end


always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) txd_frame_o <= 32'b0; //initial
	else if((p_addr_i == 11) && (w_operate)) txd_frame_o <= ldata_o;
	else txd_frame_o <= txd_frame_o;
end

always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) txd_width_o <= 32'b0; //initial
	else if((p_addr_i == 12) && (w_operate)) txd_width_o <= ldata_o;
	else txd_width_o <= txd_width_o;
end

always@(posedge p_clk_i or negedge p_rst_n_i) begin
	if(!p_rst_n_i) txd_height_o <= 32'b0; //initial
	else if((p_addr_i == 13) && (w_operate)) txd_height_o <= ldata_o;
	else txd_height_o <= txd_height_o;
end



// Pci read operate
assign ldata_i = ((p_addr_i == 0) && (r_operate)) ? test_reg : //test register
				 ((p_addr_i == 1) && (r_operate)) ? {28'h0,rst_n_o} :
				// ((p_addr_i == 2) && (r_operate)) ? {21'h0,pud_sel_o,tr_sel_o,lp_sel_o} :
				 ((p_addr_i == 3) && (r_operate)) ? {28'h0,rxd_ena_o} :
				//  ((p_addr_i == 4) && (r_operate)) ? {28'h0,rxd_edge_o} :
				 ((p_addr_i == 5) && (r_operate)) ? alloc_mem_o :
				 ((p_addr_i == 6) && (r_operate)) ? {28'h0,rd_mode_o} :
				
				 ((p_addr_i == 7) && (r_operate)) ? fifo_tx_data1_i :
				 // ((p_addr_i == 8) && (r_operate)) ? txd_send_time_o :
				 ((p_addr_i == 9) && (r_operate)) ? {19'h0,wr_number_o}:
				 ((p_addr_i == 10) && (r_operate)) ? {18'h0,rd_number_o} :
				 ((p_addr_i == 11) && (r_operate)) ? {16'h0,txd_frame_o} :
				 ((p_addr_i == 12) && (r_operate)) ? {16'h0,txd_width_o} :
				 ((p_addr_i == 13) && (r_operate)) ? {16'h0,txd_height_o} :


//				 ((p_addr_i == 253) && (r_operate)) ? {28'h0,fifo_back_rst4_o,fifo_back_rst3_o,fifo_back_rst2_o,fifo_back_rst1_o} :
				 ((p_addr_i == 253) && (r_operate)) ? {31'h0,fifo_back_rst1_o} :
				 ((p_addr_i == 254) && (r_operate)) ? {31'h0,sys_flag_i} :
				 ((p_addr_i == 255) && (r_operate)) ? 32'hfee5_0311 : 32'h5555_5555;

assign fifo_rd_req1_o = ((p_addr_i == 36) && (r_operate)); //1 channel fifo read request
assign fifo_tx_req1_o = ((p_addr_i == 37) && (w_operate)); //1 channel fifo write request


	// User logic ends
// ila_0 ila9054(
// .clk(clk100M),
// .probe0(PXI_trig0),
// .probe1(sync_flag_temp1),
// .probe2(n_second_rx1),
// .probe3(second_rx1)
//.probe4(pud_sel_o),
//.probe5(tr_sel_o),
//.probe6(lp_sel_o),
//.probe7(rxd_ena_o),
//.probe8(rxd_edge_o),
//.probe9(txd_start_o),
//.probe10(txd_edge_o),
//.probe11(txd_baudrate_o),
//.probe12(txd_code_o),
//.probe13(txd_pattern_o),
//.probe14(txd_number_o),
//.probe15(fifo_rd_usedw1_i),
//.probe16({fifo_rd_data1_i[7:0],fifo_rd_data1_i[15:8],fifo_rd_data1_i[23:16],fifo_rd_data1_i[31:24]}),
//.probe17(rxd_number1_o),
//.probe18(rxd_pattern1_o),
//.probe19(rxd_length1_o),
//.probe20(rxd_code1_o),
//.probe21(rxd_filter_num1_o)
//);

endmodule 


