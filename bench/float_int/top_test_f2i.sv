// dummy model of float to integer processor
// CSE141L  Fall 2017
// you would substitute your actual design here
module top_test_f2i(
  input        clk_i,		 	// _i, _o are optional
  input        reset_i,
  output logic done_o);

  logic[15:0] flt,              // incoming data
              int1;             // converted data
  logic[ 4:0] exp;				// extracted exponent
  logic[ 9:0] mant;				// extracted mantissa
  wire [ 7:0] DataOut;          // data_mem output for load operations
// data_mem1 -- mine is just a dummy to let the test bench 
//   load operands and read results
  data_mem data_mem1(.CLK        (clk_i),	 // your DUT will need this connection
                     .DataAddress(8'b0),		 // you DUT will need to drive this
                     .ReadMem    (1'b1),		 // you may be able to read continuously
                     .WriteMem   (1'b0),        // your DUT will need this = 1 during store ops
                     .DataIn     (8'b0),		 // your DUT will need to drive this for store ops
                     .DataOut    (DataOut)); // your DUT will need to connect this for load ops     

always @(posedge clk_i) begin
  if(reset_i) begin				// during reset, read the incoming operand  {} = concat. operator
    flt = {data_mem1.my_memory[64],data_mem1.my_memory[65]};
	done_o = 1'b0;				// clear done flag -- will set at end of program
  end
  else begin
    int1[15] = flt[15];		    // sign bit carries across
	exp      = flt[14:10];
	mant     = flt[ 9: 0];
// depending on the exponent value, do the following:
// 1. prepend the mantissa with the hidden bit (1 if biased exponent != 0)
// 2. limit the two overflow cases (exp>29) to max. magnitude integer (sign, followed by all 1s)
// 3. shift mantissa and hidden bit left for exponents >25
// 4. bring mantissa and hidden bit straight out for exponent = 25
// 5. shift mantissa and hidden bit right for exponents <25 -- round to nearest even
// 6. if biased exponent <14, flush result to 0 (underflow)
    case(exp)							                     // not elegant or compact, but accurate
	  30,31:          int1[14:0] = 15'h7fff;                 // saturate on overflow
	  29,28,27,26,25: int1[14:0] = ({5'b1,mant})<<(exp-25);	 // no rounding
	  24: begin
	    int1[14:0] = {6'b1,mant[9:1]};
		if(mant[1]) int1 = int1 + mant[0];                   // round up on odd
	  end
	  23: begin
	    int1[14:0] = {7'b1,mant[9:2]};
		if(mant[2]||mant[0]) int1 = int1 + mant[1];
	  end
	  22: begin
	    int1[14:0] = {8'b1,mant[9:3]};
		if(mant[3] || (|mant[1:0])) int1 = int1 + mant[2]; 
	  end
	  21: begin
	    int1[14:0] = {9'b1,mant[9:4]};
		if(mant[4] || (|mant[2:0])) int1 = int1 + mant[3];
	  end
	  20: begin
	    int1[14:0] = {10'b1,mant[9:5]};
		if(mant[5] || (|mant[3:0])) int1 = int1 + mant[4];
	  end
	  19: begin
	    int1[14:0] = {11'b1,mant[9:6]};
		if(mant[6] || (|mant[4:0])) int1 = int1 + mant[5];
      end
	  18: begin
	    int1[14:0] = {12'b1,mant[9:7]};
		if(mant[7] || (|mant[5:0])) int1 = int1 + mant[6];
      end
	  17: begin
	    int1[14:0] = {13'b1,mant[9:8]};
		if(mant[8] || (|mant[6:0])) int1 = int1 + mant[7];
      end
	  16: begin
	    int1[14:0] = {14'b1,mant[9]};
		if(mant[9] || (|mant[7:0])) int1 = int1 + mant[8];
      end
	  15: int1[14:0] = 15'b1 + mant[9];
	  14: begin
	    int1[14:0] = 15'b0;
		if(|mant[9:0]) int1 = 15'b1;
      end
	  default:        int1[14:0] = 15'h0;	   // underflow to signed zero
    endcase
	{data_mem1.my_memory[66],data_mem1.my_memory[67]} = int1;
	#20ns done_o = 1'b1;
  end  
end
endmodule