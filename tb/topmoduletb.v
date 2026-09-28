`timescale 1ns/1ps

module top_tb;

reg pclk;
reg presetn;
reg [3:0] paddr;
reg pwrite;
reg psel;
reg penable;
reg [7:0] pwdata;
reg miso;

wire ss;
wire sclk;
wire spi_int_req;
wire mosi;
wire [7:0] prdata;
wire pready;
wire pslverr;


/////////////////////////////////////////////
// DUT
/////////////////////////////////////////////

top DUT(
.pclk(pclk),
.presetn(presetn),
.paddr(paddr),
.pwrite(pwrite),
.psel(psel),
.penable(penable),
.pwdata(pwdata),
.miso(miso),
.ss(ss),
.sclk(sclk),
.spi_int_req(spi_int_req),
.mosi(mosi),
.prdata(prdata),
.pready(pready),
.pslverr(pslverr)
);


/////////////////////////////////////////////
// Clock generation
/////////////////////////////////////////////

initial
begin
    pclk=0;
    forever #5 pclk=~pclk;
end


/////////////////////////////////////////////
// APB write task
/////////////////////////////////////////////

task apb_write;
input [3:0] addr;
input [7:0] data;

begin

@(posedge pclk);

paddr <= addr;
pwdata <= data;
pwrite <= 1;
psel <= 1;
penable <= 0;

@(posedge pclk);

penable <=1;

@(posedge pclk);

psel<=0;
penable<=0;
pwrite<=1;

$display("WRITE : Addr=%0d Data=%h Time=%0t",
addr,data,$time);

end

endtask


/////////////////////////////////////////////
// APB read task
/////////////////////////////////////////////

task apb_read;
input [3:0] addr;

begin

@(posedge pclk);

paddr<=addr;
pwrite<=0;
psel<=1;
penable<=0;

@(posedge pclk);

penable<=1;

@(posedge pclk);

$display("READ : Addr=%0d Data=%h Time=%0t",
addr,prdata,$time);

psel<=0;
penable<=0;

end

endtask


/////////////////////////////////////////////
// SPI Slave stimulus
/////////////////////////////////////////////

reg [7:0] slave_data=8'b10101010;
integer i=7;

always @(negedge sclk)
begin

if(!ss)
begin
    miso<=slave_data[i];
    i=i-1;
end

end


/////////////////////////////////////////////
// Monitor
/////////////////////////////////////////////

initial
begin

$monitor("T=%0t SS=%b SCLK=%b MOSI=%b MISO=%b PRDATA=%h",
$time,ss,sclk,mosi,miso,prdata);

end


/////////////////////////////////////////////
// Test sequence
/////////////////////////////////////////////

initial
begin

presetn=0;

paddr=0;
pwrite=0;
psel=0;
penable=0;
pwdata=0;
miso=0;

#20;

presetn=1;

/////////////////////////////////////////////
// Write registers
/////////////////////////////////////////////

//CR1
//SPE=1 MSTR=1

apb_write(0,8'b01010000);

//CR2
apb_write(1,8'b00000000);

//BR
apb_write(2,8'b00010001);

//DR
apb_write(5,8'hA5);


/////////////////////////////////////////////
// Read registers
/////////////////////////////////////////////

apb_read(0);

apb_read(1);

apb_read(2);

apb_read(5);


/////////////////////////////////////////////
// Wait for SPI transfer
/////////////////////////////////////////////

@(posedge ss);
@(posedge pclk);


/////////////////////////////////////////////
// Read received data
/////////////////////////////////////////////

apb_read(5);

#500;

$finish;

end

endmodule