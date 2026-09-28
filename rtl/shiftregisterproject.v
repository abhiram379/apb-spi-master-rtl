module shiftregister(
input pclk,
input presetn,
input ss,
input senddata,
input lsbfe,
input cpha,
input cpol,
input miso_receive_sclk,
input miso_receive_sclk0,
input mosi_send_sclk,
input mosi_send_sclk0,
input [7:0]data_mosi,
input miso,
input receivedata,
output reg mosi,
output [7:0]data_miso
);

reg [7:0]shift_reg;
reg [7:0]temp_reg;
reg [2:0]count, count1;
reg [2:0]count2, count3;

// Load MOSI data
always @(posedge pclk or negedge presetn) begin
    if(!presetn)
        shift_reg <= 8'd0;
    else if(senddata)
        shift_reg <= data_mosi;
end

assign data_miso = receivedata ? temp_reg : 8'b0;

// Transmit Data Logic
always @(posedge pclk or negedge presetn) begin
    if(!presetn) begin
        mosi <= 1'b0;
        count <= 3'd0;
        count1 <= 3'd7;
    end else if(!ss) begin
        if((!cpha && cpol) || (cpha && !cpol)) begin
            if(lsbfe) begin
                if(mosi_send_sclk0) begin
                    mosi <= shift_reg[count];
                    count <= count + 1'b1;
                end
            end else begin
                if(mosi_send_sclk0) begin
                    mosi <= shift_reg[count1];
                    count1 <= count1 - 1'b1;
                end
            end
        end else begin
            if(lsbfe) begin
                if(mosi_send_sclk) begin
                    mosi <= shift_reg[count];
                    count <= count + 1'b1;
                end
            end else begin
                if(mosi_send_sclk) begin
                    mosi <= shift_reg[count1];
                    count1 <= count1 - 1'b1;
                end
            end
        end
    end
end

// Receive Data Logic
always @(posedge pclk or negedge presetn) begin
    if(!presetn) begin
        count2 <= 3'd0;
        count3 <= 3'd7;
        temp_reg <= 8'd0;
    end else if(!ss) begin
        if((!cpha && cpol) || (cpol && !cpha)) begin
            if(lsbfe) begin
                if(miso_receive_sclk0) begin
                    temp_reg[count2] <= miso;
                    count2 <= count2 + 1'b1;
                end
            end else begin
                if(miso_receive_sclk0) begin
                    temp_reg[count3] <= miso;
                    count3 <= count3 - 1'b1;
                end
            end
        end else begin
            if(lsbfe) begin
                if(miso_receive_sclk) begin
                    temp_reg[count2] <= miso;
                    count2 <= count2 + 1'b1;
                end
            end else begin
                if(miso_receive_sclk) begin
                    temp_reg[count3] <= miso;
                    count3 <= count3 - 1'b1;
                end
            end
        end
    end
end

endmodule