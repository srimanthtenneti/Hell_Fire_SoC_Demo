// **************************************************************
// Design : Alignment FIFO
// Author: Srimanth Tenneti 
// Date: 19th July 2023 
// Version : 0.06
// **************************************************************


// @@@@@@@@@@@@@@@@@@@@@@@@@@@ Circular FIFO Logic @@@@@@@@@@@@@@@@@@@@@@@@@@

module Circular_FIFO #(parameter W = 8, D = 7)(
    input wire clk, 
    input wire resetn, 
    input wire we, 
    input wire re, 
    input wire [W - 1 : 0] data, 
    output wire fifo_full, 
    output wire fifo_empty, 
    output wire [W - 1 : 0] dataout
); 

reg [$clog2(D) - 1 : 0] wptr, rptr; 
wire [$clog2(D) - 1 : 0] nwptr, nrptr;

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
  
// FIFO Status Signals 
assign fifo_empty = (wptr == rptr); 
  assign fifo_ctrl  = ((wptr + 3'b01) == rptr); // !!!!!!
  
reg fifo_full_pipe; 

  always @ (posedge clk or negedge resetn)
    begin
      if (~resetn)
         fifo_full_pipe <= 0; 
       else 
         fifo_full_pipe <= fifo_ctrl; 
    end
  
assign fifo_full = fifo_full_pipe; 

// FIFO Write and Read Logic 
assign write_en = (~fifo_full && we); 
assign read_en  = (~fifo_empty && re);  

// FIFO Pointer Update
assign nwptr = (~fifo_ctrl && we && (wptr < 3'd7)) ? wptr + 1 : (wptr == 3'd6) ? 0 : wptr; 
assign nrptr = (read_en && (rptr < 3'd7))  ? rptr + 1 : (rptr == 3'd6) ? 0 :  rptr; 

// FIFO Write
always @ (posedge clk) 
    begin
      if (write_en)
       cfifo[wptr] <= data; 
    end
  
reg [W-1 : 0] dout; 
  
  always @ (posedge clk or negedge resetn) 
    begin
      if (~resetn) 
        dout <= 0; 
      else 
        begin
          if (read_en) 
            dout <= cfifo[rptr]; 
           else 
             dout <= 0; 
        end
    end

// FIFO Read
  assign dataout = dout; 

endmodule