module fprobus 
  #(parameter BRG_BASE = 32'hc000_0000)
(
  //MicroBlaze 接口
    input  logic io_addr_strobe,   // not used
    input  logic io_read_strobe, 
    input  logic io_write_strobe, 
    input  logic [3:0] io_byte_enable, 
    input  logic [31:0] io_address, 
    input  logic [31:0] io_write_data, 
    output logic [31:0] io_read_data, 
    output logic io_ready, 
  //FPro bus
    output logic fp_video_cs,
    output logic fp_mmio_cs, 
    output logic fp_wr,
    output logic fp_rd,
    output logic [20:0]fp_word_addr,
    output logic [1:0]fp_byte_addr,
    output logic [31:0] fp_wr_data ,
    input logic [31:0] fp_rd_data
);
  
  logic mcs_bridge_en;
  logic [29:0] word_addr;
  //原代码中只支持字寻址,我们添加了对字节寻址的支持
  logic [1:0] byte_addr;
  
  assign word_addr = io_address[31:2];
  assign byte_addr = io_address[1:0];
  //当处理器要处理的内存地址为外设时将启用信号拉高
  assign mcs_bridge_en = (io_address[31:24]== BRG_BASE[31:24]);
  //当处理器对外设通信时，通过地址进一步判断是启用哪个系统
  assign fp_video_cs = (mcs_bridge_en && io_address[23] == 1);
  assign fp_mmio_cs = (mcs_bridge_en && io_address[23] == 0);
  assign fp_word_addr = word_addr[20:0];//更高的地址我们不需要
  assign fp_byte_addr = byte_addr;
  //控制信号，为了实现单周期操作，我们拉高io_ready使处理器总是能对总线信号进行处理
  assign fp_wr = io_write_strobe;
  assign fp_rd = io_read_strobe;
  assign io_ready = 1;
  //data线
  assign fp_wr_data = io_write_data;
  assign io_read_data = fp_rd_data;  
endmodule