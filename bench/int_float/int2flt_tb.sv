// CSE141L  Fall 2017
// testbench for integer to float conversion
// bench computes theoretical result
// bench holds your DUT and my dummy DUT
// (ideally, all three should agree :) )
// keyword bit is same as logic, except it self-initializes
//  to 0 and cannot take on x or z value
module int2flt_tb();
  bit       clk, reset=1'b1;
  wire      done,			 // my dummy done flag
            done2;			 // your DUT's done flag
  bit  [15:0] int_in;	  	 // incoming operand
  bit  [ 3:0] shift;         // for incoming data sizing
  logic[15:0] flt_out2,		 // desired final result
			  flt_out3,
              flt_out_dut;	 // DUT final result
  bit  [15:0] score1,        // your DUT vs. theory 
              score2,		 // your DUT vs. mine
			  count;         // number of trials
  int2flt f2(.*);	         // instantiate dummy DUT
  int2flt f3(				 // your DUT goes here
    .clk  (clk),			 //  rename module & ports
	.reset(reset),			 //  as necessary
    .done (done2));          
  always begin               // clock 
    #5ns clk = 1'b1;			 
	#5ns clk = 1'b0;
  end

  initial begin
    int_in = 16'd0;          
	disp2(int_in);
	int_in = 16'd1;			 // minimum nonzero positive
	disp2(int_in);
	int_in = 16'd2;			 // 
	disp2(int_in);
	int_in = 16'd3;			 // 
	disp2(int_in);
	int_in = 16'd12;		 // 
	disp2(int_in);
	int_in = 16'd48;		 // 
	disp2(int_in);
	int_in = 16'd8191;      // qtr maximum positive
	disp2(int_in);
	int_in = 16'd16383;      // half maximum positive
	disp2(int_in);
	int_in = 16'd32767;      // maximum positive
	disp2(int_in);
	int_in = 16'd30767;      // near maximum positive
	disp2(int_in);
	forever begin
	  shift  = $random;
	  int_in = $random;
	  int_in = int_in>>shift;
	  disp2(int_in);
	  if(count>20) begin
	  	#20ns $display("scores = %d %d out of %d",score1,score2,count); 
        $stop;
	  end
	end
  end

  task automatic disp2(input[15:0] int_in); 			 // device itself
    logic       sgn;
    logic[ 4:0] exp_dut;
    logic[11:0] mant_dut;
    reset = 1'b1;
	f2.data_mem1.my_memory[1][7:0] = int_in[15:8];	 // load operands into memory
	f2.data_mem1.my_memory[2][7:0] = int_in[ 7:0];
	f3.data_mem1.my_memory[1][7:0] = int_in[15:8];	 // load operands into memory
	f3.data_mem1.my_memory[2][7:0] = int_in[ 7:0];
	sgn            = int_in[15]; 
	f2.data_mem1.my_memory[5][7]   = sgn;            // sign bit passes through
	f3.data_mem1.my_memory[5][7]   = sgn;            // sign bit passes through
    flt_out_dut[15]     = sgn;
    flt_out2[15]        = sgn;
    flt_out3[15]        = sgn;
	#20ns reset         = 1'b0;
	#40ns wait(done2)
  	flt_out2[14:0] = {f2.data_mem1.my_memory[5][7:0],f2.data_mem1.my_memory[6][7:0]};	 // read results from memory
    flt_out3[14:0] = {f3.data_mem1.my_memory[5][7:0],f3.data_mem1.my_memory[6][7:0]};	 // same from dummy DUT
    $display("what's feeding the case %b",int_in);
	exp_dut  = 0;		   
	mant_dut = 0;
    casez(int_in[14:0])
	  15'b1??_????_????_????: begin
	    exp_dut  = 29;
	    mant_dut = int_in[14:4];
		if(int_in[4]||(|int_in[2:0])) mant_dut = mant_dut+int_in[3];
        if(mant_dut[11]) begin
		  exp_dut++;
		  mant_dut = mant_dut>>1;
		end
	  end
	  15'b01?_????_????_????: begin
	    exp_dut  = 28;
	    mant_dut = int_in[13:3];
		if(int_in[3]||(|int_in[1:0])) mant_dut = mant_dut+int_in[2];
        if(mant_dut[11]) begin
		  exp_dut++;
		  mant_dut = mant_dut>>1;
		end
	  end
	  15'b001_????_????_????: begin
	    exp_dut  = 27;
	    mant_dut = int_in[12:2];
		if(int_in[2]||(int_in[0]))    mant_dut = mant_dut+int_in[1];
        if(mant_dut[11]) begin
		  exp_dut++;
		  mant_dut = mant_dut>>1;
		end
	  end
	  15'b000_1???_????_????: begin
	    exp_dut  = 26;
		mant_dut = int_in[11:1];
        if(int_in[1])                 mant_dut = mant_dut+int_in[0];
        if(mant_dut[11]) begin
		  exp_dut++;
		  mant_dut = mant_dut>>1;
		end
	  end
	  15'b000_01??_????_????: begin
	    exp_dut  = 25;
		mant_dut = int_in[10:0];
	  end
	  15'b000_001?_????_????: begin
	    exp_dut  = 24;
		mant_dut = {int_in[9:0],1'b0};
      end
	  15'b000_0001_????_????: begin
		exp_dut  = 23;
		mant_dut = {int_in[8:0],2'b0};
      end
	  15'b000_0000_1???_????: begin
		exp_dut  = 22;
		mant_dut = {int_in[7:0],3'b0};
      end
	  15'b000_0000_01??_????: begin
		exp_dut  = 21;
		mant_dut = {int_in[6:0],4'b0};
      end
	  15'b000_0000_001?_????: begin
		exp_dut  = 20;
		mant_dut = {int_in[5:0],5'b0};
      end
	  15'b000_0000_0001_????: begin
		exp_dut  = 19;
		mant_dut = {int_in[4:0],6'b0};
      end
	  15'b000_0000_0000_1???: begin
		exp_dut  = 18;
		mant_dut = {int_in[3:0],7'b0};
      end
	  15'b000_0000_0000_01??: begin
		exp_dut  = 17;
		mant_dut = {int_in[2:0],8'b0};
      end
	  15'b000_0000_0000_001?: begin
		exp_dut  = 16;
		mant_dut = {int_in[1:0],9'b0};
      end
	  15'b000_0000_0000_0001: begin
        exp_dut  = 15;
		mant_dut = 11'b100_0000_0000;
	  end
    endcase
	if(exp_dut==0)  begin			// no hidden; force exp = 0
      $display("flt_out_dut = %d = %f * 2**%d flt_out2=%b %d %b",
        int_in,real'((mant_dut/1024.0)),exp_dut,flt_out2[15],flt_out2[14:10],flt_out2[9:0]);
      $display("flt_out_dut = %b_%b_%b, flt_out3 = %b_%b_%b",
         flt_out2[15],flt_out2[14:10],flt_out2[9:0],flt_out3[15],flt_out3[14:10],flt_out3[9:0]);
      if((exp_dut == flt_out3[14:10])&&(mant_dut==flt_out3[9:0])) score2++;
	  if(flt_out2    == flt_out3) score1++;
    end
    else begin 	  			// normal, non-underflow
      $display("flt_out_dut = %d = %f * 2**%d flt_out2=%b %d %b",
        int_in,real'(mant_dut/1024.0),exp_dut,flt_out2[15],flt_out2[14:10],flt_out2[9:0]);
      $display("flt_out_dut = %b_%b_%b, flt_out3 = %b_%b_%b",
         flt_out2[15],flt_out2[14:10],flt_out2[9:0],flt_out3[15],flt_out3[14:10],flt_out3[9:0]);
      $display("%d = %f * 2**%d flt_out3=%b %d 1.%b",
        int_in,real'(mant_dut/1024.0),exp_dut-15,flt_out3[15],flt_out3[14:10]-15,flt_out3[9:0]);
      $display("flt_out2=%b_%b_%b, flt_out3 = %b_%b_%b",
         flt_out2[15],flt_out2[14:10],flt_out2[9:0],flt_out3[15],flt_out3[14:10],flt_out3[9:0]);
      if((exp_dut[4:0] == flt_out3[14:10])&&(mant_dut[9:0] == flt_out3[9:0])) score2++;
      if(flt_out2 == flt_out3) score1++;
	end
    count++; 
    $display("scores = %d, %d out of %d",score1,score2,count);
	$display();
  endtask
endmodule
