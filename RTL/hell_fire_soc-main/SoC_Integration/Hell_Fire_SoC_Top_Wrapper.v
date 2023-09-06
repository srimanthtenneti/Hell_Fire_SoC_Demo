// ************************************************************
// Design : Hell Fire SoC Top 
// Author: Srimanth Tenneti 
// Date: 27th August 2023 
// Version : 0.02
// ************************************************************

module Hell_Fire_SoC_Top_Wrapper_V3 #(parameter W = 32)(
   // Global Clock and Reset 
   input wire clk, 
   input wire reset, 

   // LED Out 
   output wire [3:0] LED, 

   // Debug 
   input wire  TDI, 
   input wire  TCK, 
   input wire  TMS, 
   output wire TDO
);

// Clocking 
wire fclk; // Free Running Clock 
assign fclk = clk; 

wire resetn = reset; 

// MUX2CPU Response and Data
wire mux2cpu_hready; 
wire [W - 1 : 0] mux2cpu_hrdata; 

// Mux Select 
wire [1:0] muxsel; 

// Peripheral Select 
wire hsel_memory; 
wire hsel_gpio; 
wire hsel_nomap;
wire hsel_array; 

// Peripheral HREADY 
wire hready_memory; 
wire hready_gpio; 
wire hready_array; 
wire hready_nomap; 

// Peripheral Data Connections 
wire [W - 1  : 0] hrdata_memory; 
wire [W - 1  : 0] hrdata_gpio; 
wire [W - 1  : 0] hrdata_array; 
wire [W - 1  : 0] hrdata_nomap; 

// Side Bank Signals 
wire lockup; 
wire lockup_reset_req; 
wire sys_reset_req; 
wire txev; 
wire sleeping; 
wire [31:0] irq; 

// Interrupt Signals 
assign irq = 0; 

// Reset Sync 
reg [4:0] reset_sync_reg; 

