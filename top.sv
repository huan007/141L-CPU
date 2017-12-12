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
  logic              Abs_Jump,// = 1'b0, // branch to "offset"
                     Rel_Jump;		// branch by "offset"
  logic signed[15:0] Offset = 16'd10;
  logic Halt;
  wire[IW-1:0] PC;                    // pointer to insr. mem
  wire[   8:0] InstOut;				// 9-bit machine code from instr ROM
  wire[   7:0] rt_val_o,			// reg_file data outputs to ALU
               rs_val_o,			// 
               result_o;			// ALU data output
  wire ov_o;
  wire alu_z_o;
  logic wen_i;                      // reg file write enable
  logic carry_en = 1'b1;
  logic carry_clr;
  assign carry_clr = reset;
  logic ov_i;
  logic[7:0] alu_mux;
  wire [7:0] DataOut;
  logic      rf_sel;			   // conrol
  logic[7:0] rf_select;            // data bus
  logic[7:0] DataAddress;

IF IF1(
  .Abs_Jump (Abs_Jump)  ,   // branch to "offset"
  .Rel_Jump (Rel_Jump)	 ,	// branch by "offset"
  .Offset   (Offset  )	 ,
  .Reset    (reset   )	 ,
  .Halt     (1'b0    )	 ,
  .CLK      (clk     )	 ,
  .PC       (PC      )      // pointer to insr. mem
  );				 

InstROM #(.IW(16)) InstROM1(
  .InstAddress (PC),	// address pointer
  .InstOut (InstOut));

reg_file #(.raw(3)) rf1	 (
  .clk		     (clk		    ),   // clock (for writes only)
  .rs_addr_i	 (InstOut[2:0]  ),   // read pointer rs
  .rt_addr_i	 (InstOut[5:3]  ),   // read pointer rt
  .write_addr_i  (InstOut[2:0]  ),   // write pointer (rd)
  .wen_i		 (wen_i		    ),   // write enable
  .write_data_i	 (rf_select     ),   // data to be written/loaded 
  .rs_val_o	     (rs_val_o	    ),   // data read out of reg file
  .rt_val_o		 (rt_val_o	    )
                );

assign rf_select = rf_sel? DataOut : result_o;	// supports load commands

alu alu1(.rs_i     (alu_mux)     ,	
         .rt_i	   (rt_val_o)	  ,	
    	 .ov_i     (ov_i)     ,	
         .op_i	   (InstOut)	  ,	
// outputs
         .result_o (result_o) ,
		 .ov_o     (ov_o    ) ,
		 .alu_z_o  (alu_z_o ));

data_mem dm1(
   .CLK           (clk        ),        
   .DataAddress   (DataAddress),
   .ReadMem       (1'b1       ), // mem read always on		
   .WriteMem      (WriteMem   ), // 1: mem_store		
   .DataIn        (rs_val_o   ), // store (from RF)		
   .DataOut       (DataOut    )  // load  (to RF)
);

logic[14:0] dummy;
assign             Rel_Jump = &(InstOut[8:3]);//&&ov_o;
assign             Abs_Jump = &(InstOut[8:0])&&alu_z_o;
assign             done = InstOut==9'b0_0001_0001;
assign             alu_mux = InstOut[8:6]==5? 8'b0 : rs_val_o;
//assign             wen_i = InstOut == 9'b1_0001_1110;
// lookup table for driving wen_i;
lut lut1(
  .lut_addr(InstOut[8:6]),
  .lut_val(wen_i)//({dummy,wen_i})
);


always_ff @(posedge clk)   // one-bit carry/shift
  if(carry_clr==1'b1)
    ov_i <= 1'b0;
  else if(carry_en==1'b1)
    ov_i <= ov_o;

endmodule