// Create Date:     2017.11.05
// Latest rev date: 2017.11.06
// Created by:      J Eldon
// Design Name:     CSE141L
// Module Name:     top (top of sample microprocessor design)

module top(
  input clk,
        reset,
  output logic done
);
  parameter IW = 16;				// program counter / instruction pointer
                            // TODO should this be 8
  parameter OW = 10;
  //logic              Abs_Jump,// = 1'b0, // branch to "offset"
  //                   Rel_Jump;		// branch by "offset"
  logic signed[15:0] Offset = 16'd10;
  wire[IW-1:0] PC;                    // pointer to insr. mem
  wire[   8:0] InstOut;				// 9-bit machine code from instr ROM
  wire[   7:0] rt_val_o,			// reg_file data outputs to ALU
               rs_val_o,			//
               result_o;			// ALU data output

  wire ov_o;   // I'm guessing this is carry
  wire neg_o;
  wire zero_o;

  //wire alu_z_o;

  //control_signals
  logic branchsig_i;
  logic branchtype_i;
  logic wen_i;                      // reg file write enable
  logic coutwen_i;
  logic memread_i;
  logic memwrite_i;
  logic Halt;
  logic[1:0] rf_sel;			   // this is regsrc


  //logic carry_en = 1'b1;            //TODO I don't know what these do
  //logic carry_clr;
  //assign carry_clr = reset;
  //logic ov_i; we don't have carry_in should be not needed
  //logic[7:0] alu_mux; not needed

  wire [7:0] DataOut;
  logic[7:0] rf_select;            // data bus
  logic[7:0] DataAddress;

  //TODO, need wires ? or logic ? for IMMEout, BranchOut
  wire [7:0] ImmeOut;
  wire [7:0] BranchOut;

  logic [OW-1:0] 	control_signals;
  logic special_reg;
	logic temp_mem;

IF IF1(
  //.Abs_Jump (Abs_Jump)  ,   // branch to "offset"
  //.Rel_Jump (Rel_Jump)	 ,	// branch by "offset"
  //.Offset   (Offset  )	 ,
  .reset    (reset   )	 ,
  .halt     (Halt    )	 ,     //TODO this was 1b'0, should it be Halt
  .clk      (clk     ),
  .newAddress (PC      ),      // pointer to insr. mem
                                // TODO PC input (newAddress) in our
                                // implementation looks like its 16 bits
                                // instead of 8; see above need some help here
  .core       (core )
  );

//InstROM (here by default)
//TODO check .IW(16)
InstROM #(.IW(16)) InstROM1(
  .InstAddress (PC),	// address pointer
  .InstOut (InstOut));

//Decoder TODO check .IW(16)
decoder #(.IW(16)) (
	.instruction (InstOut)),
	.control_signals (control_signals),
	.special_reg   (special_reg),
	.temp_mem      (temp_mem));

//immeLUT TODO problem the module signatures are the same as InstROM1

//branchLUT TODO problem the module signatures are the same as InstROM1

//TODO do we need .raw(3)
reg_file #(.raw(3)) rf1	 (
  .clk		     (clk		    ),   // clock (for writes only)
  .rs_addr_i	 (InstOut[2:0]  ),   // read pointer rs
  .rt_addr_i	 (InstOut[5:3]  ),   // read pointer rt
  .wen_i		 (wen_i		    ),   // write enable
  .coutwen_i		 (coutwen_i		    ),   // cout write enable
  .write_data_i	 (rf_select     ),   // data to be written/loaded
  .cout_data_i	 (ov_o),   // cout to be written/loaded
  .rs_val_o	     (rs_val_o	    ),   // data read out of reg file
  .rt_val_o		 (rt_val_o	    )
                );

//TODO rf_sel is regsrc; created mux.
case(rf_sel):
  2'b00: rf_select = result_o;
  2'b01: rf_select = ImmeOut;
  2'b10: rf_select = DataOut;
  2'b11: rf_select = 2h'00; //no write
endcase


//assign rf_select = rf_sel? DataOut : result_o;	// supports load commands
//replaced with mux above

alu alu1(.rs_i     (alu_mux)     , //TODO no mux needed before alu
         .rt_i	   (rt_val_o)	  ,
         .op_i	   (InstOut)	  ,
// outputs
         .result_o (result_o) ,
		 .carry_o     (ov_o    ) ,
     .neg_o     (neg_o    ) ,
     .zero_o     (zero_o    ));

//TODO check but looks like it will work as is
data_mem dm1(
   .CLK           (clk        ),
   .DataAddress   (DataAddress),
   .ReadMem       (1'b1       ), // mem read always on
   .WriteMem      (WriteMem   ), // 1: mem_store
   .DataIn        (rs_val_o   ), // store (from RF)
   .DataOut       (DataOut    )  // load  (to RF)
);

logic[14:0] dummy;
case ()
//TODO I'm assigning the control signals here
//TODO I don't think the ones in comment are needed (here by default)
//assign             Rel_Jump = &(InstOut[8:3]);//&&ov_o;
//assign             Abs_Jump = &(InstOut[8:0])&&alu_z_o;
//assign             alu_mux = InstOut[8:6]==5? 8'b0 : rs_val_o;

assign             branchsig_i = control_signals[9];
assign             branchtype_i = control_signals[8];
assign             wen_i = control_signals[7];
assign             coutwen_i = control_signals[6];
//TODO isn't reset an input
assign             Halt = control_signals[4];
assign             memread_i = control_signals[3];
assign             memwrite_i = control_signals[2];
assign             rf_sel = control_signals[1:0];

// lookup table for driving wen_i;
//lut lut1(
//  .lut_addr(InstOut[8:6]),
//  .lut_val(wen_i)//({dummy,wen_i})
//);

//TODO idk what this does exactly or if needed
always_ff @(posedge clk)   // one-bit carry/shift
  if(carry_clr==1'b1)
    ov_i <= 1'b0;
  else if(carry_en==1'b1)
    ov_i <= ov_o;

endmodule
