module axi_crossbar (
	//Standards
	input wire clk,
	input wire reset_n,
	
	//*********************
	//*Master 0 Interface *
	//*********************
	
	// *CHANNEL DESCRIPTIONS*
	// * Write Address (AW), sends the address of what is being written. 
	// Sends Valid and Ready signals for confirmation
	// * Write Data (W), sends what is being written, 
	// * Write Responses (B), sends back a signal saying the status code
	// * Read Address (AR),
	// * Read Data (R),
	
	// *VAR DESCRIPTIONS*
	// *Response sends a success or fail of transaction, it has 2 bits:
	//		2'b00: OKAY | Transaction is a success
	//		2'b01: EXOKAY | Exclusive Transaction is a success
	//		2'b10: SLVERR | Slave Error, info sent to slave but it returned error
	// 	2'b11: DECERR | Decode Error, info sent cannot be found to any target
	
	//Write Address Channel (AW)
	input wire [31:0]  m0_AWAddr,
	input wire 			 m0_AWValid,
	output wire 		 m0_AWReady,
	
	//Write Data Channel (W)
	input wire [31:0]  m0_WData,
	input wire [3:0]   m0_WStrb,
	input wire 			 m0_WValid,
	output wire 		 m0_WReady,
	
	//Write Response (B)
	output reg [1:0]   m0_BResp,
	output reg 		    m0_BValid,
	input wire 			 m0_BReady,
	
	//Read Address Channel (AR)
	input wire [31:0]  m0_ARAddr,
	input wire 			 m0_ARValid,
	output wire 		 m0_ARReady,
	
	//Read Data Channel (R)
	output reg [31:0]  m0_RData,
	output reg [1:0]   m0_RResp,
	output reg  		 m0_RValid,
	input wire 			 m0_RReady,
	 
	//*********************
	//*Master 1 Interface *
	//********************* 
	
	//Write Address Channel (AW)
	input wire [31:0]  m1_AWAddr,
	input wire			 m1_AWValid,
	output wire 		 m1_AWReady,
	
	//Write Data Channel (W)
	input wire [31:0]  m1_WData,
	input wire [3:0]	 m1_WStrb,
	input wire      	 m1_WValid,
	output wire 		 m1_WReady,
	
	//Write Response (B)
	output reg [1:0]   m1_BResp,
	output reg 		    m1_BValid,
	input wire 			 m1_BReady,
	
	//Read Address Channel (AR)
	input wire [31:0]  m1_ARAddr,
	input wire 			 m1_ARValid,
	output wire 		 m1_ARReady,
	
	//Read Data Channel (R)
	output reg [31:0]  m1_RData,
	output reg [1:0]   m1_RResp,
	output reg 		 	 m1_RValid,
	input wire 			 m1_RReady,
	
	//*********************
	//*Slave 0 Interface  *
	//********************* 
	
	output wire [31:0] s0_AWAddr,
	output wire 		 s0_AWValid,
	input wire 		 	 s0_AWReady,
	
	//Write Data Channel (W)
	output wire [31:0] s0_WData,
	output wire [3:0]  s0_WStrb,
	output wire 		 s0_WValid,
	input wire 		    s0_WReady,
	
	//Write Response (B)
	input wire [1:0]   s0_BResp,
	input wire 		    s0_BValid,
	output wire 		 s0_BReady,
	
	//Read Address Channel (AR)
	output wire [31:0] s0_ARAddr,
	output wire 		 s0_ARValid,
	input wire 		    s0_ARReady,
	
	//Read Data Channel (R)
	input wire [31:0]  s0_RData,
	input wire [1:0]   s0_RResp,
	input wire 		    s0_RValid,
	output wire 		 s0_RReady,
	
	//*********************
	//*Slave 1 Interface  *
	//********************* 
	
	output wire [31:0] s1_AWAddr,
	output wire 		 s1_AWValid,
	input wire 		 	 s1_AWReady,
	
	//Write Data Channel (W)
	output wire [31:0] s1_WData,
	output wire [3:0]  s1_WStrb,
	output wire 		 s1_WValid,
	input wire 		    s1_WReady,
	
	//Write Response (B)
	input wire [1:0]   s1_BResp,
	input wire 		    s1_BValid,
	output wire 		 s1_BReady,
	
	//Read Address Channel (AR)
	output wire [31:0] s1_ARAddr,
	output wire 		 s1_ARValid,
	input wire 		    s1_ARReady,
	
	//Read Data Channel (R)
	input wire [31:0]  s1_RData,
	input wire [1:0]   s1_RResp,
	input wire 		    s1_RValid,
	output wire 		 s1_RReady
);
//Arbiter
wire [1:0] 	arbit_input;
wire [1:0]  arbit_grant;
wire 			arbit_transactiondone;

