//Program Counter (Fetch)
module IF (
	input branchsig,
	input branchtype,
	input cmp,
	input [7:0] BranchOut,
	input reset,
	input halt,
	input [7:0] clk,
	//input [7:0] newAddress,
	output logic[7:0] core);
	reg [7:0] AddressReg;

	assign core = AddressReg;

	always_ff @ (posedge clk)
		if(reset)
			AddressReg <= 0;
		else if (halt)
			AddressReg <= AddressReg;
		else if (branchsig==1'b1) //if branch instruction
			if(branchtype==1'b0)
				if(cmp<2'h00)
					AddressReg <= AddressReg + BranchOut;
				else
					AddressReg <= AddressReg + 1; //blt
			else
				if(cmp!=2'h00)
					AddressReg <= AddressReg + BranchOut;
				else
					AddressReg <= AddressReg + 1; //bne
		else
			AddressReg <= AddressReg + 1; //normal advance
		//	core <= newAddress;
endmodule
