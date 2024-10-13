`timescale 1ns/1ns

module Receiver__tb();

parameter HalfPeriod=50;
parameter Baud=0;

reg Clock, Reset, BaudRate, TxDataLoad, RxDataIn;
reg [7:0] TxDataIn, DataIn;
wire TxDataOut, RecClock, TranClock, TxDone, RxDone, RxError;
wire [7:0] RxDataOut;
wire [9:0] DataInn;

assign DataInn={1'b1, DataIn, 1'b0};

integer NumOfTests=10;
integer counter, count;

always #(HalfPeriod) Clock=~Clock;

initial begin
	$dumpvars(1,  Receiver__tb);
	Clock=1'b1;
	BaudRate=Baud;
	DataIn=$random;
	TxDataLoad=1'b0;
	Reset=1'b0;
	counter=0;
end
always @(posedge TranClock) begin
	RxDataIn<=DataInn[counter];
	counter<=counter+1;
	if(counter==12)begin
		if(DataIn!=RxDataOut) $display("error");
		else $display("trial successful");
 		$stop;
	end
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
