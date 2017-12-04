//Decoder
//Basic LUT depend on what instruction it is
//
module decoder #(parameter IW=5, OW=10) (
	input [IW-1:0] 			instruction,
	output logic [OW-1:0] 	control_signals);

	logic [OW-1:0] decoder_rom [2**IW];

	initial
		$readmemb("instructions.txt", decoder_rom);
	
	//Look up table
	assign InstOut = decoder_rom[instruction];

endmodule
