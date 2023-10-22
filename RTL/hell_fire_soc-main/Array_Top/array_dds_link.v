// **************************************************************
// Design : Systolic_Array
// Author: Sindhura Maddineni 
// Date: 1th July 2023 
// Version : 0.01
// **************************************************************

module systolic_array_4_by_4#(parameter data_size=8)(clk,resetn,a1,a2,a3,a4,b1,b2,b3,b4,
          c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
           c11,c12,c13,c14,c15,c16);

  input wire clk,resetn;
  input wire [data_size-1:0] a1,a2,a3,a4,b1,b2,b3,b4;
  output wire [2*data_size:0] c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,
  c11,c12,c13,c14,c15,c16;
 
  wire [data_size-1:0] a12,a23,a34,a56,a67,a78,a910,a1011,a1112,
  a1314,a1415,a1516,b15,b26,b37,b48,b59,b610,
  b711,b812,b913,b1014,b1115,b1216;
 
   
  pe pe1 (.clk(clk), .resetn(resetn), .in_a(a1), .in_b(b1), .out_a(a12), .out_b(b15), .out_c(c1));
  pe pe2 (.clk(clk), .resetn(resetn), .in_a(a12), .in_b(b2), .out_a(a23), .out_b(b26), .out_c(c2));
  pe pe3 (.clk(clk), .resetn(resetn), .in_a(a23), .in_b(b3), .out_a(a34), .out_b(b37), .out_c(c3));
  pe pe4 (.clk(clk), .resetn(resetn), .in_a(a34), .in_b(b4), .out_a(), .out_b(b48), .out_c(c4));
  pe pe5 (.clk(clk), .resetn(resetn), .in_a(a2), .in_b(b15), .out_a(a56), .out_b(b59), .out_c(c5));
  pe pe6 (.clk(clk), .resetn(resetn), .in_a(a56), .in_b(b26), .out_a(a67), .out_b(b610), .out_c(c6));
  pe pe7 (.clk(clk), .resetn(resetn), .in_a(a67), .in_b(b37), .out_a(a78), .out_b(b711), .out_c(c7));
  pe pe8 (.clk(clk), .resetn(resetn), .in_a(a78), .in_b(b48), .out_a(), .out_b(b812), .out_c(c8));
  pe pe9 (.clk(clk), .resetn(resetn), .in_a(a3), .in_b(b59), .out_a(a910), .out_b(b913), .out_c(c9));
  pe pe10 (.clk(clk), .resetn(resetn), .in_a(a910), .in_b(b610), .out_a(a1011), .out_b(b1014), .out_c(c10));
  pe pe11 (.clk(clk), .resetn(resetn), .in_a(a1011), .in_b(b711), .out_a(a1112), .out_b(b1115), .out_c(c11));
  pe pe12 (.clk(clk), .resetn(resetn), .in_a(a1112), .in_b(b812), .out_a(), .out_b(b1216), .out_c(c12));
  pe pe13 (.clk(clk), .resetn(resetn), .in_a(a4), .in_b(b913), .out_a(a1314), .out_b(), .out_c(c13));
  pe pe14 (.clk(clk), .resetn(resetn), .in_a(a1314), .in_b(b1014), .out_a(a1415), .out_b(), .out_c(c14));
  pe pe15 (.clk(clk), .resetn(resetn), .in_a(a1415), .in_b(b1115), .out_a(a1516), .out_b(), .out_c(c15));
  pe pe16 (.clk(clk), .resetn(resetn), .in_a(a1516), .in_b(b1216), .out_a(), .out_b(), .out_c(c16));


endmodule

module pe#(parameter data_size = 8)(clk,resetn,in_a,in_b,out_a,out_b,out_c);

 input wire resetn,clk;
 input wire [data_size-1:0] in_a,in_b;
 output [2*data_size:0] out_c;
 output [data_size-1:0] out_a,out_b;
  
  reg [2 * data_size : 0] outC;
  reg [data_size-1:0] outA,outB;  

 always @(posedge clk or negedge resetn)begin
    if(~resetn) begin
      outA<=0;
      outB<=0;
      outC<=0;
    end
    else begin  
      outC<=outC+in_a*in_b;
      outA<=in_a;
      outB<=in_b;
    end
 end
  
  assign out_a = outA;
  assign out_b = outB;
  assign out_c = outC;
 
endmodule

// **************************************************************
// Design : Array and Data Delivery Subsystem Link 
// Author: Srimanth Tenneti 
// Date: 19th July 2023 
// Version : 0.07
// **************************************************************

module array_dds_link (
    
    input wire clk,
    input wire resetn,

    input we, 

    input [31:0] datain, 

    output [16:0] fc1,
    output [16:0] fc2, 
    output [16:0] fc3, 
    output [16:0] fc4, 
    output [16:0] fc5, 
    output [16:0] fc6, 
    output [16:0] fc7, 
    output [16:0] fc8, 

    output [16:0] fc9, 
    output [16:0] fc10,  
    output [16:0] fc11, 
    output [16:0] fc12, 
    output [16:0] fc13, 
    output [16:0] fc14, 
    output [16:0] fc15, 
    output [16:0] fc16, 
    output global_read_enable, 
    output master_full, 
    output master_empty
    
 
);

    wire [7:0] w1_data;
    wire [7:0] w2_data;
    wire [7:0] w3_data;
    wire [7:0] w4_data; 

    wire [7:0] n1_data;
    wire [7:0] n2_data;
    wire [7:0] n3_data;
    wire [7:0] n4_data;

    data_del_master_interface_top data_delivery_subsystem_MIF_LINK (
     
     // Global Clock and Reset
     .clk(clk), 
     .resetn(resetn), 
     
     // Payload 
     .data(datain),

     .we(we),
     
     // Aligned Data 
     .w1_data(w1_data),  
     .w2_data(w2_data),  
     .w3_data(w3_data),  
     .w4_data(w4_data), 

     .n1_data(n1_data), 
     .n2_data(n2_data), 
     .n3_data(n3_data), 
     .n4_data(n4_data), 
     .global_read_enable(global_read_enable), 
     .master_full(master_full), 
     .master_empty(master_empty)

);

systolic_array_4_by_4  systolic_array_interface_0x1 (
.clk(clk), 
.resetn(resetn), 
.a1(w1_data),
.a2(w2_data),
.a3(w3_data),
.a4(w4_data),
.b1(n1_data),
.b2(n2_data),
.b3(n3_data),
.b4(n4_data), 
.c1(fc1),
.c2(fc2), 
.c3(fc3),
.c4(fc4),
.c5(fc5),
.c6(fc6), 
.c7(fc7),
.c8(fc8), 
.c9(fc9),
.c10(fc10), 
.c11(fc11),
.c12(fc12), 
.c13(fc13),
.c14(fc14), 
.c15(fc15),
.c16(fc16) 
);

endmodule