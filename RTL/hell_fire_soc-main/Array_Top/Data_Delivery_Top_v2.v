// **************************************************************
// Design : Data Delivery Subsystem  - Top - Area Optimized
// Author: Srimanth Tenneti 
// Date: March 23rd, 2024
// Version : 0.05
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

wire [W-1:0] lane0, lane1, lane2, lane3; 

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

   // Data Lanes  -> Done -> Cut to half 
   .dataout0(lane0),
   .dataout1(lane1),
   .dataout2(lane2),
   .dataout3(lane3),
   
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

// @@@@@@@@@@@@@@@@@@@@@  Data Aligners @@@@@@@@@@@@@@@@@@@@@@@@@@@@

wire [W - 1 : 0] W1_N1_Out; 
wire [W - 1 : 0] W2_N2_Out; 
wire [W - 1 : 0] W3_N3_Out; 
wire [W - 1 : 0] W4_N4_Out; 

Alignment_Top_N1_W1 west1_north1_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel0t | sel4t), 
  
  // Payload 
  .data(lane0), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(W1_N1_Out), 

  // FIFO Status 
  .fifo_empty_top(w1empty), 
  .fifo_full_top(w1full)
  
);

lane_reuse_demux lrd_W1_N1(
    // Global Clock and Reset 
    .clk(clk), 
    .resetn(resetn), 

    // Datalane  
    .datalane(W1_N1_Out),

    // Select Lane 
    .sel0x(sel0t), 
    .sel1x(sel4t), 

    // Output lanes 
    .outlane1(w1_data), 
    .outlane2(n1_data)
); 

Alignment_Top_N2_W2 west2_north2_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel1t | sel5t), 
  
  // Payload 
  .data(lane1), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(W2_N2_Out), 

  // FIFO Status 
  .fifo_empty_top(w2empty), 
  .fifo_full_top(w2full)
  
);

lane_reuse_demux lrd_W2_N2(
    // Global Clock and Reset 
    .clk(clk), 
    .resetn(resetn), 

    // Datalane  
    .datalane(W2_N2_Out),

    // Select Lane 
    .sel0x(sel1t), 
    .sel1x(sel5t), 

    // Output lanes 
    .outlane1(w2_data), 
    .outlane2(n2_data)
); 

Alignment_Top_N3_W3 west3_north3_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel2t | sel6t), 
  
  // Payload 
  .data(lane2), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(W3_N3_Out), 

  // FIFO Status 
  .fifo_empty_top(w3empty), 
  .fifo_full_top(w3full)
  
);

lane_reuse_demux lrd_W3_N3(
    // Global Clock and Reset 
    .clk(clk), 
    .resetn(resetn), 

    // Datalane  
    .datalane(W3_N3_Out),

    // Select Lane 
    .sel0x(sel2t), 
    .sel1x(sel6t), 

    // Output lanes 
    .outlane1(w3_data), 
    .outlane2(n3_data)
); 

Alignment_Top_N4_W4 west4_north4_aligner (
  
  // Clock and Reset 
  .clk(clk), 
  .resetn(resetn), 
  
  .sel(sel3t | sel7t), 
  
  // Payload 
  .data(lane3), 
  
  // Read Logic 
  .global_re(uni_read), 
  
  // Aligned Data 
  .aligned_data(W4_N4_Out), 

  // FIFO Status 
  .fifo_empty_top(w4empty), 
  .fifo_full_top(w4full)
  
);

lane_reuse_demux lrd_W4_N4(
    // Global Clock and Reset 
    .clk(clk), 
    .resetn(resetn), 

    // Datalane  
    .datalane(W4_N4_Out),

    // Select Lane 
    .sel0x(sel3t), 
    .sel1x(sel7t), 

    // Output lanes 
    .outlane1(w4_data), 
    .outlane2(n4_data)
); 


endmodule 