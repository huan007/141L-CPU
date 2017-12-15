//Program Counter (Fetch)
module IF (
	input branchsig,
	input branchtype,
	input signed [7:0] cmp,
	input [7:0] BranchOut,
	input reset,
	input halt,
	input clk,
	output logic[7:0] core);

	initial 
		core = 8'b0;

	always_ff @ (posedge clk) begin
		if(reset) begin
			core <= 0;
			end
		else if (halt) begin
			core <= core;
			end
		else if (branchsig==1'b1) begin //if branch instruction
			if(branchtype==1'b0) begin
				if($signed(cmp)<$signed(8'h00)) begin
					core <= core + BranchOut;
					end
				else begin
					core <= core + 1; //blt
					end
				end
			else begin
				if(cmp!=8'h00) begin
					core <= core + BranchOut;
					end
				else begin
					core <= core + 1; //bne
					end
				end
			end
		else begin
			core <= core + 1; //normal advance
			end
	end
endmodule
