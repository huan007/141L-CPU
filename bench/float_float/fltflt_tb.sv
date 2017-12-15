// CSE141L   Fall 2017
// testbench for float addition
// plug in your own model and test it
// adapt as needed for instance and type names of your modules and 
//  for any initialization you require (can also be done inside your 
//  design itself)
module fltflt_tb();             
  bit         clk         ;		 // same as type logic, but self-inits to 0
  logic       reset = 1'b1;		 // reset = 0 is run
  logic       done_test,		 //	done flag from my dummy
              done;				 // done flag from your DUT
  logic[15:0] flt1,
              flt2;              // incoming floating operand
  logic[15:0] flt3_test,		 // sum/difference out
              flt3, 	         // sum/difference out
			  score1,            // number of trials match to theory
			  score2,            // number of trials match to my hardware
			  count;			 // number of trials
  int         cycle_ct;          // clock cycle count
  logic               flt_sign,	 // input/output sign bit
                      flt1_sign,
					  flt2_sign,
					  flt3_sign, // your DUT's output sign bit
					  flt3_test_sign; // my output sign bit
  logic signed [ 5:0] flt1_exp,	 // incoming exponent, debiased
                      flt2_exp,
                      flt3_exp,  // your DUT's output exponent
                      flt3_test_exp;
  logic        [10:0] flt1_mant,  // incoming mantissa w/ hidden
					  flt2_mant,
					  flt3_mant,  // your DUT's output mant.
					  flt3_test_mant;
  real                flt1_real,  // type "real" supported in test benches only
                      flt2_real,
                      flt3_real;

  fltflt t1_test(	              // my dummy DUT -- gives right answer
    .clk   (clk  ),
	.reset (reset),
	.done  (done_test));

  fltflt t1     (                 // your DUT would go here
    .clk     (clk  ),		      // retain my dummy, above
	.reset   (reset),			  // rename ports and module fltflt
	.done    (done));			  //  to those in your design

  initial begin
    score1 = 16'b0;
	score2 = 16'b0;
	count  = 16'b0;			  
