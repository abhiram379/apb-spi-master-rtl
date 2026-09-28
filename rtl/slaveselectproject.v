module slave_select(
input pclk,
input presetn,
input mstr,
input spiswai,
input [1:0]spi,
input senddata,
input [11:0]bauddivisor,
output reg receivedata,
output reg  ss,
output tip);

reg [15:0]count;
wire [15:0]target;
reg rcv;

assign target= bauddivisor*8;
assign tip= ~ss;

always@(posedge pclk or negedge presetn)
begin
if(!presetn)
  begin
  count <= 16'hffff;
  ss <= 1'b1;
  rcv <= 1'b0;
  end

else if(mstr && ((spi==2'b00 || spi==2'b01) && !spiswai))
  begin
  if(senddata)
    begin
    ss <= 1'b0;
    count <= 1'b0;
    end
  else if(count < target)
    begin
    ss <= 1'b0;
    count <=count+1;
    end
  else if(count==target)
    begin
    rcv<=1'b1;
    ss <= 1'b1;
    count <= 16'hffff;
    end
  else
    begin
    ss <= 1'b1;
    rcv <= 1'b0;
    count <= 16'hffff;
    end
  end

else if(!mstr || spi == 2'b10)
  begin
    ss <= 1'b1;
    rcv <= 1'b0;
    count <= 16'hffff;
  end
end


always@(posedge pclk or negedge presetn)
begin
 if(!presetn)
   receivedata <= 1'b0;

 else
   receivedata <= rcv;

end

endmodule