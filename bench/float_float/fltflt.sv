// behavioral model for float addition
// CSE141L Fall 2017
// dummy DUT for float+float
module fltflt(
  input        clk, reset,
  output logic done);
  logic       nil1,		    	      // zero detect addend 1
              nil2,		    	      // zero detect addend 2
			  nil3,                   // zero detect sum
              guard,	    	      // needed for subtraction
              round,
              sticky;
  logic[10:0] mant1,                   // mantissa of addend 1
              mant2;				   //  (w/ room for hidden bit)
  logic[11:0] mant3;	      	       // mantissa of sum, incl. overflow
  logic[ 5:0] exp1,			           // exponent of addend 1
              exp2,
              exp3;					   // exponent of sum
  logic       sign1,		           // sign of addend 1
              sign2,
              sign3;	               // sign of sum (or difference)

 logic              CLK;               // wires for all DataMem ports
 logic     [8-1:0]  DataAddress;	   // in your model you would connect these	
 logic              ReadMem;		   //  to other blocks/modules	
 logic              WriteMem;	   		
 logic       [7:0]  DataIn;			
 logic       [7:0]  DataOut;			

  data_mem data_mem1(.*);

  always @(posedge clk) begin	 :main
    if(reset) begin
	  guard  = 1'b0;
	  round  = 1'b0;
	  sticky = 1'b0;
	  sign1  = data_mem1.my_memory[128][7];			 // load operands from data_mem
	  sign2  = data_mem1.my_memory[130][7];
      exp1   = data_mem1.my_memory[128][6:2];
	  exp2   = data_mem1.my_memory[130][6:2];
	  nil1   = !data_mem1.my_memory[128][6:2];	     // zero exp trap
	  nil2   = !data_mem1.my_memory[130][6:2];		 // zero exp trap
	  mant1  = {data_mem1.my_memory[128][1:0],data_mem1.my_memory[129]};
	  mant2   = {data_mem1.my_memory[130][1:0],data_mem1.my_memory[131]};
	  done   = 1'b0;
    end
	else 
  if( !done ) begin	  :nonreset
	  exp3  = exp1;                     // covers equal exponent case; override if exp2>exp1   
	  if(sign1==sign2) begin  :netadd   // perform addition
        sign3 = sign1;				    // won't need guard, but would for subtraction
	    mant1 = {!nil1,mant1[9:0]};	    // prepend hidden bit
		mant2 = {!nil2,mant2[9:0]};
		if(exp1>exp2) begin
		  exp3 = exp1;				    // larger exponent always wins
		  for(int j=0; j<(exp1-exp2); j++) begin
		    sticky = sticky|round;	    // move everything down 1 position
			round  = mant2[0];
		    mant2  = mant2>>1;
		  end
		end
		else if(exp2>exp1) begin             
          exp3 = exp2;
          for(int j=0; j<(exp2-exp1); j++) begin // right-shift mant1 by exp2-exp1
		    sticky = sticky|round;
			round  = mant1[0];
		    mant1  = mant1>>1;
		  end
		end
       	mant3 = mant1 + mant2;
        //$display("mant3 = %b = mant1 + mant2 = %b + %b",mant3,mant1,mant2);
		if(mant3[11]) begin	           // overflow case
		  //$display("overflow engaged");
      exp3++;					   // incr. exp & right-shift mant.
		  sticky = sticky|round;
		  round  = mant3[0];
		  mant3  = mant3>>1;
		end
		if(mant3[0]||sticky)           // rounding
		  mant3 = mant3 + round;
		if(mant3[11]) begin		       // round-induced overflow
		  mant3 = mant3>>1;
		  exp3++;
		end
		nil3=!exp3;
	  end   :netadd

// you may ignore net subtraction, if you wish, and assume that
//  the two operand sign bits are equal
	  else begin  :netsub			   // perform subtraction
        if(exp1>exp2) begin
		  sign3 = sign1;
		  for(int j=0; j<(exp1-exp2); j++) begin
		    sticky = sticky|round;
			round  = guard;
			guard  = mant1[0];
		    mant1  = mant1>>1;
		  end
// subtract mants w/o adding 1 LSB (yet) -- conditional rounding
		  mant3 = mant1 + (~mant2) + !({guard,round,sticky});   // address GRS next
		  if(!mant3[10]) begin	          // need to left-shift to norm.
		    mant3 = {mant3,guard};
			guard = round;
			round = sticky;
		  end
		  if(mant3[0] || sticky || round)
		    mant3 = mant3 + guard;
		end
		else if(exp2>exp1) begin
		  sign3 = sign2;
		  for(int j=0; j<(exp1-exp2); j++) begin
		    sticky = sticky|round;
			round  = guard;
			guard  = mant1[0];
		    mant1  = mant1>>1;
		  end
		  mant3 = mant2 + (~mant1) + !({guard,round,sticky});	 // renorm shrunk mantissa
		  if(!mant3[10]) begin
		    mant3 = {mant3,guard};
			guard = round;
			round = sticky;
		  end
		  if(mant3[0] || sticky|| round)
		    mant3 = mant3 + guard;
		end
		else begin                         // equal exp. case
          exp3 = exp1;                     // provisionally
          if(mant1>mant2) begin
		    mant3 = mant1 + (~mant2) + 1;  // no RS (why?)
			for(int k = 0; k < 9; k++)     // perform normalization
			  if(!mant3[10]) begin
			    mant3 = mant3 << 1'b1;
				exp3--;
			  end
		  end
		  else if(mant2>mant1) begin
		    mant3 = mant2 + (~mant1) + 1;
			for(int k = 0; k < 9; k++)      // perform normalization
			  if(!mant3[10]) begin
			    mant3 = mant3 << 1'b1;
				exp3--;
			  end
		  end
		  else begin				       // zero result (A-A)
		    exp3  = 0;
		    mant3 = 0;
		  end
		end
      end :netsub

// now store results into specified my_memory addresses so that the testbench
//  can read them

      $display("exp3 = %b", exp3);
      if( exp3[5] ) 
      begin
        data_mem1.my_memory[132][7]								=	   sign3; 
        data_mem1.my_memory[132][6:2]							    =	   5'b11111 ; 
        {data_mem1.my_memory[132][1:0],data_mem1.my_memory[133]}  =	   10'b1111111111; 
      end
      else
      begin
        data_mem1.my_memory[132][7]								=	   sign3; 
        data_mem1.my_memory[132][6:2]							    =	   exp3 ; 
        {data_mem1.my_memory[132][1:0],data_mem1.my_memory[133]}  =	   mant3; 
      end
	  done = 1'b1;														     
	end	 :nonreset
  end  :main
endmodule