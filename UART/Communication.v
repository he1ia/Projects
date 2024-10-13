module Communication(   input Reset,
			input Clock,
			input BaudRate,
			input TxDataLoad,
			input [7:0] TxDataIn,
			input RxDataIn,
			output TxDataOut,
			output [7:0] RxDataOut,
			output TxDone,
			output RxDone,
			output RxError);
parameter ClockRate=10000000;
parameter baud1=19200;
parameter baud0=9600;
wire RecClock;
wire RecClock0;
wire RecClock1;
wire TranClock;
wire TranClock0;
wire TranClock1;
wire TxDataOutt;

ClockGen #(.ClockRate(ClockRate),
.BaudRate(19200)) 
Clk1( .Clock(Clock),
.RecClock(RecClock1),
.TranClock(TranClock1));

ClockGen #(.ClockRate(ClockRate),
.BaudRate(9600)) 
Clk0(
.Clock(Clock),
.RecClock(RecClock0),
.TranClock(TranClock0));

assign RecClock=BaudRate? RecClock1:RecClock0;
assign TranClock=BaudRate? TranClock1:TranClock0;

Receiver Rx(
	.Clock(RecClock),
	.Reset(Reset),
	.RxDataIn(RxDataIn),
	.RxDataOut(RxDataOut),
	.RxDone(RxDone),
	.RxError(RxError));

Transmitter Tx(
	.Clock(TranClock),
	.Reset(Reset),
	.TxDataLoad(TxDataLoad),
	.TxDataIn(TxDataIn),
	.TxDataOut(TxDataOut),
	.TxDone(TxDone));
endmodule

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

module Transmitter(input Clock,
		input Reset,
		input TxDataLoad,
		input [7:0] TxDataIn,
		output reg TxDataOut,
		output reg TxDone);

//FSM states
parameter [1:0] idle=2'b00;
parameter [1:0] start=2'b01;
parameter [1:0] send=2'b10;
parameter [1:0] stop=2'b11;
reg [1:0] state;

integer i=0;
reg [7:0] inputt;

//always @(negedge Reset) begin
//	state<=2'b00;
	//i<=0;
	//inputt<=8'b0;
	//TxDone<=1'b0;
//end

initial begin
	state<=2'b00;
end

always @(posedge Clock) begin
	case(state)
	2'b00: begin //Idle
		TxDataOut<=1'b1;
		TxDone<=1'b0;
		i<=0;
		inputt<=8'b0;
		if(TxDataLoad) begin
			state<= 2'b01;
			inputt<=TxDataIn;
		end
	end
	2'b01: begin //Start bit
		TxDataOut<=1'b0;
		state<= 2'b10;
		i<=0;
	end
	2'b10: begin //Sending data
		TxDataOut<= inputt[i];
		if (i==7) begin
			i<=0;
			state<=2'b11;
		end
		else
			i<=i+1;
	end
	2'b11: begin //Stop bit
		TxDone<=1'b1;
		inputt<=8'b0;
		state<=2'b00;
	end
	default: state<= 2'b00;
	endcase
end
endmodule

module Receiver(input Clock,
		input Reset,
		input RxDataIn,
		output reg [7:0] RxDataOut,
		output reg RxDone,
		output reg RxError);

//FSM states
reg [1:0] idle=2'b00;
reg [1:0] start= 2'b01;
reg [1:0] receive=2'b10;
reg [1:0] stop=2'b11;
reg [1:0] state;

reg [2:0] count=3'b0;
reg [2:0] started=3'b0;
integer i=0;
reg [7:0] RxDataOutt=8'b0;

always @( negedge Reset) begin
	RxDataOut<=8'b0;
	RxDone<=1'b0;
	state<=idle;
	count<=3'b0;
	started<=3'b0;
end

always @(posedge Clock) begin
	case(state) 
		2'b0: begin //idle
			//RxError<=1'b0;
			RxDone<=1'b0;
			state<=idle;
			count<=3'b0;
			started<=3'b0;
			if(!RxDataIn) begin
				started<=3'd1;
				state<=start;
			end			
		end
		2'b01: begin //start
			//RxDataOut<=8'b0;
			RxDataOutt<=8'b0;
			RxDone<=1'b0;
			count<=3'b0;
			if(started<3'd5) begin
				if(!RxDataIn) begin
					started<=started+1;
					state<=start;
				end
				else begin
					state<=idle;
					RxError<=1'b1;
				end
			end
			else if (started==5) begin
				state<=receive;
				count=3'b0;
				i<=0;
			end
		end
		2'b10: begin //receive
			if (count==3'b111 && i<8) begin
				RxDataOutt[i]<=RxDataIn;
				count<=3'b0;
				i<=i+1;
				state<=receive;
			end
			else if (!(&count)) begin
				count<=count+1;
				state<=receive;
			end
			else if (i==8) begin
				//RxDataOutt[i]<=RxDataIn;
				state<=stop;
				count<=3'b0;
			end
		end
		2'b11: begin //stop
			//if(count==3'b111) begin
			if (RxDataIn) begin
				RxDone<=1;
				RxDataOut<=RxDataOutt;
			end
			else begin
				RxError<=1'b1;
				RxDone<=1'b0;
				RxDataOut<=8'b0;
			end
			state<=idle;
			//end
			//else count<=count+1;
		end
		default: state<=idle;
	endcase
end
endmodule