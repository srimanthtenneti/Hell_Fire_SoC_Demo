// **************************************************************
// Design : Data Delivery Subsystem  - Top
// Author: Srimanth Tenneti 
// Date: 23rd March 2024
// Version : 0.01
// Status -> Verified -> By Srimanth Tenneti 
// **************************************************************

module  lane_reuse_demux #(
    parameter Width = 8
) (
    // Global Clock and Reset 
    input wire clk, 
    input wire resetn, 

    // Datalane  
    input wire [Width - 1] datalane,

    // Select Lane 
    input wire sel0x, 
    input wire sel1x, 

    // Output lanes 
    output wire [Width - 1] outlane1, 
    output wire [Width - 1] outlane2
); 

// Input DataBus 
reg [Width - 1 : 0] dlane; 

always @ (posedge clk or negedge resetn) begin
   if (~resetn) begin
      dlane <= 0; 
   end 
   else begin
      dlane <= datalane; 
   end
end

assign outlane1 = ({sel1x, sel0x} == 2'b01) ? dlane : 0; 
assign outlane2 = ({sel1x, sel0x} == 2'b10) ? dlane : 0; 
    
endmodule