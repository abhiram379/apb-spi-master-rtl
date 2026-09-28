module top(
input pclk,
input presetn,
input  [2:0]paddr,
input pwrite,
input psel,
input penable,
input[7:0] pwdata,
input miso,
output ss,
output sclk,
output spi_int_req,
output mosi,
output [7:0]prdata,
output pready,
output pslverr);

wire [1:0]spi;
wire spiswai;
wire [2:0]sppr;
wire [2:0]spr;
wire cpol;
wire cpha;
wire miso_receive_sclk;
wire miso_receive_sclk0;
wire mosi_send_sclk;
wire mosi_send_sclk0;
wire [11:0]bauddivisor;
wire mstr;
wire senddata;
wire receivedata;
wire tip;
wire lsbfe;
wire [7:0]data_mosi;
wire [7:0]data_miso;



//Instantiate Baud//
baud baud1(pclk,presetn,spi,spiswai,sppr,spr,cpol,cpha,ss,sclk,miso_receive_sclk,miso_receive_sclk0,mosi_send_sclk,mosi_send_sclk0,bauddivisor);

slave_select slaveselect(pclk,presetn,mstr,spiswai,spi,senddata,bauddivisor,receivedata,ss,tip);

shiftregister shiftregister1(pclk,presetn,ss,senddata,lsbfe,cpha,cpol,miso_receive_sclk,miso_receive_sclk0,mosi_send_sclk,mosi_send_sclk0,data_mosi,miso,receivedata,mosi,data_miso);

apbslaveinterface apbinterfacer(pclk,presetn,paddr,pwrite,psel,penable,pwdata,ss,data_miso,receivedata,tip,prdata,mstr,cpol,cpha,lsbfe,spiswai,sppr,spr,spi_int_req,pready,pslverr,senddata,data_mosi,spi);

endmodule