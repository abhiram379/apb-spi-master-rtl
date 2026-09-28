module shiftregister_tb();

reg pclk;
reg presetn;
reg ss;

reg senddata;
reg receivedata;

reg lsbfe;
reg cpha;
reg cpol;

reg [7:0] data_mosi;
reg miso;

// Wires from DUT
wire mosi;
wire [7:0] data_miso;

// Wires for baud generator
wire sclk;
wire miso_receive_sclk;
wire miso_receive_sclk0;
wire mosi_send_sclk;
wire mosi_send_sclk0;
wire [11:0] bauddivisor;

// DUT instantiation
shiftregister dut(
    .pclk(pclk),
    .presetn(presetn),
    .ss(ss),
    .senddata(senddata),
    .lsbfe(lsbfe),
    .cpha(cpha),
    .cpol(cpol),
    .miso_receive_sclk(miso_receive_sclk),
    .miso_receive_sclk0(miso_receive_sclk0),
    .mosi_send_sclk(mosi_send_sclk),
    .mosi_send_sclk0(mosi_send_sclk0),
    .data_mosi(data_mosi),
    .miso(miso),
    .receivedata(receivedata),
    .mosi(mosi),
    .data_miso(data_miso)
);

// Baud generator instantiation
baud baud_inst(
    .pclk(pclk),
    .presetn(presetn),
    .spi(2'b00),
    .spiswai(0),
    .sppr(3'd1),
    .spr(3'd1),
    .cpol(cpol),
    .cpha(cpha),
    .ss(ss),
    .sclk(sclk),
    .miso_receive_sclk(miso_receive_sclk),
    .miso_receive_sclk0(miso_receive_sclk0),
    .mosi_send_sclk(mosi_send_sclk),
    .mosi_send_sclk0(mosi_send_sclk0),
    .bauddivisor(bauddivisor)
);

// Clock generation
initial begin
    pclk = 0;
    forever #5 pclk = ~pclk; // 100 MHz
end

// Main test
initial begin
    // Reset
    presetn = 0;
    ss = 1;
    senddata = 0;
    receivedata = 0;
    lsbfe = 1;
    cpha = 0;
    cpol = 0;
    data_mosi = 8'hA5;
    miso = 0;

    #20;
    presetn = 1;

    // Enable SPI transaction
    @(negedge pclk)
    ss = 0;

    // Load data to transmit
    senddata = 1;
    @(negedge pclk)
    senddata = 0;

    //-----------------------------------
    // Simulate SPI reception
    //-----------------------------------
   

    // Example: incoming SPI data = 11001100
    miso = 1; wait_posedge_sclk();
    miso = 1; wait_posedge_sclk();
    miso = 0; wait_posedge_sclk();
    miso = 0; wait_posedge_sclk();
    miso = 1; wait_posedge_sclk();
    miso = 1; wait_posedge_sclk();
    miso = 0; wait_posedge_sclk();
    miso = 0; wait_posedge_sclk();
  
    //sending data
 	receivedata = 1;
	ss=1'b1; wait_posedge_sclk();
    #50;
    $display("Received Data = %h", data_miso);

    #50;
    $finish;
end

// Task to wait for SCLK rising edge from baud generator
task wait_posedge_sclk;
begin
    @(negedge sclk);
    #1; // small delay to ensure sampling
end
endtask

// Monitor
initial begin
    $monitor("TIME=%0t MOSI=%b MISO_DATA=%h SCLK=%b",
              $time, mosi, data_miso, sclk);
end

endmodule