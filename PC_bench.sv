module PC_bench ();
	bit clk = 1;
	bit reset = 1;
	bit halt = 1'b0;
	bit branchsig = 0;
	bit branchtype = 0;
	logic [7:0] cmp = 8'h01;
	logic unsigned [7:0] PCOut;
	logic unsigned [7:0] BranchOut;

	IF IF1(
	.branchsig(branchsig),
	.branchtype(branchtype),
	.cmp(cmp),
	.BranchOut(BranchOut),
	.reset(reset),
	.halt(halt),
	.clk(clk),
	.core(PCOut));

always begin
	#5ns clk = 1;
	#5ns clk = 0;
	#5ns clk = 1;
	#5ns clk = 0;
	branchsig = 1;
	branchtype = 1;
	cmp <= 8'h00;
	BranchOut <= 8'h7F;
	#5ns clk = 1;
	#5ns clk = 0;
	branchsig = 0;
	branchtype = 0;
	cmp <= 8'h00;
	BranchOut <= 8'h00;
	#5ns clk = 1;
	#5ns clk = 0;
	#5ns clk = 1;
	branchsig = 1;
	branchtype = 1;
	cmp <= 8'h01;
	BranchOut <= 8'h0F;
	#5ns clk = 0;
	#5ns clk = 1;
	#5ns clk = 0;
	branchsig = 1;
	branchtype = 0;
	cmp <= 8'hFF;
	BranchOut <= 8'h0F;
	#5ns clk = 1;
	#5ns clk = 0;
	#5ns clk = 1;
	#5ns clk = 0;
	#5ns clk = 1;
end

//Initialize
initial begin
	clk = 1'b0;
	#5ns clk = 1;
	#5ns clk = 0;
	#20ns reset = 1'b0;
	#5000ns $stop;
end

endmodule
