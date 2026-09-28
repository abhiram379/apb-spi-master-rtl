module apbslaveinterface_tb;

reg pclk;
reg presetn;

reg [2:0] paddr;
reg pwrite;
reg psel;
reg penable;
reg [7:0] pwdata;

reg ss;
reg [7:0] data_miso;
reg receivedata;
reg tip;

wire [7:0] prdata;

wire mstr;
wire cpol;
wire cpha;
wire lsbfe;
wire spiswai;

wire [2:0] sppr;
wire [2:0] spr;

wire spi_int_req;
wire pready;
wire pslverr;

wire senddata;
wire [7:0] data_mosi;

wire [1:0] spi;



parameter CR1 = 3'd0;
parameter CR2 = 3'd1;
parameter BR = 3'd2;
parameter SR = 3'd3;
parameter DR = 3'd5;



apbslaveinterface dut(
    .pclk(pclk),
    .presetn(presetn),
    .paddr(paddr),
    .pwrite(pwrite),
    .psel(psel),
    .penable(penable),
    .pwdata(pwdata),
    .ss(ss),
    .data_miso(data_miso),
    .receivedata(receivedata),
    .tip(tip),

    .prdata(prdata),

    .mstr(mstr),
    .cpol(cpol),
    .cpha(cpha),
    .lsbfe(lsbfe),
    .spiswai(spiswai),

    .sppr(sppr),
    .spr(spr),

    .spi_int_req(spi_int_req),
    .pready(pready),
    .pslverr(pslverr),

    .senddata(senddata),
    .data_mosi(data_mosi),

    .spi(spi)
);



initial
begin
    pclk = 0;

    forever #5 pclk = ~pclk;
end


task initialize;

begin

    paddr       = 0;
    pwdata      = 0;
    pwrite      = 0;
    psel        = 0;
    penable     = 0;
	ss          = 1;
    data_miso   = 0;
    receivedata = 0;
    tip         = 1;

end
endtask



task reset;

begin

    presetn = 1'b0;

    @(negedge pclk)
	
    presetn = 1'b1;

end
endtask



task apb_write;
input [2:0] addr;
input [7:0] data;

begin

    @(negedge pclk);

    paddr   <= addr;
    pwdata  <= data;
    pwrite  <= 1'b1;
    psel    <= 1'b1;
    penable <= 1'b0;

    @(negedge pclk);

    penable <= 1'b1;

    @(negedge pclk);

    psel    <= 1'b0;
    penable <= 1'b0;

end
endtask


task apb_read;
input [2:0] addr;

begin

    @(negedge pclk);

    paddr   <= addr;
    pwrite  <= 1'b0;
    psel    <= 1'b1;
    penable <= 1'b0;

    @(negedge pclk);

    penable <= 1'b1;

    @(negedge pclk);

    $display("READ ADDR=%0d DATA=%h", addr, prdata);

    psel    <= 1'b0;
    penable <= 1'b0;

end
endtask



initial
begin

    initialize;

    reset;
	apb_write(CR1,8'b11111011);
	apb_write(CR2,8'b00010010);
	apb_write(BR,8'b01110101);
	apb_write(DR,8'hA5);
	apb_read(CR1);
	apb_read(CR2);
	apb_read(BR);
	apb_read(SR);
	apb_read(DR);


    @(negedge pclk)
	@(negedge pclk)

    data_miso   = 8'h3C;
    receivedata = 1'b1;

    @(negedge pclk)

    receivedata = 1'b0;
    apb_read(DR);

    ss = 0;
	@(negedge pclk)
	@(negedge pclk)
	#100;

    $finish;

end


initial
begin

    $monitor(
        "TIME=%0t STATE=%0d SPI=%0d DR=%h SEND=%b MODF=%b INT=%b",
        $time,
        dut.state,
        spi,
        dut.DR,
        senddata,
        dut.modf,
        spi_int_req
    );

end

endmodule