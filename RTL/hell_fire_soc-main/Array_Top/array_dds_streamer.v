// **************************************************************
// Design : IP Stream Top
// Author: Srimanth Tenneti 
// Date: 20th August 2023 
// Version : 0.02
// **************************************************************

module IP_Stream_Top #(parameter W = 32) (
    input wire clk, 
    input wire resetn,
    input wire accResetn,  
    input wire we, 
    input wire [W-1:0] datain, 
    output wire [W-1:0] dataout, 
    output wire valid, 
    output wire master_full, 
    output wire master_empty
); 

    wire [16:0] fc1;
    wire [16:0] fc2;
    wire [16:0] fc3;
    wire [16:0] fc4;
    wire [16:0] fc5;
    wire [16:0] fc6;
    wire [16:0] fc7;
    wire [16:0] fc8;
    wire [16:0] fc9;
    wire [16:0] fc10;
    wire [16:0] fc11;
    wire [16:0] fc12;
    wire [16:0] fc13;
    wire [16:0] fc14;
    wire [16:0] fc15;
    wire [16:0] fc16;

    wire global_read_enable;

serializier ser0_array(

   // Clock and Reset
   .clk(clk), 
   .resetn(resetn), 

   // Isolated Data Load Signal 
   .load_data(global_read_enable), 

   // Array Feed
   .fc1(fc1),
   .fc2(fc2),
   .fc3(fc3),
   .fc4(fc4),
   .fc5(fc5),
   .fc6(fc6),
   .fc7(fc7),
   .fc8(fc8),
   .fc9(fc9),
   .fc10(fc10), 
   .fc11(fc11),
   .fc12(fc12),
   .fc13(fc13),
   .fc14(fc14),
   .fc15(fc15),
   .fc16(fc16),
 
   // Serialized Dataout
   .dataout(dataout), 

   // Stream Done Signal 
   .valid(valid)
);

 array_dds_link link0 (
    
   .clk(clk),
   .resetn(resetn),
   .accResetn(accResetn),

    .we(we), 

    .datain(datain), 

   .fc1(fc1),
   .fc2(fc2),
   .fc3(fc3),
   .fc4(fc4),
   .fc5(fc5),
   .fc6(fc6),
   .fc7(fc7),
   .fc8(fc8),
   .fc9(fc9),
   .fc10(fc10), 
   .fc11(fc11),
   .fc12(fc12),
   .fc13(fc13),
   .fc14(fc14),
   .fc15(fc15),
   .fc16(fc16),
   .global_read_enable(global_read_enable), 
   .master_full(master_full), 
   .master_empty(master_empty)

);

endmodule