//Decoder
wire [31:0] dec_addr;
wire			dec_sel_s0;
wire			dec_sel_s1;
wire			dec_decerr;

//Read-Arbiter
wire [1:0]	read_arbit_input;
wire [1:0]	read_arbit_grant;
wire 			read_arbit_transactiondone;

//Read-Decoder
wire [31:0] read_dec_addr;
wire 			read_dec_sel_s0;
wire 			read_dec_sel_s1;

//Routing Variables
//-AW Vars
reg 			selected_AWValid;
reg 			selected_AWReady;
//-W Vars
reg [31:0]  selected_WData;
reg 			selected_WReady;
reg 			selected_WValid;
reg [3:0] 	selected_WStrb;
//-B Vars
reg  [1:0]	selected_BResp;
reg 			selected_BValid;
reg 			selected_BReady;
//-AR Vars
reg 			selected_ARValid;
reg 			selected_ARReady;
//-R Vars
reg [31:0]	selected_RData;
reg [1:0]	selected_RResp;
reg			selected_RValid;
reg 			selected_RReady;
	

axi_arbiter write_arbiter (
	.clk 					(clk),
	.reset_n				(reset_n),
	.req 					(arbit_input),
	.transaction_done (arbit_transactiondone),
	.grant 				(arbit_grant)
);

axi_decoder write_decoder (
	.addr					(dec_addr),
	.sel_s0 				(dec_sel_s0),
	.sel_s1				(dec_sel_s1),
	.decerr				(dec_decerr)
);

axi_arbiter read_arbiter (
	.clk 					(clk),
	.reset_n				(reset_n),
	.req 					(read_arbit_input),
	.transaction_done (read_arbit_transactiondone),
	.grant 				(read_arbit_grant)
);

axi_decoder read_decoder (
	.addr					(read_dec_addr),
	.sel_s0 				(read_dec_sel_s0),
	.sel_s1				(read_dec_sel_s1),
	.decerr				(read_dec_decerr)
);
//Write Address Channel
//Routes for Addresses
assign dec_addr = (arbit_grant[0]) ? m0_AWAddr : m1_AWAddr; //Looks at bit 0 of Grant and checks if its 1, sends to decoder
assign s0_AWAddr = dec_addr;
assign s1_AWAddr = dec_addr;
assign arbit_transactiondone = selected_AWValid & selected_AWReady;

//Deciding which one is Valid (Either 1 or 0, AWReady decides which route to go)
always @(*) begin
	selected_AWValid = 1'b0;
	if (arbit_grant[0]) begin
		selected_AWValid = m0_AWValid;
	end else if (arbit_grant[1]) begin
		selected_AWValid = m1_AWValid;
	end
end

assign arbit_input = {m1_AWValid, m0_AWValid};
assign s0_AWValid = selected_AWValid & dec_sel_s0;
assign s1_AWValid = selected_AWValid & dec_sel_s1;

//Deciding which route the information will go to
//Sends confirmation signals.
always @(*) begin
	selected_AWReady = 1'b0;
	selected_WReady = 1'b0;
	if (dec_sel_s0) begin
		selected_AWReady = s0_AWReady;
		selected_WReady = s0_WReady;
	end else if (dec_sel_s1) begin
		selected_AWReady = s1_AWReady;
		selected_WReady = s1_WReady;
	end else if (dec_decerr) begin
		selected_AWReady = 1'b1;
		selected_WReady = 1'b1;
	end
end

assign m0_AWReady = selected_AWReady & (arbit_grant[0]);
assign m1_AWReady = selected_AWReady & (arbit_grant[1]);

//Writing Channel
assign s0_WValid = (arbit_grant[0]) & dec_sel_s0;
assign s1_WValid = (arbit_grant[1]) & dec_sel_s1;

always @(*) begin
	selected_WValid = 1'b0;
	selected_WStrb  = 4'b0000;
	selected_WData  = 32'h0000_0000;
	if (arbit_grant[0]) begin
		selected_WValid = m0_WValid;
		selected_WStrb  = m0_WStrb;
		selected_WData  = m0_WData;
	end else if (arbit_grant[1]) begin
		selected_WValid = m1_WValid;
		selected_WStrb  = m1_WStrb;
		selected_WData  = m1_WData;
	end
