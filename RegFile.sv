//Register File
module reg_file #(parameter count = 2, DW = 8) (
	input clk,
	input [count-1:0]	rs,
						rt,
	input write_enable,
	input [DW-1:0] write_data,
	output logic [DW-1:0] rs_val_o,
	output logic [DW-1:0] rt_val_o
);

//the core itself
logic [count-1:0] RF [2**count];
//two simultaneous, continuous read
assign rs_val_o = RF [rs];
assign rt_val_o = RF [rt];

//synchronous (clocked) write to rs 
always_ff @ (posedge clk)
	if (write_enable)
		RF [rt] <= write_data;

endmodule
