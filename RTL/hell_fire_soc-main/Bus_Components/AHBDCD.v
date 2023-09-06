/*
  Design: AHB Decoder 
  Date : 21 June 2023 
  Author : Srimanth Tenneti 
  Description : Address Decoder 
*/

module AHBDCD #(parameter W = 32)(
    // Input Address
    input wire [W-1:0] HADDR, 
    // Peripheral Select 
    output wire hsel_s0, 
    output wire hsel_s1, 
    output wire hsel_s2, 
    output wire hsel_s3,
    output wire hsel_nomap,
    // Mux Select  
  output wire [1:0] mux_sel_out  
); 

reg [15:0] DECODER; 
reg [1:0] mux_sel; 

assign hsel_s0 = DECODER[0]; // 0x0000_0000 -> 0x00FF_FFFF -> Memory 
assign hsel_s1 = DECODER[1]; // 0x5000_0000 -> 0x50FF_FFFF -> GPIO
assign hsel_s2 = DECODER[2]; // 0x5100_0000 -> 0x51FF_FFFF -> Array  -> 8x Values 
assign hsel_nomap = DECODER[15];

always @ * 
begin
  case (HADDR[31:24])  
    8'h00 : 
      begin
         DECODER = 16'b0000_0000_0000_0001;  // MEMORY
         mux_sel = 2'b00; 
      end
    8'h50 : 
      begin
        DECODER = 16'b0000_0000_0000_0010;   // GPIO
        mux_sel = 2'b01; 
      end 
    8'h51 : 
      begin
        DECODER = 16'b0000_0000_0000_0100;   // Accelerator
        mux_sel = 2'b10;  
      end
    default : 
      begin
        DECODER = 16'b1000_0000_0000_0000;   // NO MAP
        mux_sel = 2'b11; 
      end
  endcase
end
  
assign mux_sel_out = mux_sel;

endmodule