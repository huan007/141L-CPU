//Instruction
module InstROM #(parameter IW=9, DW=8) (
	input	[DW-1:0] InstAddress,	//address pointer
	output logic[IW-1:0] InstOut);

	logic [IW-1:0] inst_rom [2**DW];

	initial
		$readmemb("instructions.txt", inst_rom);

	//Look up table
	assign InstOut = inst_rom[InstAddress];

endmodule
