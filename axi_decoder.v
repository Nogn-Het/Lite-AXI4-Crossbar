module axi_decoder (
// Decides if the address is getting sent to S1 or S2

	//Inputs
	input wire [31:0] addr,
	//Outputs
	output reg sel_s0,
	output reg sel_s1,
	output reg decerr
);

always @(*) begin
	sel_s0 = 1'b0;
	sel_s1 = 1'b0;
	decerr = 1'b0;
	
	if (addr[31:16] == 16'h0000) begin
		sel_s0 <= 1'b1;
	end else if (addr[31:16] == 16'h1000) begin
		sel_s1 <= 1'b1;
	end else begin
		decerr <= 1'b1;
	end
end
endmodule

