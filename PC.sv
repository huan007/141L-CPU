//Program Counter (Fetch)
module IF (
	input branchsig,
	input branchtype,
	input zero,
	input negative,
	input [7:0] BranchOut,
	input reset,
	input halt,
	input clk,
	//input [7:0] newAddress,
	output logic[7:0] core);

	always_ff @ (posedge clk)
		if(reset)
			core <= 0;
		else if (halt)
			core <= core;
		else if (branchsig==1'b1) //if branch instruction
			if(branchtype==1'b0)
				if(negative==1'b0)
					core <= core + BranchOut;
				else
					core <= core + 1; //blt
			else
				if(zero==1'b1)
					core <= core + BranchOut;
				else
					core <= core + 1; //bne
		else
			core <= core + 1; //normal advance
		//	core <= newAddress;
endmodule
