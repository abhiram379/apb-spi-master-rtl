module apbslaveinterface(
input pclk,
input presetn,
input [2:0]paddr,
input pwrite,
input psel,
input penable,
input [7:0]pwdata,
input ss,
input [7:0]data_miso,
input receivedata,
input tip,
output reg [7:0]prdata,
output mstr,
output cpol,
output cpha,
output lsbfe,
output spiswai,
output [2:0]sppr,
output [2:0]spr,
output spi_int_req,
output pready,
output pslverr,
output reg senddata,
output reg [7:0]data_mosi,
output reg [1:0]spi);

parameter SPI_APB_DATA_WIDTH= 8;
parameter SPI_REG_WIDTH = 8;

localparam IDLE= 2'b00,
           SETUP= 2'b01,
           ENABLE=2'b10;

localparam RUN= 2'b00,
           WAIT= 2'b01,
           STOP = 2'b10;

//internal registers//

reg [1:0]state,nextstate;
reg [1:0]nextmode;

reg [SPI_REG_WIDTH-1:0]CR1;
reg [SPI_REG_WIDTH-1:0]CR2;
reg [SPI_REG_WIDTH-1:0]BR;
reg [SPI_REG_WIDTH-1:0]SR;
reg [SPI_REG_WIDTH-1:0]DR;

reg spif;
reg sptef;
reg modf;

wire modfen;
wire spe;
wire spie;
wire sptie;
wire ssoe;

wire we;
wire re;

//apb seq logic//


always@(posedge pclk or negedge presetn)
begin
  if(!presetn)
    state <= IDLE;
  else
    state <= nextstate;
end


//apb comb logic//

always@(*)
begin

  case(state)

  IDLE:
  nextstate = (psel && !penable)? SETUP:IDLE;

  SETUP:
  nextstate = (psel && penable)? ENABLE:SETUP;

  ENABLE:
  nextstate = (pready)? ((psel)? SETUP:IDLE) : ENABLE;
  
  default:
  nextstate= IDLE;

  endcase

end

//spi seq logic//
always@(posedge pclk or negedge presetn)
begin
if(!presetn)
  spi <=RUN;

else
  spi <= nextmode;
end



always@(*)
begin
case(spi)

 RUN:
 nextmode= (!spe)? WAIT:RUN;

 WAIT:
 nextmode= (spe)? RUN: ((spiswai)? STOP:WAIT);

 STOP:
 nextmode= (!spiswai)? WAIT:STOP;

 default:
 nextmode=RUN;

 endcase
 
end


//APB control signals//

assign pready=(state==ENABLE);

assign pslverr=((state==ENABLE) && !tip);

assign we=((state==ENABLE) && pwrite);

assign re=((state==ENABLE) && !pwrite);



//register write logic//

always@(posedge pclk or negedge presetn)
begin
if(!presetn)
  begin
  CR1 <=8'd4;
  CR2 <= 8'd0;
  BR <= 8'd0;
  end

  else if(we)
    begin
    case(paddr)

    3'd0:
    CR1 <=pwdata;

    3'd1:
    CR2 <=pwdata;

    3'd2:
    BR<=pwdata;

    default:
    begin
    CR1 <=CR1;
    CR2 <=CR2;
    BR <=BR;
    end
    
    endcase
  end
end


//spi data register//

always@(posedge pclk or negedge presetn)
begin
if(!presetn)
  DR<=8'd0;

else 
if(we)
	if(paddr==3'd5)
		DR<= pwdata;
	else
		DR<=8'd0;
else
	if(DR==pwdata && DR!=data_miso && (spi== RUN || (spi==WAIT && !spiswai)))
		DR<=8'd0;
	else
		if(DR!=data_miso && (spi== RUN || (spi==WAIT && !spiswai)) && receivedata)
			DR<=data_miso;
		else
			DR<=DR;
end




//mosi logic//

always@(posedge pclk or negedge presetn)
begin
if(!presetn)
  data_mosi <= 8'b0;

else if(((spi == RUN) || (spi == WAIT)) && (DR != data_miso))
  data_mosi <=DR;

else
  data_mosi <= data_mosi;
end


//send data logic//

always@(posedge pclk or negedge presetn)
begin
if(!presetn)
  senddata <= 1'b0;

else if(we)
  senddata <= senddata;
  
else
  begin

  if(((spi == RUN) || (spi == WAIT)) && (DR != data_miso) &&(DR==pwdata))
    senddata <= 1'b1;

  else if(((spi == RUN) || (spi == WAIT)) )
    senddata <= 1'b0;

  else
    senddata <=senddata;
  end

end

//Read data path//

always@(*)
begin
case(paddr)

3'b000:
prdata=re? CR1:8'b0;

3'b001:
prdata= re? CR2:8'b0;

3'b010:
prdata= re? BR:8'b0;

3'b011:
prdata= re? SR:8'b0;

3'b101:
prdata= re? DR:8'b0;

default:
prdata= 8'b0;

endcase
end


//Control register decode//

assign spie=CR1[7];
assign spe=CR1[6];
assign sptie=CR1[5];
assign mstr=CR1[4];
assign cpol=CR1[3];
assign cpha=CR1[2];
assign ssoe=CR1[1];
assign lsbfe=CR1[0];
assign modfen=CR2[4];
assign spiswai=CR2[1];
assign sppr=BR[6:4];
assign spr=BR[2:0];


//mode fault detection//

always@(*)
begin
modf=(!ss && mstr && modfen && !ssoe)? 1'b1:1'b0;
end


//status flag//
always@(*)
begin
sptef=(DR == 8'b0);

spif=(DR != 8'b0);
end


//assign status reg //
always@(*)
begin
SR[7]=spif;
SR[6]=1'b0;
SR[5]=sptef;
SR[4]=modf;
SR[3:0]=4'b0000;
end

//interrupt request//

assign spi_int_req=(!spie && !sptie)? 1'b0:(spie && !sptie)? (spif || modf):(!spie && sptie)? sptef :(spif||modf||sptef);

endmodule