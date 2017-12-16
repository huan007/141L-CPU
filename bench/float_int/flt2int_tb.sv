// CSE141L   Fall 2017
// testbench for float to integer
// plug in your own model and test it
// adapt as needed for instance and type names of your modules and 
//  for any initialization you require (can also be done inside your 
//  design itself)
module flt2int_tb();             
  logic       clk   = 1'b0;
  logic       reset = 1'b1;		 // reset = 0 is run
  logic       done_test,		 //
              done;
  logic[15:0] flt;               // incoming floating operand
  logic[15:0] int1_test,		 // converted result
              int1,		         // converted result
			  score1,            // number of trials match to theory
			  score2,            // number of trials match to my hardware
			  count;			 // number of trials
  logic        [14:0] int_out;	 // mag part of result
  logic               flt_sign;	 // input/output sign bit
  logic signed [ 5:0] flt_exp;	 // incoming exponent, debiased
  logic        [10:0] flt_mant;	 // incoming mantissa w/ hidden

  top_test_f2i t1_test(	      // my dummy DUT -- gives right answer
    .clk_i   (clk  ),
	.reset_i (reset),
	.done_o  (done_test));

  top_float2Int t1(            // your DUT could go here
    .clk     (clk  ),		  // retain my dummy, above
	.reset   (reset),
	.done    (done));

  initial begin
    score1 = 16'b0;
	score2 = 16'b0;
	count  = 16'b0;
// emergency stop -- increase value if you need > 2K clocks/test
    #200000ns $display("no done flag!"); 
    $stop;		               // emergency stop if no done	 in 10K clks
  end

  always begin
	#5ns clk = 1'b1;
	#5ns clk = 1'b0;
  end

  initial begin			  // contrived operands
    flt        = {1'b1, 5'h10, 10'b10_0000_0100};
	flt_int_conv;
    flt        = {1'b1, 5'h12, 10'b10_0001_0000};
	flt_int_conv;
	flt        = {1'b1, 5'h14, 10'b10_0000_1111};
	flt_int_conv;
    forever begin		 // loop for random operands
      flt      = $random;	                           // generate new operand	
	  flt_int_conv;
	end
  end
    
  task flt_int_conv;  	       	   	       
    flt_sign = flt[15];			                   // parse into sign, exp, mant
    flt_exp  = flt[14:10]-15;					   // debias exponent
    flt_mant = {|flt[14:10],flt[9:0]};             // restore hidden
// load incoming operands into test DUT and your DUT
    t1_test.data_mem1.my_memory[64] = flt[15:8];    // MSW of incoming flt
	t1_test.data_mem1.my_memory[65] = flt[ 7:0];    // LSW of incoming flt
    t1.data_mem1.my_memory[64]       = flt[15:8];    // MSW of incoming flt
	t1.data_mem1.my_memory[65]       = flt[ 7:0];    // LSW of incoming flt
	#20ns reset = 1'b0;   // release reset
	wait(done);                                     // wait for your done flag
// read results from test DUT and your DUT
	int1_test[15:8] = t1_test.data_mem1.my_memory[66];
	int1_test[ 7:0] = t1_test.data_mem1.my_memory[67]; 
	int1[15:8]      = t1.data_mem1.my_memory[66];
	int1[ 7:0]      = t1.data_mem1.my_memory[67];
//  modify display statements to meet your own needs
//   I have included decimal and binary values, for debug convenience
    $display("input = %b   %b   %b",flt[15],flt[14:10],flt[9:0]);
    if(flt_sign)
      $display("input = -%12.10f * 2**%d",(real'(flt_mant)/1024),flt_exp);
    else
      $display("input = %12.10f * 2**%d",(real'(flt_mant)/1024),flt_exp);
    int_out = int1_test[14:0];			 // mag. part -- sign separate
	if(flt_exp>14) begin
	  if(flt_sign)                       // neg. overflow
	    $display("exp_output = -32767 -- neg. overflow");
	  else
	    $display("exp_output = 32767 -- pos. overflow");
    end	  
	else begin 
	  if(flt_sign)						 // neg. result
        $display("exp_output = -%d  -%b",(real'(flt_mant)/1024)*2**flt_exp,
          ((real'(flt_mant)/1024)*2**flt_exp));    
	  else
        $display("exp_output = %d  %b",(real'(flt_mant)/1024)*2**flt_exp,
          ((real'(flt_mant)/1024)*2**flt_exp)); 
    end       
    if(flt_sign)
      $display("output = -%d -%b",int_out[14:0],int1[14:0]);
    else   
	  $display("output = %d   %b",int_out[14:0],int1[14:0]);
    $display("%d %d",int_out,(real'(flt_mant)/1024)*2**flt_exp);		 
	if(int_out - (real'(flt_mant)/1024)*2**flt_exp < 2)
      score1 ++;
    if(int_out == int1[14:0]) score2++;   
	//else
	//	$stop;
	$display("scores = %d %d",score1,score2);
	$display();	                        // blank line feed for readability
	#20ns reset = 1'b1;
	count ++;
	if(count > 19) begin
	  $display("score1 = %d, score2 = %d, out of %d",score1,score2,count);  
	  $stop;
	end
  endtask

endmodule