end

assign s0_WStrb  = selected_WStrb;
assign s1_WStrb  = selected_WStrb;
assign s0_WData = selected_WData;
assign s1_WData = selected_WData;

assign m0_WReady = selected_WReady & arbit_grant[0];
assign m1_WReady = selected_WReady & arbit_grant[1];

 
//Responses Channel
//Decoder Sends which is selected, connect those signals to Crossbar
always @(*) begin
	selected_BResp = 2'b00;
	selected_BValid = 1'b0;
	if (dec_sel_s0) begin
		selected_BResp = s0_BResp;
		selected_BValid = s0_BValid;
	end else if (dec_sel_s1) begin
		selected_BResp = s1_BResp;
		selected_BValid = s1_BValid;
	end else if (dec_decerr) begin
	//Fabricated Output
		selected_BResp = 2'b11;
		selected_BValid = 1'b1;
	end
end

always @(*) begin
	m0_BResp = 2'b00;
	m1_BResp = 2'b00;
	m0_BValid = 1'b0;
	m1_BValid = 1'b0;
	selected_BReady = 1'b0;
	if (arbit_grant[0]) begin
		m0_BResp = selected_BResp;
		m0_BValid = selected_BValid;
		selected_BReady = m0_BReady;
	end else if (arbit_grant[1]) begin
		m1_BResp = selected_BResp;
		m1_BValid = selected_BValid;
		selected_BReady = m1_BReady;
	end
end
//Now have Responses, send them back

assign s0_BReady = selected_BReady & dec_sel_s0;
assign s1_BReady = selected_BReady & dec_sel_s1;


//Read Address Channels
assign read_arbit_input = {m1_ARValid , m0_ARValid};
assign read_dec_addr = (read_arbit_grant[0]) ? m0_ARAddr : m1_ARAddr;
assign s0_ARAddr = read_dec_addr;
assign s1_ARAddr = read_dec_addr;

always @(*) begin
	selected_ARValid = 0;
	if (read_arbit_grant[0]) begin
		selected_ARValid = m0_ARValid;
	end else if (read_arbit_grant[1]) begin
		selected_ARValid = m1_ARValid;
	end
end

assign s0_ARValid = selected_ARValid & read_dec_sel_s0;
assign s1_ARValid = selected_ARValid & read_dec_sel_s1;

always @(*) begin
	if (read_dec_sel_s0) begin
		selected_ARReady = s0_ARReady;
	end else if (read_dec_sel_s1) begin
		selected_ARReady = s1_ARReady;
	end else if (read_dec_decerr) begin
		selected_ARReady = 1;
	end else begin
		selected_ARReady = 0;
	end
end

assign m0_ARReady = (read_arbit_grant[0]) & selected_ARReady;
assign m1_ARReady = (read_arbit_grant[1]) & selected_ARReady;
assign read_arbit_transactiondone = selected_ARReady & selected_ARValid;

//Read Data Channel
always @(*) begin
	selected_RData = 32'h0000_0000;
	selected_RResp = 2'b00;
	selected_RValid = 0;
	if (read_dec_sel_s0) begin
		selected_RData = s0_RData;
		selected_RResp = s0_RResp;
		selected_RValid = s0_RValid;
	end else if (read_dec_sel_s1) begin
		selected_RData = s1_RData;	
		selected_RResp = s1_RResp;
		selected_RValid = s1_RValid;
	end else if (read_dec_decerr) begin
		selected_RData = 32'h0000_0000;
		selected_RResp = 2'b11;
		selected_RValid = 1;
	end 
end

always @(*) begin
	//Latch Prevention
	m0_RData = 32'h0000_0000;
	m0_RResp = 2'b00;
	m0_RValid = 0;
	m1_RData = 32'h0000_0000;
	m1_RResp = 2'b00;
	m1_RValid = 0;
	selected_RReady = 0;
	if (read_arbit_grant[0]) begin
		m0_RData = selected_RData;
		m0_RResp = selected_RResp;
		m0_RValid = selected_RValid;
		selected_RReady = m0_RReady;
	end else if (read_arbit_grant[1]) begin
		m1_RData = selected_RData;
		m1_RResp = selected_RResp;
		m1_RValid = selected_RValid;
		selected_RReady = m1_RReady;
	end
end

assign s0_RReady = selected_RReady & (read_dec_sel_s0);
assign s1_RReady = selected_RReady & (read_dec_sel_s1);

endmodule
