module ClockGen #(
		parameter ClockRate=10000000, //10MHz
		parameter BaudRate=9600)
		(input Clock,
		output reg RecClock,
		output reg TranClock);

parameter RecMaxRate=ClockRate/(2*8*BaudRate);
parameter TranMaxRate=ClockRate/(2*BaudRate);
parameter RecWid= $clog2(RecMaxRate);
parameter TranWid= $clog2(TranMaxRate);

reg [RecWid-1:0] RecCounter=0;
reg [TranWid-1:0] TranCounter=0;

initial begin
    RecClock= 1'b0;
    TranClock= 1'b0;
end

always @(posedge Clock) begin
    //Receiver Clock
    if (RecCounter == RecMaxRate[RecWid-1:0]) begin
        RecCounter = 0;
        RecClock = ~RecClock;
    end 
    else begin
        RecCounter = RecCounter + 1'b1;
    end
    //Transmitter Clock
    if (TranCounter == TranMaxRate[TranWid-1:0]) begin
        TranCounter = 0;
        TranClock = ~TranClock;
    end 
    else begin
        TranCounter = TranCounter + 1'b1;
    end
end

endmodule