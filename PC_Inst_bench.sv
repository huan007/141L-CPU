module PC_Inst_bench ();
	bit clk, reset = 1;
	bit halt = 1'b0;	
	wire unsigned [7:0] PCOut;	
	wire unsigned [8:0] nextPC;
	wire [8:0] romIn = {0, PCOut};
	wire [8:0] romOut;
	
	assign nextPC = {0,PCOut} + 1;

	IF IF1(
	.reset(reset),
	.halt(halt),
	.clk(clk),
	.newAddress(nextPC[7:0]),
	.core(PCOut));

	InstROM rom1(
		.InstAddress(romIn),
		.InstOut(romOut));

always begin
	#10ns clk = 1;
	#10ns clk = 0;
end

//Initialize
initial begin
	clk = 1'b0;
	#20ns reset = 1'b0;
	#5000ns $stop;
end


endmodule
