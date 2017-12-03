//Data Memory
module data_mem #(parameter AW=8, DW=8) (
	input clk,
	input [AW-1:0] DataAddress,
	input ReadMem,
	input WriteMem,
	input [DW-1:0] DataIn,
	output logic[DW-1:0] DataOut);

//The core
logic [DW-1:0] mem_core [2**AW];

always_comb 
	if (ReadMem) begin
		DataOut = mem_core[DataAddress];
		$display("Memory Read M[%d] = %d", DataAddress, DataOut);
	end else
		DataOut = 8'bZ;

always_ff @ (posedge clk)
	if (WriteMem) begin
		mem_core[DataAddress] = DataIn;
		$display("Memory Write M[%d] = %d", DataAddress, DataIn);
	end 

endmodule

