module top_self_bench ();
	bit clk, reset = 1;
	bit halt = 1'b0;	
	wire unsigned [7:0] PCOut;	
	wire unsigned [8:0] nextPC;
	wire done;
	
	assign nextPC = {0,PCOut} + 1;

	//Declare CPU
	top cpu(
		.clk(clk),
		.reset(reset),
		.done(done));

always begin
	#20ns clk = 1;
	#20ns clk = 0;
end

//Initialize
initial begin
	clk = 1'b0;
	#20ns reset = 1'b0;
	#5000ns $stop;
end

endmodule
