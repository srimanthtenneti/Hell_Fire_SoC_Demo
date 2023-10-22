// **************************************************************************
// Design : AHB SoC Interface Top 
// Standard : AMBA3 AHB-Lite 
// Author: Srimanth Tenneti 
// Date: 22th August 2023 
// Version : 0.01
// Bugs : HREADYOUT and HRESP Signal Issues
// **************************************************************************


// HRESP -> 0 -> OKAY
// HRESP -> 1 -> ERROR

module AHB_Soc_Interface #(parameter W = 32)(
    
    // Global Clock and Reset
    input wire HCLK, 
    input wire HRESETn, 

    // Control Signals 
    input wire HSEL, 
    input wire HWRITE, 
    input wire HMASTLOCK,  
    
    input wire [1:0] HTRANS, 
    input wire [2:0] HBURST, 
    input wire [2:0] HSIZE, 
    
    // Address and Data  
    input wire [W-1:0] HWDATA, 
    
    // Response
    output wire [W-1:0] HRDATA, // Done
    output wire HREADYOUT,    // Done
    output wire HRESP   // Done
 
);

// **************************************************************************
//      Address Phase Signals
// **************************************************************************
 

reg Aphase_HSEL; 
reg Aphase_HSEL1; 

reg Aphase_HWRITE; 
reg Aphase_HWRITE1; 

reg [1:0] Aphase_HTRANS; 
reg [1:0] Aphase_HTRANS1; 


always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) 
   begin
     Aphase_HSEL <= 0;
     Aphase_HSEL1 <= 0;
   end
   else 
   begin
     Aphase_HSEL1 <= HSEL;
     Aphase_HSEL <= Aphase_HSEL1; 
   end
end

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) 
   begin
     Aphase_HWRITE <= 0;
     Aphase_HWRITE1 <= 0;
   end
   else 
   begin
     Aphase_HWRITE1 <= HWRITE;
     Aphase_HWRITE <= Aphase_HWRITE1; 
   end
end

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) 
   begin
     Aphase_HTRANS <= 0;
     Aphase_HTRANS1 <= 0;
   end
   else 
   begin
     Aphase_HTRANS1 <= HTRANS;
     Aphase_HTRANS <= Aphase_HTRANS1; 
   end
end



// AHB Lite Write 
wire write_control; 
assign write_control = Aphase_HSEL && Aphase_HTRANS[1] && Aphase_HWRITE; 

// **************************************************************************



// **************************************************************************
//     IP Stream Top -> MIF, DDS Switch, Aligners, 4x4 Array
// **************************************************************************

// OSF Data Input
reg we; 

wire [31:0] OSF_DATA_LINK;

// MIF Status from Stream Top
wire mif_empty; 
wire mif_full; 

// We controller
wire valid; // -> We controller for the OSF

reg [31:0] HWDATA_Q; 

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) 
     HWDATA_Q <= 0; 
   else 
     HWDATA_Q <= HWDATA; 
end

IP_Stream_Top stream_top_0 (
    .clk(HCLK), 
    .resetn(HRESETn), 
    .we(write_control), 
    .datain(HWDATA_Q), 
    .dataout(OSF_DATA_LINK), 
    .valid(valid), 
    .master_full(mif_full), 
    .master_empty(mif_empty)
); 

// **************************************************************************


// **************************************************************************
//      Output Stream FIFO (OSF) -> For AHB Read Transaction 
// **************************************************************************

wire osf_empty; 
wire osf_full; 


// For Response Stability

reg val_Q; 
wire valid_fall_edge; 

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) 
     val_Q <= 0; 
   else 
     val_Q <= valid; 
end

assign valid_fall_edge = ~valid && val_Q; 

reg cal_Q; 

wire osf_full_edge; 
wire osf_empty_edge; 

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) 
     cal_Q <= 0; 
   else 
     begin
        if (valid_fall_edge)
          cal_Q <= 1; 
        if (osf_empty_edge) 
          cal_Q <= 0; 
     end
end


