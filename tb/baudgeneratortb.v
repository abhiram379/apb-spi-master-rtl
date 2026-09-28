module baud_tb();
reg pclk,prst;
reg [1:0]spi;
reg  spiswai;
reg [2:0]sppr,spr;
reg ss,cpol,cpha;
wire sclk;
wire [11:0]bauddivisor;
wire miso_receive_sclk;
wire miso_receive_sclk0;
wire mosi_send_sclk;
wire mosi_send_sclk0;

baud DUT(pclk,prst,spi,spiswai,sppr,spr,cpol,cpha,ss,sclk,miso_receive_sclk,miso_receive_sclk0,mosi_send_sclk,mosi_send_sclk0,bauddivisor);

initial
begin
pclk=1'b0;
forever
#5 pclk=~pclk;
end


task initialize;
begin
prst=1'b0;
spi=1'b0;
sppr=1'b0;
spr=1'b0;
ss=1'b1;
cpol=1'b0;
cpha=1'b0;
spiswai=1'b1;
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

task stimulus(input [1:0]x, input [2:0]i,j, input k,l);
begin
@(posedge pclk)
cpol=k;
cpha=l;
@(negedge pclk)
spi=x;
sppr=i;
spr=j;
ss=1'b0;
spiswai=1'b0;
end
endtask



initial
begin
initialize;
reset;
stimulus(2'd0,3'd1,3'd0,0,0);
#100;
stimulus(2'd0,3'd1,3'd0,0,1);
#100;
stimulus(2'd0,3'd1,3'd0,1,0);
#100;
stimulus(2'd0,3'd1,3'd0,1,1);
#100;

$finish;
end

endmodule
