// Create Date:     2017.05.05
// Latest rev date: 2017.10.26
// Created by:      J Eldon
// Design Name:     CSE141L
// Module Name:     ALU (Arithmetic Logical Unit)


//This is the ALU module of the core, op_code_e is defined in definitions.v file
// Includes new enum op_mnemonic to make instructions appear literally on waveform.
import definitions::*;

module alu (input  [7:0]       rs_i ,	 // operand s
            input  [7:0]       rt_i	,	 // operand t
    		input              ov_i ,	 // shift-in
            input  [8:0]       op_i	,	 // instruction / opcode
            output logic [7:0] result_o,	 // rslt
			output logic       ov_o);

op_code    op3; 	                     // type is op_code, as defined
assign op3 = op_code'(op_i[8:6]);        // map 3 MSBs of op_i to op3 (ALU), cast to enum

always_comb								  // no registers, no clocks
  begin
    result_o   = 'd0;                     // default or NOP result
    ov_o       = 'd0;
  case (op3)   						      // using top 3 bits as ALU instructions
	SLL: begin							  // logical shift left
	       ov_o     = rs_i[7];			  // generate shift-out bit to left
	       result_o = {rs_i[6:0],ov_i};	  // accept previous shift-out from right
	 	 end
	SRL: begin							  // logical right shift
		   ov_o     = rs_i[0];
		   result_o = {ov_i,rs_i[7:1]};	  // opposite of SLL
		 end
//HALT: // handled in top level / decode -- not needed in ALU
    LSW: begin                            // store word or load word
		   result_o = rs_i;				  // pass rs_i to output	(a+0)
		   ov_o = ov_i;
		 end
    CLR: result_o = 8'h00;				  // clear (output = 0)
 	EMK: result_o = 8'b01111100 & rs_i;	  // exponent mask
    INC: {ov_o, result_o} = rs_i + 9'b1;  // out = A+1
    ADD: {ov_o, result_o} = rs_i + rt_i + ov_i;
	SUB: {ov_o, result_o} = rs_i - rt_i + !ov_i;
    endcase
  end

endmodule 
