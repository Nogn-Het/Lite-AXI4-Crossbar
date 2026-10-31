module axi_arbiter(
	// Inputs
	input wire clk,
	input wire reset_n,
	input wire [1:0] req, // Which Master is requesting to send Info
	input wire transaction_done,
	
	//Outputs
	output reg [1:0] grant
	);
	//Vars
	reg last_granted;
	
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			grant <= 2'b00; //Nothing
			last_granted <= 1'b0;
		end else begin
			if ((grant != 2'b00 ) && (!transaction_done)) begin
				grant <= grant;
			end else begin
				case (req)
					2'b00 : begin //No Requests
						grant <= 2'b00;
					end
					2'b01 : begin //Master 0 Requests
						grant <= 2'b01;
						last_granted <= 1'b0;
					end
					2'b10 : begin //Master 1 Requests
						grant <= 2'b10;
						last_granted <= 1'b1;
					end
					2'b11 : begin //Both Masters Requests
						if (last_granted == 1'b0) begin //M0 had last, M1 next
							grant <= 2'b10;
							last_granted <= 1'b1;
						end else begin
							grant <= 2'b01;
							last_granted <= 1'b0;
						end
					end
					default : begin
						grant <=2'b00;
					end
				endcase
			end
		end
	end
endmodule
