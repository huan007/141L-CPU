// Create Date:     2017.11.05
// Latest rev date: 2017.11.06
// Created by:      J Eldon
// Design Name:     CSE141L
// Module Name:     top (top of sample microprocessor design)

module top_float2Int(
  input clk,
        reset,
  output logic done
);
  parameter IW = 16;				// program counter / instruction pointer
                            // TODO should this be 8
  parameter OW = 10;
  //logic signed[15:0] Offset = 16'd10;
  wire[IW-1:0] PC;                    // pointer to insr. mem
  wire[   8:0] InstOut;				// 9-bit machine code from instr ROM
  wire[   7:0] rt_val_o,			// reg_file data outputs to ALU
               rs_val_o,			//
               result_o;			// ALU data output
  wire[8:0] newPC = PC[7:0];

  //carry, neg, zero
  wire ov_o;
  wire neg_o;
  wire zero_o;

  //cmp register
  logic [7:0] CMP;

  //control_signals
  logic branchsig_i;
  logic branchtype_i;
  logic wen_i;                      // reg file write enable
  logic coutwen_i;
  logic memread_i;
  logic memwrite_i;
  logic Halt;
  logic[1:0] rf_sel;			   // this is regsrc

  wire [7:0] mem_Address_i;		   // 8 bit address
  wire [7:0] DataOut;
  logic[7:0] rf_select;            // data bus

  logic [7:0] ImmeOut;
  logic [7:0] BranchOut;

  //Decoder's wires
  logic [OW-1:0] 	control_signals;
  logic special_reg;
  logic temp_mem;


//COMPONENT: PC
IF IF1(
  .branchsig (branchsig_i),
  .branchtype (branchtype_i),
  .BranchOut (BranchOut),
  .cmp       (CMP),
  .reset    (reset   ),
  .halt     (Halt    ),
  .clk      (clk     ),
  .core       (PC[7:0] )
  );

//COMPONENT: INSTRUCTION MEMORY
//TODO: PC is only 8 bits but InstROM takes 9 bit instruction pointer?

//InstROM (here by default)
InstROM_float2Int InstROM1(
  .InstAddress (PC[7:0]),	// address pointer
  .InstOut (InstOut));

decoder decoder1 (
	.instruction (InstOut[8:1]),
	.control_signals (control_signals),
	.special_reg   (special_reg),		//MSB of rt
	.temp_mem      (temp_mem));			//Control signal for mux before MEM

//branchLUT
branchLUT branchLUT1 (
  .InstAddress    (InstOut[5:0]),
  .BranchOut      (BranchOut)
);

//immeLUT
immeLUT immeLUT1 (
  .InstAddress    (InstOut[6:2]),
  .ImmeOut      (ImmeOut)
);

reg_file rf1	 (
  .clk		     (clk		    ),   // clock (for writes only)
  .rs	 (InstOut[1:0]  ),   // read pointer rs (2 bits)
  .rt	 ({special_reg, InstOut[3:2]}  ),   // read pointer rt (3 bits)
  .write_enable		 (wen_i		    ),   // write enable
  .cout_write_enable		 (coutwen_i		    ),   // cout write enable
  .write_data	 (rf_select     ),   // data to be written/loaded
  .cout_data	 ({7'b0,ov_o}),   // cout to be written/loaded
  .rs_val_o	     (rs_val_o	    ),   // data read out of reg file
  .rt_val_o		 (rt_val_o	    ));

//rf_sel is regsrc; created mux.
Mux_4_To_1 Reg_src_mux(
	.i_Select(rf_sel),
	.i_Data1(result_o),
	.i_Data2(ImmeOut),
	.i_Data3(DataOut),
	.i_Data4(8'h00),
	.o_Data(rf_select));

alu alu1(.rs_i     (rs_val_o)   ,
         .rt_i	   (rt_val_o)	  ,
         .op_i	   (InstOut)	  ,
// outputs
         .result_o (result_o	) ,
         .cmp      (CMP       ) ,
         .carry_o  (ov_o    	) ,
         .neg_o    (neg_o    	) ,
         .zero_o   (zero_o    	));

//Add a mux before memAddress to support ALW and ASW
Mux_2_To_1 mem_Address_mux (
	.i_Select(temp_mem),
	.i_Data1(8'h80),			//tempMemLocation = 128
	.i_Data2(rt_val_o),
	.o_Data(mem_Address_i));
// check but looks like it will work as is
data_mem data_mem1(
   .CLK           (clk        ),
   .DataAddress   (mem_Address_i),
   .ReadMem       (memread_i       ), // mem read always on
   .WriteMem      (memwrite_i   ), // 1: mem_store
   .DataIn        (rs_val_o   ), // store (from RF)
   .DataOut       (DataOut    )  // load  (to RF)
);

logic[14:0] dummy;
//case ()
assign             branchsig_i = control_signals[9];
assign             branchtype_i = control_signals[8];
assign             wen_i = control_signals[7];
assign             coutwen_i = control_signals[6];
//TODO isn't reset an input
//assign             reset = control_signals[5];
assign             Halt = control_signals[4];
assign             memread_i = control_signals[3];
assign             memwrite_i = control_signals[2];
assign             rf_sel = control_signals[1:0];
//Set done signal equals to Halt signal
assign done = Halt & ~reset;

//Initialize regFile
initial begin
//	rf1.RF[0] = 8'h00;
//	rf1.RF[1] = 8'h00;
//	rf1.RF[2] = 8'h00;
//	rf1.RF[3] = 8'h00;
//	rf1.RF[4] = 8'h00;
//	rf1.RF[5] = 8'h00;
//	rf1.RF[6] = 8'h00;
//	rf1.RF[7] = 8'h00;
end

endmodule
