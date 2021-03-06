//LUT for branch
//6 bit input to specify 64 direct instruction address
//Output is 8 bits instruction address
module branchLUT #(parameter IW=6, OW=8) (
	input	[IW-1:0] InstAddress,	//address pointer
	output logic[OW-1:0] BranchOut);

	logic [OW-1:0] inst_rom [2**IW];

	initial
		$readmemh("branch_hex.txt", inst_rom);

	//Look up table
	assign BranchOut = inst_rom[InstAddress];

endmodule
