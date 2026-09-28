module baud(
input pclk,
input presetn,
input [1:0]spi,
input spiswai,
input [2:0]sppr,
input [2:0]spr,
input cpol,
input cpha,
input ss,
output reg sclk,
output reg miso_receive_sclk,
output reg miso_receive_sclk0,
output reg mosi_send_sclk,
output reg mosi_send_sclk0,
output [11:0]bauddivisor);

wire preclk;
reg [11:0]count;

assign preclk= cpol ? 1'b1 : 1'b0;
assign bauddivisor= (sppr + 1) + (2**(spr+1));


always @(posedge pclk or negedge presetn)
begin
  if(!presetn)
    begin
      sclk<=preclk;
      count <=12'b0;
    end

    else if((spi==2'b00 || spi == 2'b01 && !spiswai) && !ss)
      begin
        if(count==(bauddivisor/2)-1'b1)
          begin
          sclk <= ~sclk;
          count <= 12'b0;
          end
        else
          begin
            sclk <=sclk;
            count <=count+1;
          end
      end
end

always @(posedge pclk or negedge presetn)
begin
  if(!presetn)
    begin
    miso_receive_sclk<=1'b0;
    miso_receive_sclk0<=1'b0;
    end

  else if(!ss && ((!cpha && cpol) || (cpha && !cpol)))
    begin
      if(sclk)
        begin
          if(count == (bauddivisor/2)-1'b1)
            miso_receive_sclk0<=1'b1;
          else
             miso_receive_sclk0<=1'b0;
        end
      else
        miso_receive_sclk0<=1'b0;
    end

  else if(!ss && ((!cpha && !cpol) || (cpha && cpol)))
    begin
      if(!sclk)
        begin
          if(count == (bauddivisor/2)-1'b1)
            miso_receive_sclk<=1'b1;
          else
            miso_receive_sclk<=1'b0;
          end
      else
        miso_receive_sclk<=1'b0;
    end
end

always @(posedge pclk or negedge presetn)
begin
if(!presetn)
  begin
  mosi_send_sclk<=1'b0;
  mosi_send_sclk0<=1'b0;
  end

else if(!ss && ((!cpha && cpol) || (cpha && !cpol)))
  begin
    if(sclk)
      begin
        if(count == (bauddivisor/2)-2'd2)
          mosi_send_sclk0<=1'b1;
        else
          mosi_send_sclk0<=1'b0;
      end
    else
      mosi_send_sclk0<=1'b0;
  end

  else if(!ss && ((!cpha && !cpol) || (cpha && cpol)))
  begin
    if(!sclk)
      begin
      if(count == (bauddivisor/2)-2'd2)
        mosi_send_sclk<=1'b1;
      else
        mosi_send_sclk<=1'b0;
      end
    else
      mosi_send_sclk<=1'b0;
  end
end
endmodule