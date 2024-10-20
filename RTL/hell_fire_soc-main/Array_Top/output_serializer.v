// **************************************************************
// Design : Output Serializer
// Author: Srimanth Tenneti 
// Date: 19th July 2023 
// Version : 0.03
// **************************************************************

module serializier #(parameter W = 16)(

   // Clock and Reset
   input clk, 
   input resetn, 

   // Isolated Data Load Signal 
   input load_data, 

   // Array Feed
   input [16:0] fc1,
   input [16:0] fc2,
   input [16:0] fc3,
   input [16:0] fc4,
   input [16:0] fc5,
   input [16:0] fc6,
   input [16:0] fc7,
   input [16:0] fc8,
   input [16:0] fc9,
   input [16:0] fc10, 
   input [16:0] fc11,
   input [16:0] fc12,
   input [16:0] fc13,
   input [16:0] fc14,
   input [16:0] fc15,
   input [16:0] fc16,
 
   // Serialized Dataout
   output [31:0] dataout, 

   // Stream Done Signal 
   output valid
);

wire [31:0] packet1; 
wire [31:0] packet2; 
wire [31:0] packet3; 
wire [31:0] packet4; 
wire [31:0] packet5; 
wire [31:0] packet6; 
wire [31:0] packet7; 
wire [31:0] packet8; 

reg load; 
wire loadX; 

always @ (posedge clk or negedge resetn) begin 
   if (~resetn) 
     load <= 0; 
   else 
     begin
       load <= load_data; 
     end
end 

assign loadX = ~load_data && load; 

reg loadXd; 

always @ (posedge clk or negedge resetn) begin
   if (~resetn) 
     loadXd <= 0; 
   else 
     begin
       if (loadX)
         loadXd <= 1; 
     end
end

// Packet Construction 

assign packet1 = (loadXd) ? {fc2[15:0], fc1[15:0]}   : 0; 
assign packet2 = (loadXd) ? {fc4[15:0], fc3[15:0]}   : 0; 
assign packet3 = (loadXd) ? {fc6[15:0], fc5[15:0]}   : 0; 
assign packet4 = (loadXd) ? {fc8[15:0], fc7[15:0]}   : 0; 
assign packet5 = (loadXd) ? {fc10[15:0], fc9[15:0]}  : 0; 
assign packet6 = (loadXd) ? {fc12[15:0], fc11[15:0]} : 0; 
assign packet7 = (loadXd) ? {fc14[15:0], fc13[15:0]} : 0; 
assign packet8 = (loadXd) ? {fc16[15:0], fc15[15:0]} : 0; 


// Stable Data Counter 
reg [2:0] stableCount; 
wire [2:0] nstableCount; 

always @ (posedge clk or negedge resetn) begin
  if (~resetn) 
    stableCount <= 0; 
  else 
    stableCount <= nstableCount; 
end

assign nstableCount = ((stableCount <= 3'd5) && (loadXd)) ? stableCount + 3'd1 : stableCount; 


// Packet Counter 
reg [2:0] count; 
wire [2:0] ncount; 


always @ (posedge clk or negedge resetn) begin
  if (~resetn) 
    count <= 0; 
  else 
    count <= ncount;
end

// Saturates after count 7 -> Needs Reset -> Counts only after 7 cycles of GRE 
assign ncount = (count <= 3'd6 && (stableCount == 3'd6)) ? count + 3'd1 : count; 

// Done Signal Assignment 

wire start, done; 

assign done  = (count == 3'd7); 
assign start = (count == 3'd0) && (stableCount == 3'd5); 

wire start_edge, done_edge; 

Pos_detector  start_pos (
    .clk(clk), 
    .resetn(resetn), 
    .signal(start), 
    .edge_(start_edge)
); 

Pos_detector end_pos (
    .clk(clk), 
    .resetn(resetn), 
    .signal(done), 
    .edge_(done_edge)
); 

reg val; 

always @ (posedge clk or negedge resetn) begin
  if (~resetn) 
    val <= 0; 
  else 
    begin
       if (start_edge) 
        val <= 1; 
       else 
         begin
            if (done_edge) 
               val <= 0; 
            else 
               val <= val; 
         end
    end
end


reg [31:0] data; 

// Packet Stream 
//always @ (val, count, load_data) begin // Changing to *
//    case(count) 
//        3'd0 : data = (val) ? packet1 : 0; 
//        3'd1 : data = (val) ? packet2 : 0; 
//        3'd2 : data = (val) ? packet3 : 0; 
//        3'd3 : data = (val) ? packet4 : 0; 
//        3'd4 : data = (val) ? packet5 : 0; 
//        3'd5 : data = (val) ? packet6 : 0; 
//        3'd6 : data = (val) ? packet7 : 0; 
//        3'd7 : data = (val) ? packet8 : 0; 
//        default : data = 32'h0; 
//    endcase
//end


// Packet Stream 
always @ (*) begin // Changing to *
    case(count) 
        3'd0 : data = (val) ? packet1 : 0; 
        3'd1 : data = (val) ? packet2 : 0; 
        3'd2 : data = (val) ? packet3 : 0; 
        3'd3 : data = (val) ? packet4 : 0; 
        3'd4 : data = (val) ? packet5 : 0; 
        3'd5 : data = (val) ? packet6 : 0; 
        3'd6 : data = (val) ? packet7 : 0; 
        3'd7 : data = (val) ? packet8 : 0; 
    endcase
end

// Data Assignment 

assign dataout = data; 
assign valid = val;

endmodule