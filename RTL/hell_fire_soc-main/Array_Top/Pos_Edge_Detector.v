module Pos_detector (
    input wire clk, 
    input wire resetn, 
    input wire signal, 
    output wire edge_
); 

reg signalQ; 

always @ (posedge clk or negedge resetn) begin 
   if (~resetn) 
     signalQ <= 0; 
   else 
     signalQ <= signal; 
end

assign edge_ = (signal && ~signalQ); 
 
endmodule