wire osf_read_control; 
// Fall Edge added for Stability 
assign osf_read_control = HSEL && HTRANS[1] && ~Aphase_HWRITE  && cal_Q; 

reg [31:0] OSFOUT_Q;
wire [31:0] OSFOUT; 

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) 
    OSFOUT_Q <= 0; 
   else 
   begin
      OSFOUT_Q <= OSFOUT; 
   end
end

Circular_FIFO #(
  .W(32), 
  .D(8)
  ) 
  OSF0 (
    .clk(HCLK), 
    .resetn(HRESETn), 
    .we(valid), 
    .re(osf_read_control), 
    .data(OSF_DATA_LINK), 
    .fifo_full(osf_full), 
    .fifo_empty(osf_empty), 
    .dataout(OSFOUT)
); 

assign HRDATA = OSFOUT_Q;

// **************************************************************************



// **************************************************************************
//     FIFO Status Edge Generation 
// **************************************************************************

// Master Interface FIFO (MIF) Status Edges 
wire mif_full_edge; 
wire mif_empty_edge; 

Pos_detector mif_empty_edge_0 (
    .clk(HCLK), 
    .resetn(HRESETn), 
    .signal(mif_empty), 
    .edge_(mif_empty_edge)
); 


Pos_detector mif_full_edge_0 (
    .clk(HCLK), 
    .resetn(HRESETn), 
    .signal(mif_full), 
    .edge_(mif_full_edge)
); 


// Output Stream FIFO (OSF) Status Edges 

Pos_detector osf_empty_edge_0 (
    .clk(HCLK), 
    .resetn(HRESETn), 
    .signal(osf_empty), 
    .edge_(osf_empty_edge)
); 


Pos_detector osf_full_edge_0 (
    .clk(HCLK), 
    .resetn(HRESETn), 
    .signal(osf_full), 
    .edge_(osf_full_edge)
); 

// **************************************************************************



// **************************************************************************
//     MIF Write Enable Handler +++
// **************************************************************************

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) 
     we = 0; 
    else 
      begin
        if (write_control && ~mif_full_edge) // -> !!! Check this later !!!
          we = 1; 
        if (mif_full_edge) 
          we = 0;  
      end
end

// MIF Write Output 
assign we_out = we; 

// **************************************************************************




// **************************************************************************
//    HREADYOUT Handler 
// **************************************************************************

reg HRDY; 

wire dataphase; 
assign dataphase = (Aphase_HSEL1 && Aphase_HTRANS1[1]); 

reg calZ; 

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) 
    calZ <= 0; 
   else 
     if (osf_full_edge)
    calZ <= 1;  
     
end  

always @ (posedge HCLK or negedge HRESETn) begin
  if (~HRESETn) 
    HRDY <= 1; 
  else 
    begin
       if (mif_full_edge | dataphase) 
          HRDY <= 0; 
       else 
          HRDY <= 1;
       if ((calZ && ~dataphase))
          HRDY <= 1; 
    end
end

assign HREADYOUT = HRDY; 

// **************************************************************************



// **************************************************************************
//    HRESP Handler 
// **************************************************************************


reg error_Q, error_Q1; 

always @ (posedge HCLK or negedge HRESETn) begin
   if (~HRESETn) 
   begin
      error_Q <= 0; 
      error_Q1 <= 0;
   end
   else 
      begin
        if (osf_empty_edge && HSEL) 
           error_Q <= 1;
        if (mif_full_edge && HSEL) 
           error_Q <= 0; 
        error_Q1 <= error_Q; // PIPE to compensate 1 cycle delay full and empty
      end
end

wire osf_read_empty_error; 
wire burst_transaction_error; 

// OSF Empty Error Response
assign osf_read_empty_error = (Aphase_HSEL && Aphase_HTRANS[1] && ~Aphase_HWRITE)  && error_Q1;

// Burst Transaction Attempt from the Master 
assign burst_transaction_error = (Aphase_HSEL && Aphase_HTRANS[0]); 

// HRESP Assignment 
assign HRESP = osf_read_empty_error | burst_transaction_error; 

// **************************************************************************
endmodule