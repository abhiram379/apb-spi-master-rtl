module slave_select_tb();
reg pclk,prst,mstr,spiswai;
reg [1:0]spi;
reg senddata;
reg [11:0]bauddivisor;
wire receivedata;
wire ss;
wire tip;


slave_select DUT(pclk,prst,mstr,spiswai,spi,senddata,bauddivisor,receivedata,ss,tip);
initial
begin
pclk=1'b0;
forever
#5 pclk=~pclk;
end

task initialize;
begin
prst=1'b1;
bauddivisor=12'd0;
spiswai=1'b1;
mstr=1'b0;
senddata=1'b0;
end
endtask

task reset;
begin
@(negedge pclk)
prst=1'b0;
@(negedge pclk)
prst=1'b1;
end
endtask

task stimulus(input [1:0]i, input [11:0]j);
begin
@(negedge pclk)
spi=i;
bauddivisor=j;
mstr=1'b1;
spiswai=1'b0;
senddata=1'b1;
@(negedge pclk)
senddata=1'b0;
end
endtask

initial
begin
initialize;
reset;
stimulus(2'b00,12'd4);
#400;
$finish;
end
endmodule