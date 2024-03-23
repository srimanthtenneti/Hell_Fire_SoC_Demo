// **************************************************************
// Design : Data Delivery Subsystem  - Switching System 
// Author: Srimanth Tenneti 
// Date: 19th July 2023 
// Version : 0.05
// **************************************************************

module Data_Switch #(parameter W = 32) (
   
   // Global Clock and Reset
   input clk, 
   input resetn, 
   input select, 
  
   // Payload 
   input [W - 1 : 0] data, 
   
   // RPTR 
   input [2:0] rptr_in,

   // Alignment FIFO Handshake Signals 

   // West Lane
   input wire w1_full, 
   input wire w1_empty,

   input wire w2_full, 
   input wire w2_empty,

   input wire w3_full, 
   input wire w3_empty,

   input wire w4_full, 
   input wire w4_empty,

   // North Lane 
   input wire n1_full, 
   input wire n1_empty, 

   input wire n2_full, 
   input wire n2_empty,

   input wire n3_full, 
   input wire n3_empty,

   input wire n4_full, 
   input wire n4_empty,


   // Data Lanes  -> Done
   output wire [W - 1 : 0] dataout0,
   output wire [W - 1 : 0] dataout1,
   output wire [W - 1 : 0] dataout2,
   output wire [W - 1 : 0] dataout3,
   
   // Lane Select Signal -> Done 
   output wire sel0, 
   output wire sel1, 
   output wire sel2, 
   output wire sel3, 
   output wire sel4, 
   output wire sel5, 
   output wire sel6, 
   output wire sel7, 

   // Rptr Update -> Done
   output wire re_out_master,

  // Master FIFO N4 Stability 
   output wire n4_full_pos_out, 

   // Unified Read 
   output wire unified_read // -> Done 

);


// Unified Full Logic 
wire ufull; 
wire ufull_trigger; 
reg ufullQ; 


// Unified Empty Logic 
wire uempty; 
wire uempty_trigger; 
reg uemptyQ; 

assign ufull  = ((w1_full && w2_full && w3_full && w4_full) && (n1_full && n2_full && n3_full && n4_full));
assign uempty = ((w1_empty && w2_empty && w3_empty && w4_empty) && (n1_empty && n2_empty && n3_empty && n4_empty));

always @(posedge clk or negedge resetn) begin
    if (~resetn) 
    begin
      ufullQ  <= 0; 
      uemptyQ <= 0; 
    end
    else 
      begin
        ufullQ  <= ufull; 
        uemptyQ <= uempty;
      end
end

// Posedge Detectors for Unified Full and Empty

assign ufull_trigger   = ufull  && ~ufullQ; 
assign uempty_trigger  = uempty && ~uemptyQ;

reg unified_read_Q; 

// Unified Read Logic 
always @ (posedge clk or negedge resetn) begin 
   if (~resetn) 
     unified_read_Q <= 0; 
   else 
     begin
      if (ufull_trigger)
        unified_read_Q <= 1; 
      else 
        if (uempty_trigger) 
          unified_read_Q <= 0; 
     end
end

// Unified Read Output Assignment 
assign unified_read = unified_read_Q; 

reg [W - 1 : 0] dataout0Q; 
reg [W - 1 : 0] dataout1Q; 
reg [W - 1 : 0] dataout2Q; 
reg [W - 1 : 0] dataout3Q; 


reg sel0Q; 
reg sel1Q;
reg sel2Q;
reg sel3Q;
reg sel4Q;
reg sel5Q;
reg sel6Q;
reg sel7Q;

// Pipe Addition 
reg [2:0] rptr_in_pipe; 

always @ (posedge clk) begin
   rptr_in_pipe <= rptr_in; 
end

