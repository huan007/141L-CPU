// Create Date:     2017.05.05
// Latest rev date: 2017.10.26
// Created by:      J Eldon
// Design Name:     CSE141L
// Module Name:     ALU (Arithmetic Logical Unit)


//This is the ALU module of the core, op_code_e is defined in definitions.v file
// Includes new enum op_mnemonic to make instructions appear literally on waveform.
`include "definitions.sv"
import definitions::*;

module alu (input  [7:0]       rs_i ,	 // operand s
            input  [7:0]       rt_i	,	 // operand t
            input  [8:0]       op_i	,	 // instruction / opcode
            output logic [7:0] result_o,	 // rslt
			      output logic       carry_o,
            output logic       neg_o,
            output logic       zero_o);

op_code    op3; 	                     // type is op_code, as defined
assign op3 = op_code'(op_i[8:1]);        // map 8 MSBs of op_i to op3 (ALU), cast to enum

always_comb								  // no registers, no clocks
  begin
    result_o  = 'd0;                     // default or NOP result
    carry_o   = 'd0;
    neg_o     = 'd0;
    zero_o    = 'd0;
  case (op3)
    //IMME:
    //BLT:
    //BNE:
  ADD: {carry_o, result_o} = rs_i + rt_i;
  ADDC: {carry_o, result_o} = rs_i + rt_i;
  SUB: {carry_o, result_o} = rs_i - rt_i;
  SUBC: {carry_o, result_o} = rs_i - rt_i;
  LSL: {carry_o, result_o} = rs_i << rt_i;
  LSLC: {carry_o, result_o} = rs_i << rt_i;
  LSR: {result_o, carry_o} = rs_i >> rt_i;
  LSRC: {result_o, carry_o} = rs_i >> rt_i;
  ASR: {result_o, carry_o} = rs_i >>> rt_i;
  NEG: result_o = ~rt_i;
  AND: result_o = rs_i & rt_i;
  OR: result_o = rs_i | rt_i;
  CMP: result_o = rs_i - rt_i;
    //LW:
    //SW:
    //ALW:
    //ASW:
    //HALT: idk what happens
    endcase
  end
endmodule
