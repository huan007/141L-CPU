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
            output logic [7:0] cmp,
			      output logic       carry_o,
            output logic       neg_o,
            output logic       zero_o);

op_code    op3; 	                     // type is op_code, as defined
assign op3 = op_code'(op_i[8:1]);        // map 8 MSBs of op_i to op3 (ALU), cast to enum
logic [1:0] rt;
assign rt = op_i[3:2];
//localparam C = 3;

always_comb								  // no registers, no clocks
  begin
    result_o  = 'd0;                     // default or NOP result
    carry_o   = 'd0;
    neg_o     = 'd0;
    zero_o    = 'd0;
  casex (op3)
    //IMME: Does nothing ?
    //BLT: Does nothing ?
    //BNE: Does nothing ?
  		ADD: begin
  		      {carry_o, result_o} = $signed({0,rs_i}) + $signed({0, rt_i});
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		ADDC: begin
  		      {carry_o, result_o} = $signed({0,rs_i}) + $signed({0,rt_i});
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		SUB: begin
  		      {carry_o, result_o} = $signed({rs_i[7], rs_i}) - $signed({rt_i[7], rt_i});
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		SUBC: begin
  		      {carry_o, result_o} = $signed({rs_i[7],rs_i}) - $signed({rt_i[7], rt_i});
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		LSL: begin
  		      {carry_o, result_o} = {0,rs_i} << rt_i;
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		LSLC: begin
  		      if (rt == 2'b11) {carry_o, result_o} = (rs_i << 1) | rt_i;
  		      else {carry_o, result_o} = {0,rs_i} << rt_i;
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		LSR: begin
  		      result_o = rs_i >> rt_i;
  		      carry_o = (rs_i & ('h01  << (rt_i - 1))) >> (rt_i - 1);
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		LSRC: begin
			if (rt == 2'b11) begin
				result_o = (rs_i >> 1) | (rt_i << 7);
				carry_o = rs_i & 8'b01;
			end
			else begin 
				result_o = rs_i >> rt_i;
  		      	carry_o = (rs_i & ('h01  << (rt_i - 1))) >> (rt_i - 1);
			end
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		ASR: begin
  		      result_o = rs_i >>> rt_i;
  		      carry_o = (rs_i & ('h01  << (rt_i - 1))) >> (rt_i - 1);
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		NEG: begin
  		      result_o = ~rt_i;
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		AND: begin
  		      result_o = rs_i & rt_i;
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		OR: begin
  		      result_o = rs_i | rt_i;
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		CMP: begin
  		      cmp = $signed(rs_i) - $signed(rt_i);
  		      zero_o = result_o || 'd0;
  		      neg_o = result_o[7];
  		      end
  		  //LW: Does nothing ?
  		  //SW: Does nothing ?
  		  //ALW: Does nothing ?
  		  //ASW: Does nothing ?
  		  //HALT: idk what happens
    endcase
  end
endmodule
