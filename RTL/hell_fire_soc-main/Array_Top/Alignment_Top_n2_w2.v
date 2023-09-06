// ************************************************************
// Design : Single Lane Data Sequencer 
// Author: Srimanth Tenneti 
// Date: 19th July 2023 
// Version : 0.04
// ************************************************************

// Additional Sequncer Signals Needed 
//  1. We for Alignment FIFO Write control 
//  2. Re for Alignment FIFO Read Control 
//  3. FIFO Full 
//  4. FIFO Empty
//  5. Reset Synchronizer - 1 Cycle between Data Sequencer
// and FIFO 

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Data Sequencer @@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// Requirements 
// 1. Data Must Remain Stable During a Transaction 
//  |-> So, unitl a RPTR update the data should not change 
// 2. Master Re must be single stage delayed 

module Data_Sequencer_V3_N2_W2 (
 // Global Clock and Reset
 input clk, 
 input resetn, 
 // Global Select
 input sel, 
 // Payload
 input [31:0] data,
 // Alignment FIFO Status 
 input FIFO_full, 
 input FIFO_empty, 
 // Global Read Enable Signal 
 input global_re, 
 // Alignment We 
 output we, 
 // Alignment Re
 output re, 
 // Sequencer Dataout
 output [7:0] D1
);


// Bug Fix -> Sel Data Storage Issue

reg [31:0] dataQ_f; 

always @ (posedge clk or negedge resetn) begin 
  if (~resetn) 
    dataQ_f <= 0; 
  else 
    if (sel) 
       dataQ_f <= data; 
    else 
       dataQ_f <= dataQ_f; 
end


// FIFO Control 
reg weQ; 
  
// Internal Data Lane
reg [7:0] D1Q;

// Byte Lane Sequences 
reg  [7:0] Byte0Q, Byte1Q, Byte2Q, Byte3Q;  
wire [7:0] Byte0, Byte1, Byte2, Byte3; 

// Bit Counter Variables 
reg [2:0] bcount, bcountf; 
wire [2:0] nbcount; 

// Data Decode
assign Byte0 = dataQ_f[7:0]; 
assign Byte1 = dataQ_f[15:8]; 
assign Byte2 = dataQ_f[23:16]; 
assign Byte3 = dataQ_f[31:24]; 


// Byte Data Storage
  always @ (*) 
 begin
  if (~resetn) 
   begin
     Byte0Q <= 0; 
     Byte1Q <= 0; 
     Byte2Q <= 0; 
     Byte3Q <= 0; 
   end
 else 
   begin
        Byte0Q <= Byte0; 
        Byte1Q <= Byte1; 
        Byte2Q <= Byte2; 
        Byte3Q <= Byte3; 
    end
 end  

// Bit Counter 
always @ (posedge clk or negedge resetn)
  begin
    if (~resetn) 
     begin
       bcount <= 0; 
       bcountf <= 0;
     end
    else 
     begin
       bcountf <= nbcount;  
       bcount <= bcountf; 
     end
  end

// Bit Counter Increment Logic 
assign nbcount = ((bcountf < 3'd6) && sel) ? bcountf + 3'd1 : (~|bcountf && ~sel) ? 0 : bcountf; 

// Sequencer 
always @ (posedge clk or negedge resetn) 
  begin
    if (~resetn)
      begin
       D1Q <= 0;
       weQ <= 0; 
      end
    else 
      begin
        case(bcount) 
          3'd0 : begin if (sel && ~FIFO_full) begin D1Q <= 0; weQ <= 1; end  else weQ <= 0; end
          3'd1 : begin if (sel && ~FIFO_full) begin D1Q <= Byte0Q; weQ <= 1; end  else weQ <= 0; end
          3'd2 : begin if (sel && ~FIFO_full) begin D1Q <= Byte1Q; weQ <= 1; end  else weQ <= 0; end
          3'd3 : begin if (sel && ~FIFO_full) begin D1Q <= Byte2Q; weQ <= 1; end  else weQ <= 0; end
          3'd4 : begin if (sel && ~FIFO_full) begin D1Q <= Byte3Q; weQ <= 1; end       else weQ <= 0; end
          3'd5 : begin if (sel && ~FIFO_full) begin D1Q <= 0; weQ <= 1; end       else weQ <= 0; end
          3'd6 : begin if (sel && ~FIFO_full) begin D1Q <= 0; weQ <= 1; end       else weQ <= 0; end 
          default : begin  D1Q <= 0; weQ <= 0; end
        endcase
    end 
  end
  
  reg we_pipe; 
  
  always @ (posedge clk or negedge resetn) 
    begin 
      if (~resetn) 
        we_pipe <= 0; 
      else 
        we_pipe <= weQ; 
    end

// Output Data Assignment 
  assign D1 = D1Q; 
  assign we = we_pipe; 
  assign re = global_re; 

endmodule


// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  Alignment Top @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

module Alignment_Top_N2_W2 #(parameter W = 32)(
  
  // Clock and Reset 
  input clk, 
  input resetn, 
  
  input sel, 
  
  // Payload 
  input [W-1:0] data, 
  
  // Read Logic 
  input global_re, 
  
  
  // Aligned Data 
  output [7:0] aligned_data,

  output fifo_full_top, 

  output fifo_empty_top
  
); 
  
  wire [7:0] data_conn; 
  wire full, empty; 
  wire r, w; 
  
  Data_Sequencer_V3_N2_W2 sequencer0(
    .clk(clk), 
    .resetn(resetn),
    .sel(sel),
    .data(data),
    .FIFO_full(full), 
    .FIFO_empty(empty), 
    .global_re(global_re), 
    .we(w), 
    .re(r), 
    .D1(data_conn)
  );
  
  Circular_FIFO alignment_fifo0(
    .clk(clk), 
    .resetn(resetn), 
    .we(w), 
    .re(r), 
    .data(data_conn), 
    .fifo_full(full), 
    .fifo_empty(empty), 
    .dataout(aligned_data)
); 

assign fifo_empty_top = empty; 
assign fifo_full_top  = full; 
  
endmodule