always @ (posedge fclk or negedge resetn) begin
   if (~resetn) begin
      reset_sync_reg <= 0; 
   end
   else 
     begin
       reset_sync_reg[3:0] <= {reset_sync_reg[2:0], 1'b1}; 
       reset_sync_reg[4] <= reset_sync_reg[2] & ~(sys_reset_req); 
     end
end

// CPU AHB-Lite Bus 

wire hresetn = reset_sync_reg[4]; 
wire hmastlock_soc; 
wire hwrite_soc; 

wire [1:0] htrans_soc; 

wire [2:0] hsize_soc; 
wire [2:0] hburst_soc; 

wire [3:0] hprot_soc; 

wire [W - 1 : 0] haddr_soc; 
wire [W - 1 : 0] hwdata_soc; 

wire [1:0] hresp_soc = 2'b00; // No Error Response
wire exeresp_soc = 0; 


wire          dbg_tdo;             
wire          dbg_tdo_nen; 

wire          dbg_swdo;                 
wire          dbg_swdo_en; 

wire          dbg_jtag_nsw;             
wire          dbg_swo;  

wire          tdo_enable     = !dbg_tdo_nen | !dbg_jtag_nsw;

wire          tdo_tms        = dbg_jtag_nsw         ? dbg_tdo    : dbg_swo;
assign        TMS            = dbg_swdo_en          ? dbg_swdo   : 1'bz;
assign        TDO            = tdo_enable           ? tdo_tms    : 1'bz;


// Debug Power Controller 
wire cdbgpwrupack, cdbgpwrupreq; 
assign cdbgpwrupack = cdbgpwrupreq; 

CORTEXM0INTEGRATION cpu0(

     .FCLK(fclk),
     .SCLK(fclk),
     .HCLK(fclk),
     .DCLK(fclk),

     .PORESETn(reset_sync_reg[2]),
     .DBGRESETn(reset_sync_reg[3]),
     .HRESETn(hresetn),

     .SWCLKTCK(TCK),
     .nTRST(1'b1),

     // AHB-LITE MASTER PORT
     .HADDR(haddr_soc),
     .HBURST(hburst_soc),
     .HMASTLOCK(hmastlock_soc),
     .HPROT(hprot_soc),
     .HSIZE(hsize_soc),
     .HTRANS(htrans_soc),
     .HWDATA(hwdata_soc),
     .HWRITE(hwrite_soc),
     .HRDATA(mux2cpu_hrdata),
     .HREADY(mux2cpu_hready),
     .HRESP(hresp_soc),
     .HMASTER(),

     // CODE SEQUENTIALITY AND SPECULATION
     .CODENSEQ(),
     .CODEHINTDE(),
     .SPECHTRANS(),
     
     // DEBUG
     .SWDITMS(TMS),
     .TDI(TDI),
     .SWDO(dbg_swdo),
     .SWDOEN(dbg_swdo_en),
     .TDO(dbg_tdo),
     .nTDOEN(dbg_tdo_nen),
     .DBGRESTART(1'b0),
     .DBGRESTARTED(),
     .EDBGRQ(1'b0),
     .HALTED(),

     // MISC
     .NMI(1'b0),
     .IRQ(irq),
     .TXEV(),
     .RXEV(1'b0),
     .LOCKUP(lockup),
     .SYSRESETREQ(sys_reset_req),
     .STCALIB({1'b1, 1'b0, 24'h007A11F}),
     .STCLKEN(1'b0),
     .IRQLATENCY(8'h00),
     .ECOREVNUM(28'h0), 

     // POWER MANAGEMENT
     .GATEHCLK(),
     .SLEEPING(),
     .SLEEPDEEP(),
     .WAKEUP(),
     .WICSENSE(),
     .SLEEPHOLDREQn(1'b1),
     .SLEEPHOLDACKn(),
     .WICENREQ(1'b0),
     .WICENACK(),
     .CDBGPWRUPREQ(cdbgpwrupreq),
     .CDBGPWRUPACK(cdbgpwrupack),
     // SCAN IO
     .SE(1'b0),
     .RSTBYPASS(1'b0)
);

AHBDCD Peripheral_Decoder (
    // Input Address
   .HADDR(haddr_soc), 
    // Peripheral Select 
   .hsel_s0(hsel_memory), 
   .hsel_s1(hsel_gpio), 
   .hsel_s2(hsel_array), 
   .hsel_s3(),
   .hsel_nomap(hsel_nomap),
    // Mux Select  
   .mux_sel_out(muxsel)  
); 

AHBMUX Peripheral_MUX(
  // Clock and Reset 
  . HCLK(fclk), 
  . HRESETn(hresetn), 
  // Mux Select Genenrated by decoder 
  .mux_sel(muxsel), 
  // HRDATA Slaves 
  .hrdata_s0(hrdata_memory), 
  .hrdata_s1(hrdata_gpio), 
  .hrdata_s2(hrdata_array), 
  .hrdata_s3(), 
  .hrdata_nomap(hrdata_nomap), 
  // HREADY Slaves 
  . hready_s0(hready_memory), 
  . hready_s1(hready_gpio), 
  . hready_s2(hready_array), 
  . hready_s3(), 
  . hready_nomap(hready_nomap), 
  // To Master 
  .hrdata_out(mux2cpu_hrdata), 
  .hready_out(mux2cpu_hready)

); 

// ***************************************************
//     AHB Peripherals 
// ***************************************************


// SRAM - Device0
AHB2SRAM SRAM_Bank0 (
    // Clock and Reset
    .HCLK(fclk), 
    .HRESETn(hresetn), 
    // Address and Control 
    .HSEL(hsel_memory), 
    .HWRITE(hwrite_soc), 
    .HREADY(mux2cpu_hready), 
    .HMASTLOCK(), 
    .HADDR(haddr_soc), 
    .HTRANS(htrans_soc), 
    .HSIZE(hsize_soc), 
    .HBURST(hburst_soc), 
    // Data 
    .HWDATA(hwdata_soc), 
    .HRDATA(hrdata_memory), 
    // Response 
    .HRESP(), 
    .HREADYOUT(hready_memory)
); 

// GPIO Bank - Device1
AHB2IO IO_Bank0 (
    // Global Clock and Reset
    .HCLK(fclk), 
    .HRESETn(hresetn), 
    // AHB Control Signals 
    .HSEL(hsel_gpio), 
    .HWRITE(hwrite_soc), 
    .HREADY(mux2cpu_hready), 
    .HMASTLOCK(), 
    // Address and Data  
    .HADDR(haddr_soc), 
    .HWDATA(hwdata_soc), 
    // Transaction Control 
    .HTRANS(htrans_soc), 
    .HBURST(hburst_soc), 
    .HSIZE(hsize_soc), 
    // Output and Transfer Response
    .HRESP(), 
    .HREADYOUT(hready_gpio), 
    .HRDATA(hrdata_gpio), 
    // Peripheral Control 
    .LED(LED)
);

// Accelerator - Device2
AHB_Soc_Interface MMA0 (
    // Global Clock and Reset
    .HCLK(fclk), 
    .HRESETn(hresetn), 
    // Control Signals 
    .HSEL(hsel_array), 
    .HWRITE(hwrite_soc), 
    .HMASTLOCK(hmastlock_soc),  
    .HTRANS(htrans_soc), 
    .HBURST(hburst_soc), 
    .HSIZE(hsize_soc), 
    // Address and Data  
    .HWDATA(hwdata_soc), 
    // Response
    .HRDATA(hrdata_array), // Done
    .HREADYOUT(hready_array),    // Done
    .HRESP()   // Done
 
);

endmodule



