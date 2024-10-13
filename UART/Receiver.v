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