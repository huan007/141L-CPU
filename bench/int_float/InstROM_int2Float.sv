//Instruction
module InstROM_int2Float #(parameter IW=9, DW=8) (
	input	[DW-1:0] InstAddress,	//address pointer
	output logic[IW-1:0] InstOut);

	logic [IW-1:0] inst_rom [2**DW];

	initial
		$readmemb("i2f_stripped.txt", inst_rom);

	//Look up table
	assign InstOut = inst_rom[InstAddress];

endmodule
