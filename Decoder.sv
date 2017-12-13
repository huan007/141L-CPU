//Decoder
//Basic LUT depend on what instruction it is
//
module decoder #(parameter IW=8, OW=10) (
	input  logic[IW-1:0] 			instruction,
	output logic [OW-1:0] 	control_signals,
	output logic special_reg,
	output logic temp_mem);

	logic [OW-1:0] decoder_rom [2**IW];

	initial
		$readmemb("signals.txt", decoder_rom);
	
	//Look up table
	//assign InstOut = decoder_rom[instruction];

always_comb
begin
	//Generate control signals
	casez (instruction)
		//HALT
		8'b01110000: begin
			control_signals = decoder_rom[6];
			//special_reg = 1'bx;
			temp_mem = 1'bx;
		end

		//IMME
		8'b10??????: begin
			control_signals = decoder_rom[0];
			//special_reg = 1'bx;
			temp_mem = 1'bx;
		end
		//BLT
		8'b110?????: begin
			control_signals = decoder_rom[1];
			//special_reg = 1'bx;
			temp_mem = 1'bx;
		end
		//BNE
		8'b111?????: begin
			control_signals = decoder_rom[2];
			//special_reg = 1'bx;
			temp_mem = 1'bx;
		end
		//LW
		8'b01101???: begin
			control_signals = decoder_rom[4];
			//special_reg = 1'bx;
			temp_mem = 0;
		end
		//SW
		8'b01100???: begin
			control_signals = decoder_rom[5];
			//special_reg = 1'bx;
			temp_mem = 0;
		end
		//ALW
		8'b0111110?: begin
			control_signals = decoder_rom[4];
			//special_reg = 1'bx;
			temp_mem = 1;
		end
		//ASW
		8'b011111??: begin
			control_signals = decoder_rom[5];
			//special_reg = 1'bx;
			temp_mem = 1;
		end

		//R-type I guess???
		default: begin
			control_signals = decoder_rom[3];
			temp_mem = 1'bx;
		end

	endcase
	//Generate specialReg
	assign special_reg = ~control_signals[6] & control_signals [3];
end

endmodule
