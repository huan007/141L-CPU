//Program Counter (Fetch)
module IF (
	input reset,
	input halt,
	input clk,
	input [7:0] newAddress,
	output logic[7:0] PC);

	always_ff @ (posedge clk)
		if(reset)
			PC <= 0;
		else if (halt)
			PC <= PC;
		else
			PC <= newAddress;

endmodule
