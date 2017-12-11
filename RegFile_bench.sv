module RegFile_bench ();
	bit clk = 1;
	bit write_enable = 0;
	bit cout_write_enable = 0;
	logic [1:0] rs = 01; 
	logic [2:0] rt = 000;
	logic [7:0] write_data;
	logic [7:0] cout_data;
	wire [7:0] rs_out;
	wire [7:0] rt_out;

	assign lower_rt = rt[2:0] + 1;

always_ff @ (posedge clk) begin
	write_data <= write_data + 1;
	rs <= rs + 1;
	rt <= {0, lower_rt};
	cout_data <= cout_data + 1;
end

reg_file reg1 (
	.clk(clk),
	.rs(rs),
	.rt(rt),
	.write_enable(write_enable),
	.cout_write_enable(cout_write_enable),
	.write_data(write_data),
	.cout_data(cout_data),
	.rs_val_o(rs_out),
	.rt_val_o(rt_out));

always begin
	#5ns clk = 1;
	#5ns clk = 0;
end

//Initialize
initial begin
	reg1.RF[0] = 8'h00;
	reg1.RF[1] = 8'h00;
	reg1.RF[2] = 8'h00;
	reg1.RF[3] = 8'h00;
	reg1.RF[4] = 8'h00;
	reg1.RF[5] = 8'h00;
	reg1.RF[6] = 8'h00;
	reg1.RF[7] = 8'h00;
	
	#15ns;
	write_enable = 1;
	cout_write_enable = 0;
	rs = 01; 
	rt = 000;
	write_data = 0;
	cout_data = 0;

	#100ns cout_data = 0;
	cout_write_enable = 1;

	#10000ns $stop;
	
end
endmodule
