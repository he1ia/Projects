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