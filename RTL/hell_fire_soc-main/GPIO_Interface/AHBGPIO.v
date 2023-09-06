// ************************************************************
// Design : GPIO Peripheral 
// Author: Srimanth Tenneti 
// Date: 25th July 2023 
// Version : 0.02
// ************************************************************

module AHB2IO #(parameter W = 32) (
    // Global Clock and Reset
    input wire HCLK, 
    input wire HRESETn, 
    // AHB Control Signals 
    input wire HSEL, 
    input wire HWRITE, 
    input wire HREADY, 
    input wire HMASTLOCK, 
    // Address and Data  
    input wire [W - 1 : 0] HADDR, 
    input wire [W - 1 : 0] HWDATA, 
    // Transaction Control 
    input wire [1:0] HTRANS, 
    input wire [2:0] HBURST, 
    input wire [2:0] HSIZE, 
    // Output and Transfer Response
    output wire HRESP, 
    output wire HREADYOUT, 
    output wire [W - 1 : 0] HRDATA, 
    // Peripheral Control 
    output wire [3:0] LED
);

// Address Phase Control Signals 
reg Aphase_HSEL, Aphase_HWRITE, Aphase_HMASTLOCK;
reg [1:0] Aphase_HTRANS; 
reg [2:0] Aphase_HBURST, Aphase_HSIZE; 
reg [W - 1 : 0] Aphase_HADDR; 

// LED Peripheral Register 
reg [3:0] LED_REG; 

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) begin
        Aphase_HSEL      <= 0; 
        Aphase_HWRITE    <= 0; 
        Aphase_HMASTLOCK <= 0; 
        Aphase_HTRANS    <= 0; 
        Aphase_HBURST    <= 0; 
        Aphase_HSIZE     <= 0; 
        Aphase_HADDR     <= 0; 
   end
   else begin
        if (HREADY) begin
           Aphase_HSEL       <= HSEL; 
           Aphase_HWRITE     <= HWRITE;
           Aphase_HMASTLOCK  <= HMASTLOCK; 
           Aphase_HTRANS     <= HTRANS; 
           Aphase_HBURST     <= HBURST;
           Aphase_HSIZE      <= HSIZE;
           Aphase_HADDR      <= HADDR; 
        end 
   end
end


// Write2LED REG
wire write_transaction; 
assign write_transaction = Aphase_HSEL && Aphase_HTRANS[1] && Aphase_HWRITE; 

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) begin
       LED_REG <= 0; 
   end
   else 
     begin
        if (write_transaction) 
           LED_REG <= HWDATA[3:0]; 
     end
end

// Write to Peripheral 
assign LED = LED_REG; 

// ReadFrLED REG 
assign HRDATA = {28'h0, LED_REG}; 

// Response Signalling 
assign  HRESP = 0; 
assign HREADYOUT = 1; 

endmodule
