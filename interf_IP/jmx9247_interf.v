`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/18 15:06:34
// Design Name: 
// Module Name: jmx9247_interf
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

`define WIDTH 800
`define HEIGHT 525
`define WIDTH_EN 640
`define HEIGHT_EN 480


module jmx9247_interf(

	input clk_i, 						//main clock
	input [3:0] rst_n_i, 				//reset signal
	// input [3:0] rxd_ena_i, 				//set receive enable
	// input [3:0] rxd_edge_i, 			//set receive edge
	// Pcm send control interface
	// input [31:0] alloc_mem_o, 					

	// input [3:0] rd_mode_o, 		
    input [31:0] fifo_tx_data1_i,

	// output 	sync_flag_temp1,
	// output 	fifo_rst2_o,
	// output fifo_wr_req2_o,

	// output reg RNG_0,
	// output reg RNG_1,
	// output reg RNG_2,
	// output reg RNG_3,
	// output reg RNG_4,
	// output reg RNG_5,
	// output reg RNG_6,
	// output reg RNG_7,
	// output reg RNG_8,
	// output reg RNG_9,
	// output reg RNG_10,
	// output reg RNG_11,
	// output reg RNG_12,
	// output reg RNG_13,
	// output reg RNG_14,
	// output reg RNG_15,
	// output reg RNG_16,
	// output reg RNG_17,
// 
	// output reg CNTL_0,
	// output reg CNTL_1,
	// output reg CNTL_2,
	// output reg CNTL_3,
	// output reg CNTL_4,
	// output reg CNTL_5,
	// output reg CNTL_6,
	// output reg CNTL_7,
	// output reg CNTL_8,

	output reg [17:0] RGB,
	output reg [8:0] CNTL,
	output RNG0,
	output RNG1,
	output PRE,
	//output PCLK_IN,
	output reg DE_IN,
	output PWRDWN
    );

assign RNG0 = 0;
assign RNG1 = 0;
assign PRE = 0;
assign PWRDWN = 0;
// assign DE_IN = 1;
reg [11:0] H_cnt;
reg [11:0] V_cnt;
// reg [11:0] H_sync;
// reg [11:0] V_sync;

always @(posedge clk_i or negedge rst_n_i[0])
begin
	if(~rst_n_i[0])
	begin
		H_cnt <= 12'b0;
		V_cnt <= 12'b0;
	end
	else if(H_cnt == `WIDTH)
	begin
		H_cnt <= 12'b0;
		V_cnt <= V_cnt + 1;
	end
	else if(V_cnt == `HEIGHT)
	begin
		H_cnt <= H_cnt + 1;
		V_cnt <= 12'b0;
	end
	else
	begin
		H_cnt <= H_cnt + 1;
		V_cnt <= V_cnt;
	end
end


always @(posedge clk_i or negedge rst_n_i[0])
begin
	if(~rst_n_i[0])
	begin
		DE_IN <= 1'b0;
	end
	else if( ( ( H_cnt+2 > (`WIDTH - `WIDTH_EN)>>1 ) && (V_cnt-2 < (`HEIGHT + `HEIGHT_EN)>>1) )
			&& ( ( V_cnt > (`HEIGHT - `HEIGHT_EN)>>1 ) && (V_cnt < (`HEIGHT + `HEIGHT_EN)>>1) )  )
	begin
		DE_IN <= 1'b1;
	end
	else
	begin
		DE_IN <= 1'b0;
	end
end


// always @(posedge clk_i or negedge rst_n_i[0])
// begin
// 	if(~rst_n_i[0])
// 	begin
// 		DE_IN <= 1'b0;
// 	end
// 	else if(fifo_tx_data1_i[26] == 1'b1)
// 	begin
// 		DE_IN <= 1'b1;
// 	end
// 	else
// 	begin
// 		DE_IN <= 1'b0;
// 	end
// end


always @(posedge clk_i or negedge rst_n_i[0])
begin
	if(~rst_n_i[0])
	begin
		RGB <= 18'b0;
		CNTL <= 9'b0;
	end
	else if(DE_IN)
	begin
		RGB <= fifo_tx_data1_i[17:0];
		CNTL <= CNTL;
	end
	else if(~DE_IN)
	begin
		RGB <= RGB;
		CNTL <= fifo_tx_data1_i[26:18];
	end
	else
	begin
		RGB <= RGB;
		CNTL <= CNTL;
	end
end

// always @(posedge clk_i or negedge rst_n_i[0])
// begin
// 	if(~rst_n_i[0])
// 	begin
// 		RNG_0 <= 1'b0;
// 		RNG_1 <= 1'b0;
// 		RNG_2 <= 1'b0;
// 		RNG_3 <= 1'b0;
// 		RNG_4 <= 1'b0;
// 		RNG_5 <= 1'b0;
// 		RNG_6 <= 1'b0;
// 		RNG_7 <= 1'b0;
// 		RNG_8 <= 1'b0;
// 		RNG_9 <= 1'b0;
// 		RNG_10 <= 1'b0;
// 		RNG_11 <= 1'b0;
// 		RNG_12 <= 1'b0;
// 		RNG_13 <= 1'b0;
// 		RNG_14 <= 1'b0;
// 		RNG_15 <= 1'b0;
// 		RNG_16 <= 1'b0;
// 		RNG_17 <= 1'b0;
// 	end
// 	else if(DE_IN)
// 	begin
// 		RNG_0 <= fifo_tx_data1_i[0];
// 		RNG_1 <= fifo_tx_data1_i[1];
// 		RNG_2 <= fifo_tx_data1_i[2];
// 		RNG_3 <= fifo_tx_data1_i[3];
// 		RNG_4 <= fifo_tx_data1_i[4];
// 		RNG_5 <= fifo_tx_data1_i[5];
// 		RNG_6 <= fifo_tx_data1_i[6];
// 		RNG_7 <= fifo_tx_data1_i[7];
// 		RNG_8 <= fifo_tx_data1_i[8];
// 		RNG_9 <= fifo_tx_data1_i[9];
// 		RNG_10 <= fifo_tx_data1_i[10];
// 		RNG_11 <= fifo_tx_data1_i[11];
// 		RNG_12 <= fifo_tx_data1_i[12];
// 		RNG_13 <= fifo_tx_data1_i[13];
// 		RNG_14 <= fifo_tx_data1_i[14];
// 		RNG_15 <= fifo_tx_data1_i[15];
// 		RNG_16 <= fifo_tx_data1_i[16];
// 		RNG_17 <= fifo_tx_data1_i[17];
// 	end
// 	else
// 	begin
// 		RNG_0 <= RNG_0;
// 		RNG_1 <= RNG_1;
// 		RNG_2 <= RNG_2;
// 		RNG_3 <= RNG_3;
// 		RNG_4 <= RNG_4;
// 		RNG_5 <= RNG_5;
// 		RNG_6 <= RNG_6;
// 		RNG_7 <= RNG_7;
// 		RNG_8 <= RNG_8;
// 		RNG_9 <= RNG_9;
// 		RNG_10 <= RNG_10;
// 		RNG_11 <= RNG_11;
// 		RNG_12 <= RNG_12;
// 		RNG_13 <= RNG_13;
// 		RNG_14 <= RNG_14;
// 		RNG_15 <= RNG_15;
// 		RNG_16 <= RNG_16;
// 		RNG_17 <= RNG_17;
// 	end
// end
// 
// always @(posedge clk_i or negedge rst_n_i[0])
// begin
// 	if(~rst_n_i[0])
// 	begin
// 		CNTL_0 <= 1'b0;
// 		CNTL_1 <= 1'b0;
// 		CNTL_2 <= 1'b0;
// 		CNTL_3 <= 1'b0;
// 		CNTL_4 <= 1'b0;
// 		CNTL_5 <= 1'b0;
// 		CNTL_6 <= 1'b0;
// 		CNTL_7 <= 1'b0;
// 		CNTL_8 <= 1'b0;
// 	end
// 	else if(DE_IN)
// 	begin
// 		CNTL_0 <= fifo_tx_data1_i[18];
// 		CNTL_1 <= fifo_tx_data1_i[19];
// 		CNTL_2 <= fifo_tx_data1_i[20];
// 		CNTL_3 <= fifo_tx_data1_i[21];
// 		CNTL_4 <= fifo_tx_data1_i[22];
// 		CNTL_5 <= fifo_tx_data1_i[23];
// 		CNTL_6 <= fifo_tx_data1_i[24];
// 		CNTL_7 <= fifo_tx_data1_i[25];
// 		CNTL_8 <= fifo_tx_data1_i[26];
// 	end
// 	else
// 	begin
// 		CNTL_0 <= CNTL_0;
// 		CNTL_1 <= CNTL_1;
// 		CNTL_2 <= CNTL_2;
// 		CNTL_3 <= CNTL_3;
// 		CNTL_4 <= CNTL_4;
// 		CNTL_5 <= CNTL_5;
// 		CNTL_6 <= CNTL_6;
// 		CNTL_7 <= CNTL_7;
// 		CNTL_8 <= CNTL_8;
// 	end
// end

endmodule