// emergency stop -- increase value if you need > 2K clocks/test
    #250000ns $display("no done flag!"); 
    $stop;		                  // emergency stop if no done in 10K clks
  end

  always begin
	#5ns clk = 1'b1;
	#5ns clk = 1'b0;
	if(reset)
	  cycle_ct = 0;		          // number of clock cycles from reset release to done    
	else
	  cycle_ct++;
  end

  initial begin			          // contrived operands
    flt1        = {1'b0, 5'h06, 10'b10_0000_0100};
    flt2        = {1'b0, 5'h06, 10'b10_0000_0100};
	fltadd;						  // task runs program & computes theoretical answer
    flt1        = {1'b0, 5'h10, 10'b10_0000_0100};
    flt2        = {1'b0, 5'h10, 10'b10_0000_0100};
	fltadd;
    flt1        = {1'b0, 5'h12, 10'b10_0001_0000};
    flt2        = {1'b0, 5'h10, 10'b10_0000_0100};
	fltadd;
	flt1        = {1'b0, 5'h14, 10'b10_0000_1111};
    flt2        = {1'b0, 5'h10, 10'b10_0000_0100};
	fltadd;
    forever begin		          // loop for random operands
      flt1[14:0] = $random;	      // generate new operand	
	  flt2[14:0] = $random;		  // forever = always inside an initial 
	  fltadd;
	end
  end
    
  task fltadd;  	       	   	       
    flt1_sign = flt1[15];			                    // parse into sign, exp, mant
    flt1_exp  = flt1[14:10]-15;					        // debias exponent
    flt1_mant = {|flt1[14:10],flt1[9:0]};               // restore hidden
    flt2_sign = flt2[15];			                    // parse into sign, exp, mant
    flt2_exp  = flt2[14:10]-15;					        // debias exponent
    flt2_mant = {|flt2[14:10],flt2[9:0]};               // restore hidden
// load incoming operands into test DUT and your DUT
    t1_test.data_mem1.my_memory[128] = flt1[15:8];      // MSW of incoming flt
	t1_test.data_mem1.my_memory[129] = flt1[ 7:0];      // LSW of incoming flt
    t1_test.data_mem1.my_memory[130] = flt2[15:8];      // MSW of incoming flt
	t1_test.data_mem1.my_memory[131] = flt2[ 7:0];      // LSW of incoming flt
    t1.data_mem1.my_memory[128] = flt1[15:8];           // MSW of incoming flt
	t1.data_mem1.my_memory[129] = flt1[ 7:0];           // LSW of incoming flt
    t1.data_mem1.my_memory[130] = flt2[15:8];           // MSW of incoming flt
	t1.data_mem1.my_memory[131] = flt2[ 7:0];           // LSW of incoming flt
	#20ns reset = 1'b0;   // release reset
	wait(done);                                         // wait for your done flag
// read results from test DUT and your DUT
	flt3_test[15:8] = t1_test.data_mem1.my_memory[132];	// my result upper bits
	flt3_test[ 7:0] = t1_test.data_mem1.my_memory[133]; 
	flt3[15:8]      = t1.data_mem1.my_memory[132];		// your result upper bits
	flt3[ 7:0]      = t1.data_mem1.my_memory[133];
    flt3_exp        = flt3[14:10]-15;			        // your debiased exponent
	flt3_mant       = {|flt3[14:10],flt3[9:0]};		    // your mantissa w/ hidden bit
    flt3_test_exp   = flt3_test[14:10]-15;
	flt3_test_mant  = {|flt3_test[14:10],flt3_test[9:0]};
//  modify display statements to meet your own needs
//   I have included decimal and binary values, for debug convenience
    $display("flt1b = %b  %b  %b",flt1[15],flt1[14:10],flt1[9:0]);
    $display("flt2b = %b  %b  %b",flt1[15],flt2[14:10],flt2[9:0]);
    $display("flt1d = %18.10f * 2**%d",real'(flt1_mant)/1024.0,flt1_exp);
    $display("flt2d = %18.10f * 2**%d",real'(flt2_mant)/1024.0,flt2_exp);
    flt1_real = (real'(flt1_mant/1024.0)) * real'(2.0**(flt1_exp));
    flt2_real = (real'(flt2_mant/1024.0)) * real'(2.0**(flt2_exp));
	$display("flt1r = %18.10f",flt1_real);
	$display("flt2r = %18.10f",flt2_real);
    if(flt1_sign == flt2_sign)
      flt3_real = flt1_real + flt2_real;
    else
      flt3_real = flt1_real - flt2_real;   
// output from first DUT 
    $display("flt3b =  %b  %b  %b",flt3[15],flt3[14:10],flt3[9:0]);				 
    $display("flt3d = %18.10f * 2**%d",real'(flt3_mant)/1024.0,flt3_exp);
    $display("flt3r = %18.10f",(real'(flt3_mant/1024.0))*real'(2.0**flt3_exp));
// output from second DUT
    $display("flt3_testb =  %b   %b",flt3_test[14:10],flt3_test[9:0]);				 
    $display("flt3_testd = %18.10f * 2**%d",real'(flt3_test_mant)/1024.0,flt3_test_exp);
    $display("flt3_testr = %18.10f",(real'(flt3_test_mant/1024.0))*real'(2.0**flt3_test_exp));
// "theoretical" result
    $display("flt3_real = %18.10f",flt3_real);
	$display("flt3_for_diff = %18.10f",(real'(flt3_mant)/1024.0)*real'(2.0**flt3_exp));
	$display("diff = %18.10f",flt3_real - (real'(flt3_mant)/1024.0)*real'(2.0**flt3_exp));
    $display("flt3_real/100.0 = %18.10f",flt3_real/100.0);
	if((flt3_real == (real'(flt3_mant)/1024.0)*real'(2.0**flt3_exp)) || (flt3_real - (real'(flt3_mant)/1024.0)*2**flt3_exp < flt3_real/100.0 &&
	   flt3_real - (real'(flt3_mant)/1024.0)*2**flt3_exp > -flt3_real/100.0))
      score1 ++;
    if(flt3==flt3_test)					      // your DUT matches my dummy DUT
	  score2 ++;           
//    if(int_out == int1[14:0]) score2++;   
	count ++;
	$display("scores = %d, %d out of %d",score1,score2,count);
    $display("clock cycle ct = %d",cycle_ct);  
	#20ns reset = 1'b1;
	$display();	                              // blank line feed for readability
	if(count > 24) begin
	  $display("score1 = %d, score2 = %d, out of %d",score1,score2,count);
	  $stop;
	end
  endtask

endmodule