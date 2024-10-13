`timescale 1ns/1ns

module Transmitter__tb();

parameter HalfPeriod=50;
parameter Baud=0;

reg Clock, Reset, BaudRate, TxDataLoad, RxDataIn;
reg [7:0] TxDataIn, DataIn;
wire TxDataOut, RecClock, TranClock, TxDone, RxDone, RxError;
wire [7:0] RxDataOut;
wire [9:0] DataInn;

integer NumOfTests=10;
integer counter, count;

always #(HalfPeriod) Clock=~Clock;

initial begin
	$dumpvars(1,  Transmitter__tb);
	Clock=1'b1;
	BaudRate=Baud;
	TxDataIn=8'b10101010;
	TxDataLoad=1'b1;
	Reset=1'b0;
	counter=0;
end

always @(posedge TranClock) begin
	counter<=counter+1;
	if(counter==12) $stop;
end

ClockGen #(.ClockRate(10000000),
.BaudRate(9600)) 
Clk1( .Clock(Clock),
.RecClock(RecClock),
.TranClock(TranClock));

Communication Instance(.Reset(Reset),
		.Clock(Clock),
		.BaudRate(BaudRate),
		.TxDataLoad(TxDataLoad),
		.TxDataIn(TxDataIn),
		.RxDataIn(RxDataIn),
		.TxDataOut(TxDataOut),
		.RxDataOut(RxDataOut),
		.TxDone(TxDone),
		.RxDone(RxDone),
		.RxError(RxError));
endmodule
