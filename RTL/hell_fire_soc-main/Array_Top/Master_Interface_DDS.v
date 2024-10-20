// **************************************************************
// Design : Data Delivery System and Master Inferace FIFO
// Author: Srimanth Tenneti 
// Date: 19th July 2023 
// Version : 0.03
// **************************************************************

module Circular_FIFO_Master #(parameter W = 32, D = 8)(
  // Global Clock and Reset
    input wire clk, 
    input wire resetn,
    
  // Write Enable
    input wire we,

  // Pointer Update 
    input wire rptr_incr,  

  // Data 
    input wire [W - 1 : 0] data,

    // To ensure Read Enable Stability for North4
    input wire n4_full_edge, 

  // Master FIFO Full Status 
    output wire fifo_full, 
  // Master FIFO Empty Status 
    output wire fifo_empty,

  // Master FIFO Dataout
    output wire [W - 1 : 0] dataout, 

  // Master Read Pointer Out
    output wire [2:0] rptr_out, 

  // Data Delivery Subsystem Enable
    output wire select
); 

reg [$clog2(D)  : 0] wptr, rptr; 
wire [$clog2(D)  : 0] nwptr, nrptr;

reg re; 

reg [W - 1 : 0] cfifo [D - 1 : 0]; 

// Pointer Update Logic 
always @ (posedge clk or negedge resetn) 
begin
  if (~resetn) 
   begin
     wptr <= 0; 
     rptr <= 0; 
   end 
   else 
    begin
      wptr <= nwptr; 
      rptr <= nrptr; 
    end
end


wire write_en; 
wire read_en; 

  
wire fifo_ctrl; 
wire fifo_em; 
  
// FIFO Status Signals 
assign fifo_em = (wptr == rptr); 
assign fifo_ctrl  = ((wptr == 4'd8) && (rptr == 0));
  
// Single Cycle Delayed Full and Empty 
// For Reading and Writing to all available locations 

reg fifo_full_pipe; 
reg fifo_empty_pipe; 

  always @ (posedge clk or negedge resetn)
    begin
      if (~resetn)
        begin
         fifo_full_pipe <= 0; 
         fifo_empty_pipe <= 0; 
        end
       else 
         begin
         fifo_full_pipe <= fifo_ctrl; 
         fifo_empty_pipe <= fifo_em; 
         end
    end
  
assign fifo_full = fifo_full_pipe; 
assign fifo_empty = fifo_empty_pipe;


wire full_pos, empty_pos; 

Pos_detector master_full (
    .clk(clk), 
    .resetn(resetn), 
    .signal(fifo_full), // No delay
    .edge_(full_pos)
); 

Pos_detector master_empty (
    .clk(clk), 
    .resetn(resetn), 
    .signal(fifo_empty), // No delay
    .edge_(empty_pos)
); 

reg re1; 

// Modified Read Enable Logic
always @ (posedge clk or negedge resetn) begin
   if (~resetn) 
       re1 <= 0; 
   else 
       begin
         if (full_pos) 
           re1 <= 1; 
         if (empty_pos) 
           begin
              if (n4_full_edge) // Ensures N4 Data Setup Stability 
                re1 <= 0; 
              else 
               begin
                re1 <= re1;
               end 
           end 
       end 
end

// Single Cycle Delay for RE
always @ (posedge clk or negedge resetn) begin
  if (~resetn) 
    re <= 0; 
  else 
    re <= re1; 
end

// FIFO Write Logic 
assign write_en = (~fifo_full && we); 

// Read Pointer Update 
assign read_en  = (~fifo_empty && rptr_incr);  

// FIFO Pointer Update
assign nwptr = (~fifo_ctrl && we) ? wptr + 1 : wptr; 
assign nrptr = (read_en && rptr <= 4'd7)  ? rptr + 1 : rptr; 

// FIFO Write
always @ (posedge clk) 
    begin
      if (write_en)
       cfifo[wptr] <= data; 
    end


// FIFO Read Data Out Logic
reg [W-1 : 0] dout; 
  
  always @ (posedge clk or negedge resetn) 
    begin
      if (~resetn) 
        dout <= 0; 
      else 
        begin
          if (re1) // Enable Isolation 
            dout <= cfifo[rptr]; 
           else 
             dout <= dout; 
        end
    end



// FIFO Read
  assign dataout = dout;
  assign rptr_out = rptr; 
  assign select = re; // Export Delayed Data


endmodule




module data_del_master_interface_top #(parameter W = 32)(
    // Clock and Reset
    input wire clk, 
    input wire resetn, 
    // Write Enable
    input wire we, 
    // Input Data
    input wire [W - 1 : 0] data, 
    // Sequenced Data
    output wire [7:0] w1_data,  
    output wire [7:0] w2_data,  
    output wire [7:0] w3_data,  
    output wire [7:0] w4_data, 

    output wire [7:0] n1_data, 
    output wire [7:0] n2_data, 
    output wire [7:0] n3_data, 
    output wire [7:0] n4_data, 

    output wire global_read_enable,  // Addition 
    output wire master_full, 
    output wire master_empty 
); 
 
 wire [2:0] rptr_conn; 
 
 wire full_conn, empty_conn; 

 wire [W - 1 : 0] data_link_conn; 

 wire select, n4_full_pos_out; 

 Circular_FIFO_Master master_interface_fifo_top(

    .clk(clk), 
    .resetn(resetn), 

    .we(we),

    // Pointer Increment Control 
    .rptr_incr(read_enable_conn),  

    // N4 Select Stability Signal 
    .n4_full_edge(n4_full_pos_out), 

    .data(data), 

    .fifo_full(full_conn), 
    .fifo_empty(empty_conn), 

    .dataout(data_link_conn),

    .rptr_out(rptr_conn), 

    .select(select)
    
); 

assign master_empty =  empty_conn; 
assign master_full  = full_conn; 

Data_Delivery_Top data_delivery_subsystem0 (
     
     // Global Clock and Reset
     .clk(clk), 
     .resetn(resetn), 
     
     // Master Full and Empty Edges 
     .select(select), 

     // Payload 
     .data(data_link_conn),
     
     // Master Read Pointer Input  
     .rptr_in(rptr_conn), 
     
     // Aligned Data 
     .w1_data(w1_data),  
     .w2_data(w2_data),  
     .w3_data(w3_data),  
     .w4_data(w4_data), 

     .n1_data(n1_data), 
     .n2_data(n2_data), 
     .n3_data(n3_data), 
     .n4_data(n4_data), 

     // Master Pointer Update 
     .master_rptr_en(read_enable_conn), 
     .n4_full_pos_out(n4_full_pos_out), 
     .gure(global_read_enable)
);


endmodule 