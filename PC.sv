//Program Counter (Fetch)
module IF (
	input reset,
	input halt,
	input clk,
	input [7:0] newAddress,
	output logic[7:0] core);

	always_ff @ (posedge clk)
		if(reset)
			core <= 0;
		else if (halt)
			core <= core;
		else
			core <= newAddress;

endmodule
