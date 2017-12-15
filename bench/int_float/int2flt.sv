// behavioral model for integer to float conversion
// CSE141L Fall 2017
// dummy DUT for int_to_float
module int2flt(
  input        clk, reset,
  output logic done);
  logic        nil;
  logic[ 7:0]  ctr;
  logic[ 5:0]  exp;
  logic[15:0]  int_int;
  logic        sign;

// port connections to dummy data_mem
  bit            CLK;             
  bit   [8-1:0]  DataAddress;		
  bit            ReadMem;			
  bit            WriteMem;			
  bit     [7:0]  DataIn;			
  wire    [7:0]  DataOut;			
  data_mem data_mem1(.*);					  // dummy data_memory for compatibility

  always @(posedge clk) begin
    if(reset) begin
	  nil     = !{data_mem1.my_memory[1][6:0],data_mem1.my_memory[2][7:0]};		 // zero trap
	  sign    = data_mem1.my_memory[1][7];
	  int_int = {data_mem1.my_memory[1][6:0],data_mem1.my_memory[2][7:0]};
	  exp     = 6'd29;						  // biased exponent
	  done    = 1'b0;
    end
	else if(!done) begin	   :nonreset
      if(nil) {data_mem1.my_memory[5],data_mem1.my_memory[6]} = {sign,15'b0};
      else begin 
// normalization
        for(int ct=29;ct>13;ct--) begin
          if(int_int[14]==1'b0) begin      // priority coder
            int_int = int_int<<1'b1;			  // looks for position of leading one
	        exp--;				              // decrement exponent every time we double mant.
	      end
		  else break; 
		end
		$display("preround exp = %d",exp);
// rounding
        if(int_int[4]||int_int[2:0]) begin
//          $display("I get a round %b",int_int);
          int_int = int_int+{int_int[3],3'b0}; 
//          $display("%b",int_int);
		end
        if(int_int[15]) begin				  // round induced overflow
	      $display("renorm hit, exp = %d",exp);
	      int_int[15:4] = int_int[15:4]>>1;
		  exp++;
        end   
		$display("postround exp = %d",exp);  
        {data_mem1.my_memory[5],data_mem1.my_memory[6]} = {sign,exp,int_int[13:4]};
      end
	  done = 1;
    end	 :nonreset
  end

endmodule