// Data Decoding 
always @ (rptr_in_pipe or resetn or select) begin // Added Data to Sense List 
  if (~resetn) 
    begin
      dataout0Q = 0; 
      dataout1Q = 0; 
      dataout2Q = 0; 
      dataout3Q = 0; 
      sel0Q = 0; 
      sel1Q = 0;
      sel2Q = 0;
      sel3Q = 0;
      sel4Q = 0;
      sel5Q = 0;
      sel6Q = 0;
      sel7Q = 0;
    end
  else 
    begin
      if (select) 
        begin
          case (rptr_in_pipe) 
            // West 1
            3'b000 : begin
                dataout0Q = data; 
                dataout1Q = 0; 
                dataout2Q = 0; 
                dataout3Q = 0; 
                sel0Q = 1; 
                sel1Q = 0;
                sel2Q = 0;
                sel3Q = 0;
                sel4Q = 0;
                sel5Q = 0;
                sel6Q = 0;
                sel7Q = 0;    
            end
            // West 2
            3'b001 : begin
                dataout0Q = 0; 
                dataout1Q = data; 
                dataout2Q = 0; 
                dataout3Q = 0; 
                sel0Q = 0; 
                sel1Q = 1;
                sel2Q = 0;
                sel3Q = 0;
                sel4Q = 0;
                sel5Q = 0;
                sel6Q = 0;
                sel7Q = 0;  
            end  
            // West 3
            3'b010 : begin
                dataout0Q = 0; 
                dataout1Q = 0; 
                dataout2Q = data; 
                dataout3Q = 0; 
                sel0Q = 0; 
                sel1Q = 0;
                sel2Q = 1;
                sel3Q = 0;
                sel4Q = 0;
                sel5Q = 0;
                sel6Q = 0;
                sel7Q = 0;  
            end  
            // West 4
            3'b011 : begin
                dataout0Q = 0; 
                dataout1Q = 0; 
                dataout2Q = 0; 
                dataout3Q = data;  
                sel0Q = 0; 
                sel1Q = 0;
                sel2Q = 0;
                sel3Q = 1;
                sel4Q = 0;
                sel5Q = 0;
                sel6Q = 0;
                sel7Q = 0;  
            end 
            // North 1 
            3'b100 : begin
                dataout0Q = data; 
                dataout1Q = 0; 
                dataout2Q = 0; 
                dataout3Q = 0; 
                sel0Q = 0; 
                sel1Q = 0;
                sel2Q = 0;
                sel3Q = 0;
                sel4Q = 1;
                sel5Q = 0;
                sel6Q = 0;
                sel7Q = 0;  
            end  
            // North 2 
            3'b101 : begin
                dataout0Q = 0; 
                dataout1Q = data; 
                dataout2Q = 0; 
                dataout3Q = 0; 
                sel0Q = 0; 
                sel1Q = 0;
                sel2Q = 0;
                sel3Q = 0;
                sel4Q = 0;
                sel5Q = 1;
                sel6Q = 0;
                sel7Q = 0;  
            end  
            // North 3 
            3'b110 : begin
                dataout0Q = 0; 
                dataout1Q = 0; 
                dataout2Q = data; 
                dataout3Q = 0; 
                sel0Q = 0; 
                sel1Q = 0;
                sel2Q = 0;
                sel3Q = 0;
                sel4Q = 0;
                sel5Q = 0;
                sel6Q = 1;
                sel7Q = 0;  
            end  
            // North 4
            3'b111 : begin
                dataout0Q = 0; 
                dataout1Q = 0; 
                dataout2Q = 0; 
                dataout3Q = data; 
                sel0Q = 0; 
                sel1Q = 0;
                sel2Q = 0;
                sel3Q = 0;
                sel4Q = 0;
                sel5Q = 0;
                sel6Q = 0;
                sel7Q = 1;  
            end  
          endcase
        end
      else 
        begin
                dataout0Q = 0; 
                dataout1Q = 0; 
                dataout2Q = 0; 
                dataout3Q = 0; 
                sel0Q = 0; 
                sel1Q = 0;
                sel2Q = 0;
                sel3Q = 0;
                sel4Q = 0;
                sel5Q = 0;
                sel6Q = 0;
                sel7Q = 0;  
        end

    end
end

// Output Assignment 

assign dataout0 = dataout0Q; 
assign dataout1 = dataout1Q; 
assign dataout2 = dataout2Q; 
assign dataout3 = dataout3Q; 

assign sel0 = sel0Q; 
assign sel1 = sel1Q; 
assign sel2 = sel2Q; 
assign sel3 = sel3Q; 
assign sel4 = sel4Q; 
assign sel5 = sel5Q; 
assign sel6 = sel6Q; 
assign sel7 = sel7Q; 

wire w1_full_pos; 
wire w2_full_pos; 
wire w3_full_pos; 
wire w4_full_pos; 

wire n1_full_pos; 
wire n2_full_pos; 
wire n3_full_pos; 
wire n4_full_pos; 

// West Full Posedge Detectors 

Pos_detector w1_full_i0 (
    .clk(clk), 
    .resetn(resetn), 
    .signal(w1_full), 
    .edge_(w1_full_pos)
); 

Pos_detector w2_full_i0 (
    .clk(clk), 
    .resetn(resetn), 
    .signal(w2_full), 
    .edge_(w2_full_pos)
); 

Pos_detector w3_full_i0 (
    .clk(clk), 
    .resetn(resetn), 
    .signal(w3_full), 
    .edge_(w3_full_pos)
); 

Pos_detector w4_full_i0 (
    .clk(clk), 
    .resetn(resetn), 
    .signal(w4_full), 
    .edge_(w4_full_pos)
);

// North Full Posedge Detectors 

Pos_detector n1_full_i0 (
    .clk(clk), 
    .resetn(resetn), 
    .signal(n1_full), 
    .edge_(n1_full_pos)
); 

Pos_detector n2_full_i0 (
    .clk(clk), 
    .resetn(resetn), 
    .signal(n2_full), 
    .edge_(n2_full_pos)
);

Pos_detector n3_full_i0 (
    .clk(clk), 
    .resetn(resetn), 
    .signal(n3_full), 
    .edge_(n3_full_pos)
);

Pos_detector n4_full_i0 (
    .clk(clk), 
    .resetn(resetn), 
    .signal(n4_full), 
    .edge_(n4_full_pos)
);


wire re_;
reg reQ; 

assign re_ = ((w1_full_pos | w2_full_pos | w3_full_pos | w4_full_pos) | (n1_full_pos | n2_full_pos | n3_full_pos | n4_full_pos)); 

always @(posedge clk or negedge resetn) begin
    if (~resetn) 
      reQ <= 0; 
    else 
      begin
         if (re_) reQ <= 1; 
         else reQ <= 0; 
      end 
end

assign re_out_master = reQ; 
assign n4_full_pos_out = n4_full_pos; 

endmodule