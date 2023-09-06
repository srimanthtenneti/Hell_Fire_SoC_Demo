// **************************************************************
// Design : Data Delivery Subsystem  - Top
// Author: Srimanth Tenneti 
// Date: 19th July 2023 
// Version : 0.04
// **************************************************************

module Data_Delivery_Top #(parameter W = 32) (
     
     // Global Clock and Reset
     input clk, 
     input resetn, 

     input select, 

     // Payload 
     input [W - 1 : 0] data,
     
     // Master Read Pointer Input  
     input [2 : 0] rptr_in, 
     
     // Aligned Data 
     output wire [7:0] w1_data,  
     output wire [7:0] w2_data,  
     output wire [7:0] w3_data,  
     output wire [7:0] w4_data, 

     output wire [7:0] n1_data, 
     output wire [7:0] n2_data, 
     output wire [7:0] n3_data, 
     output wire [7:0] n4_data, 

     // Master Pointer Update 
     output wire master_rptr_en, 
     output wire n4_full_pos_out, 

     output wire gure
);


wire w1full, w1empty; 
wire w2full, w2empty;
wire w3full, w3empty;
wire w4full, w4empty;
wire n1full, n1empty;
wire n2full, n2empty;
wire n3full, n3empty;
wire n4full, n4empty;

wire sel0t; 
wire sel1t;
wire sel2t;
wire sel3t;
wire sel4t;
wire sel5t;
wire sel6t;
wire sel7t;

wire [W-1:0] lane0, lane1, lane2, lane3, lane4, lane5, lane6, lane7; 

wire uni_read; 


Data_Switch switch0 (
   
   // Global Clock and Reset
   .clk(clk), 
   .resetn(resetn), 
   .select(select), 

   // Payload 
   .data(data), 
   
   // RPTR 
   .rptr_in(rptr_in),

   // West Lane
   .w1_full(w1full), 
   .w1_empty(w1empty),

   .w2_full(w2full), 
   .w2_empty(w2empty),

   .w3_full(w3full), 
   .w3_empty(w3empty),

   .w4_full(w4full), 
   .w4_empty(w4empty),

   // North Lane 
   .n1_full(n1full), 
   .n1_empty(n1empty), 

   .n2_full(n2full), 
   .n2_empty(n2empty),

   .n3_full(n3full), 
   .n3_empty(n3empty),

   .n4_full(n4full), 
   .n4_empty(n4empty),

   // Data Lanes  -> Done
   .dataout0(lane0),
   .dataout1(lane1),
   .dataout2(lane2),
   .dataout3(lane3),
   .dataout4(lane4),
   .dataout5(lane5),
   .dataout6(lane6),
   .dataout7(lane7), 
   
   // Lane Select Signal -> Done 
   .sel0(sel0t), 
   .sel1(sel1t), 
   .sel2(sel2t), 
   .sel3(sel3t), 
   .sel4(sel4t), 
   .sel5(sel5t), 
   .sel6(sel6t), 
   .sel7(sel7t), 

   // Rptr Update -> Done
   .re_out_master(master_rptr_en),
   
   // N4 Stability
   .n4_full_pos_out(n4_full_pos_out),

   // Unified Read 
   .unified_read(uni_read) // -> Done 

);

assign gure = uni_read;

// @@@@@@@@@@@@@@@@@@@@@ West Lane Data Aligners @@@@@@@@@@@@@@@@@@@@@@@@@@@@

Alignment_Top_N1_W1 west1_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel0t), 
  
  // Payload 
  .data(lane0), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(w1_data), 

  // FIFO Status 
  .fifo_empty_top(w1empty), 
  .fifo_full_top(w1full)
  
);

Alignment_Top_N2_W2 west2_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel1t), 
  
  // Payload 
  .data(lane1), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(w2_data), 

  // FIFO Status 
  .fifo_empty_top(w2empty), 
  .fifo_full_top(w2full)
  
);

Alignment_Top_N3_W3 west3_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel2t), 
  
  // Payload 
  .data(lane2), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(w3_data), 

  // FIFO Status 
  .fifo_empty_top(w3empty), 
  .fifo_full_top(w3full)
  
);

Alignment_Top_N4_W4 west4_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel3t), 
  
  // Payload 
  .data(lane3), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(w4_data), 

  // FIFO Status 
  .fifo_empty_top(w4empty), 
  .fifo_full_top(w4full)
  
);

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@ North Lane Data Aligners @@@@@@@@@@@@@@@@@@@@@


Alignment_Top_N1_W1 north1_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel4t), 
  
  // Payload 
  .data(lane4), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(n1_data), 

  // FIFO Status 
  .fifo_empty_top(n1empty), 
  .fifo_full_top(n1full)
  
);

Alignment_Top_N2_W2 north2_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel5t), 
  
  // Payload 
  .data(lane5), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(n2_data), 

  // FIFO Status 
  .fifo_empty_top(n2empty), 
  .fifo_full_top(n2full)
  
);

Alignment_Top_N3_W3 north3_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel6t), 
  
  // Payload 
  .data(lane6), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(n3_data), 

  // FIFO Status 
  .fifo_empty_top(n3empty), 
  .fifo_full_top(n3full)
  
);

Alignment_Top_N4_W4 north4_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel7t), 
  
  // Payload 
  .data(lane7), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(n4_data), 

  // FIFO Status 
  .fifo_empty_top(n4empty), 
  .fifo_full_top(n4full)
  
);


endmodule 