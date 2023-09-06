/*
  Design: AHB MUX
  Date : 21 June 2023 
  Author : Srimanth Tenneti 
  Description : Peripheral Response Multiplexor
*/

module AHBMUX #(parameter W = 32)(
  
  // Clock and Reset 
  input HCLK, 
  input HRESETn, 
  
  // Mux Select Genenrated by decoder 
  input wire [1:0] mux_sel, 
  
  // HRDATA Slaves 
  input [W-1 : 0] hrdata_s0, 
  input [W-1 : 0] hrdata_s1, 
  input [W-1 : 0] hrdata_s2, 
  input [W-1 : 0] hrdata_s3, 
  input [W-1 : 0] hrdata_nomap, 
  
  // HREADY Slaves 
  input hready_s0, 
  input hready_s1, 
  input hready_s2, 
  input hready_s3, 
  input hready_nomap, 
  
  // To Master 
  output wire [W-1:0] hrdata_out, 
  output wire hready_out
); 
  
  reg [W-1 : 0] hrdata; 
  reg hready; 
  
  reg [1:0] mux_selQ, mux_selQ1; 
  
  // Address Phase Data Storage
  always @ (posedge HCLK or negedge HRESETn) 
    begin
      if (~HRESETn) 
        begin
           mux_selQ <= 0; 
           mux_selQ1 <= 0; 
        end
      else 
      begin
                mux_selQ1 <= mux_sel; 
                mux_selQ  <= mux_selQ1;
      end
    end
  
  always @ * 
    begin 
      case(mux_selQ) 
         2'b00 : begin // MEMORY
            hrdata = hrdata_s0; 
            hready = hready_s0; 
         end
        2'b01 : begin // GPIO
           hrdata = hrdata_s1; 
           hready = hready_s1; 
        end
        2'b10 : begin // Accelerator
           hrdata = hrdata_s2; 
           hready = hready_s2; 
        end
        default : begin // NOMAP
            hrdata = hrdata_nomap; 
            hready = hready_nomap; 
        end 
      endcase
    end 

  
  assign hrdata_out = hrdata; 
  assign hready_out = hready; 
  
endmodule 