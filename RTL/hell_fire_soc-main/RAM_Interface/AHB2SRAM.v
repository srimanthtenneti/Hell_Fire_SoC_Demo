// ************************************************************
// Design : Memory Interface 
// Author: Srimanth Tenneti 
// Date: 25th July 2023 
// Version : 0.04
// ************************************************************

module AHB2SRAM # (parameter WIDTH = 14)(

// Clock and Reset

input HCLK, 
input HRESETn, 

// Address and Control 

input HSEL, 
input HWRITE, 
input HREADY, 
input HMASTLOCK, 

input [31:0] HADDR, 

input [1:0] HTRANS, 
input [2:0] HSIZE, 
input [2:0] HBURST, 

// Data 

input [31:0] HWDATA, 
output [31:0] HRDATA, 

// Response 
output HRESP, 
output HREADYOUT 

); 

// Registering Address and Control Signals 
reg HSELq, HWRITEq, HMASTLOCKq;
reg [1:0] HTRANSq; 
reg [2:0] HBURSTq, HSIZEq; 
reg [31 : 0] HADDRq; 

// Physical memory Model 
reg [31:0] memory [0:(2**(WIDTH-2)-1)]; 

initial 
begin 
  $readmemh("code.hex", memory);
end 

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) begin
        HSELq      <= 0; 
        HWRITEq    <= 0; 
        HMASTLOCKq <= 0; 
        HTRANSq    <= 0; 
        HBURSTq    <= 0; 
        HSIZEq     <= 0; 
        HADDRq     <= 0; 
   end
   else begin
        if (HREADY) begin
           HSELq       <= HSEL; 
           HWRITEq     <= HWRITE;
           HMASTLOCKq  <= HMASTLOCK; 
           HTRANSq     <= HTRANS; 
           HBURSTq     <= HBURST;
           HSIZEq      <= HSIZE;
           HADDRq      <= HADDR; 
        end 
   end
end


// Checking for a Non-Seq transfer 
wire tx_en; 
assign tx_en = HSELq && HWRITEq && HTRANSq[1]; 

// Transfer Decoding
wire len_byte; 
wire len_half_word; 
wire len_word; 
 
assign len_byte = ~HSIZEq[0] && ~HSIZEq[1]; 
assign len_half_word = HSIZEq[0] && ~HSIZEq[1]; 
assign len_word  = ~HSIZEq[0] && HSIZEq[1]; 

// Bytes Handler 
wire ByteLane0, ByteLane1, ByteLane2, ByteLane3; 

assign ByteLane0 =  tx_en && ~HADDRq[0] && ~HADDRq[1]; 
assign ByteLane1 =  tx_en && HADDRq[0] && ~HADDRq[1];
assign ByteLane2 =  tx_en && ~HADDRq[0] && HADDRq[1];
assign ByteLane3 =  tx_en && HADDRq[0] && HADDRq[1];

wire  Byte0, Byte1, Byte2, Byte3; 

assign Byte0 = len_byte && ByteLane0; 
assign Byte1 = len_byte && ByteLane1;
assign Byte2 = len_byte && ByteLane2;
assign Byte3 = len_byte && ByteLane3;

// Half Word Handler 
wire HalfWordLane0, HalfWordLane1; 

assign HalfWordLane0 = tx_en && ~HADDRq[1]; 
assign HalfWordLane1 = tx_en &&  HADDRq[1]; 

wire HalfWord0, HalfWord1; 

assign HalfWord0 = HalfWordLane0 && len_half_word; 
assign HalfWord1 = HalfWordLane1 && len_half_word; 

// Word Handler 
wire WordLane0; 
assign WordLane0 = tx_en && len_word; 

// Individual Lane Enable Signals 
wire ByteEn0, ByteEn1, ByteEn2, ByteEn3; 

assign ByteEn0 = Byte0 | HalfWord0 | WordLane0; 
assign ByteEn1 = Byte1 | HalfWord0 | WordLane0; 
assign ByteEn2 = Byte2 | HalfWord1 | WordLane0; 
assign ByteEn3 = Byte3 | HalfWord1 | WordLane0; 

always @ (posedge HCLK) 
begin
  if (ByteEn0) 
     memory[HADDRq[WIDTH:2]][7:0]   <= HWDATA[7:0]; 
  if (ByteEn1)
     memory[HADDRq[WIDTH:2]][15:8]  <= HWDATA[15:8]; 
  if (ByteEn2) 
     memory[HADDRq[WIDTH:2]][23:16] <= HWDATA[23:16];
  if (ByteEn3)
     memory[HADDRq[WIDTH:2]][31:24] <= HWDATA[31:24]; 
end 

  assign HRDATA = memory[HADDRq[WIDTH:2]]; 
  assign HRESP = 0; 
  assign HREADYOUT = 1; 

endmodule
