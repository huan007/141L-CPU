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
		else if (branchsig==0b'1) //if branch instruction
			case(branchtype) //branch lt or ne
				1b'0:	(negative==0b'0) ? core <= core + BranchOut : core <= core + 1 //blt
				1b'1: (zero==0b'1) ? core <= core + BranchOut : core <= core + 1 //bne
			endcase
		else
			core <= core + 1; //normal advance
		//	core <= newAddress;
endmodule
