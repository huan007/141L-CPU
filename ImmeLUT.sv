//LUT for Immediates
//5 bits input to specify 32 Immediates. Immediates is 8 bits
module InstROM #(parameter IW=5, OW=8) (
	input	[IW-1:0] InstAddress,	//address pointer
	output logic[OW-1:0] InstOut);
	
	logic [OW-1:0] inst_rom [2**IW];

	initial
		$readmemb("immediates.txt", inst_rom);
	
	//Look up table
	assign InstOut = inst_rom[InstAddress];

endmodule


