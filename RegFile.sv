//Register File
//Allow 2 simultaneous read, 1 write per cycle. COUT is a special register
//that will be over-written every R-type instruction.
module reg_file #(parameter count = 3, DW = 8) (
	input clk,
	input [count-2:0]	rs,
	input [count-1:0]	rt,
	input write_enable,
	input cout_write_enable,
	input [DW-1:0] write_data,
	input [DW-1:0] cout_data,
	output logic [DW-1:0] rs_val_o,
	output logic [DW-1:0] rt_val_o
);

//the core itself
logic [count-1:0] RF [2**count];
//two simultaneous, continuous read
assign rs_val_o = RF [{0,rs}];
assign rt_val_o = RF [rt];

//synchronous (clocked) write to rs 
always_ff @ (posedge clk)
  begin
	   if (write_enable)
		    RF [{0,rs}] <= write_data;
	   if (cout_write_enable)		
		    RF [3'b111] <= cout_data;	//Write to COUT if signal is on
	end

endmodule
