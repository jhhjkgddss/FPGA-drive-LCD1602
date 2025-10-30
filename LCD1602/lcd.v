module lcd(
input				clk,
input				rst_n,

output	reg	rs,
output	wire	rw,
output	reg	en,
output	reg	[7:0]	data	
);
	
reg [17:0]cnt;
reg [3:0]state_c;
reg [3:0]state_n;
reg [4:0]char_cnt;
reg [7:0]display;
reg [7:0]disp;
reg [7:0]disk;
reg [7:0]dism;
localparam
IDIE=4'd0,
INIT=4'd1,
S0=4'd2,
S1=4'd3,
S2=4'd4,
S3=4'd5,
ROW1=4'd6,
WRITE=4'd7,
ROW2=4'd8,
STOP=4'd9,
DEF1=4'd10,
WDEF1=4'd11,
WDEF2=4'd12,
DEF2=4'd13,
DEF3=4'd14,
WDEF3=4'd15;
assign rw=1'b0;

always@(posedge clk or negedge rst_n)		//1ms翻转一次
begin
if(!rst_n)
	begin
		cnt<=18'd0;
	end
else if(cnt==18'd100_000-1)
	begin
		cnt<=18'd0;
	end
else
	begin
		cnt<=cnt+1'b1;
	end

end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
	begin
		en<=1'b0;
	end
else if(cnt==18'd50_000-1)
	begin
		en<=1;
	end
else if(cnt==18'd100_000-1)
	begin
		en<=0;
	end
end

always@(posedge clk or negedge rst_n)		//当初始化完成后控制写入字符的时间节拍
begin
if(!rst_n)
	begin
		char_cnt<=5'd0;
	end
else if(state_c==WRITE&&cnt==18'd50_000-1)
	begin
		if(char_cnt==19)
			begin
				char_cnt<=5'd0;
			end
		else
			begin
				char_cnt<=char_cnt+1'b1;
			end
	end
end


always@(*)		//写入第一行字符的状态机
begin
	case(char_cnt)
		5'd0:display<="2";
		5'd1:display<="0";
		5'd2:display<="9";
		5'd3:display<="8";
		5'd4:display<="7";
		5'd5:display<="0";
		5'd6:display<="4";
		5'd7:display<="2";
		5'd8:display<=4'h00;
		5'd9:display<=4'h01;
		5'd10:display<=4'h02;
		5'd11:display<="-";
		5'd12:display<="2";
		5'd13:display<="0";
		5'd14:display<="2";
		5'd15:display<="5";
		5'd16:display<="1";
		5'd17:display<="0";
		5'd18:display<="1";
		5'd19:display<="5";
		default:display<="P";
	endcase
end

reg [19:0]cnt_15ms;
reg flag_15ms;
always@(posedge clk or negedge rst_n)		//在最开始时延时15ms，然后标志位变为1
begin
if(!rst_n)
	begin
		cnt_15ms<=20'd0;
		flag_15ms<=0;
	end
else if(state_c==IDIE&&cnt_15ms==20'd750_000)
	begin
		flag_15ms<=1;
	end
else	if(state_c==IDIE)
	begin
		cnt_15ms<=cnt_15ms+1'b1;
	end
	
end

always@(posedge clk or negedge rst_n)		//更新状态机的节拍
begin
if(!rst_n)
	begin
		state_c<=IDIE;
	end
else if(cnt==18'd50_000-1)	
	begin
		state_c<=state_n;
	end
end

always@(*)			//控制状态机的转换
begin
	case(state_c)
		IDIE:
			begin
				if(flag_15ms)
				begin
					state_n<=INIT;
				end
				else
				begin
					state_n<=state_c;
				end
			end
		INIT:
			begin
				state_n<=DEF1;
			end
		DEF1:
			begin
				state_n<=WDEF1;
			end
		WDEF1:
			begin
				if(f_cnt==7)
					begin
						state_n<=DEF2;
					end
				else
					begin
						state_n<=state_c;
					end
			end
		DEF2:
			begin
				state_n<=WDEF2;
			end
		WDEF2:
			begin
				if(f2_cnt==7)
					begin
						state_n<=DEF3;
					end
				else
					begin
						state_n<=state_c;
					end
			end
		DEF3:
			begin
				state_n<=WDEF3;
			end
		WDEF3:
			begin
				if(f3_cnt==7)
					begin
						state_n<=S0;
					end
				else
					begin
						state_n<=state_c;
					end
			end			
		S0:
			begin
				state_n<=S1;
			end
		S1:
			begin
				state_n<=S2;
			end
		S2:
			begin
				state_n<=S3;
			end
		S3:
			begin
				state_n<=ROW1;
			end
		ROW1:
			begin
				state_n<=WRITE;
			end
		WRITE:
			begin
				if(char_cnt==7)
					begin
						state_n<=ROW2;
					end
				else if(char_cnt==19)
					begin
						state_n<=STOP;
					end
				else
					begin
						state_n<=state_c;
					end
			end
		ROW2:
			begin
				state_n<=WRITE;
			end
		STOP:
			begin
				state_n<=STOP;
			end
		default:state_n<=IDIE;
	endcase


end

always@(posedge clk or negedge rst_n)		//控制状态机的动作
begin
if(!rst_n)
	begin
		data<=8'd0;;
	end
else 
	begin
		case(state_c)
			IDIE:begin data<=8'h38;rs<=0;end
			INIT:begin data<=8'h38;rs<=0;end
			DEF1:begin data<=8'h40;rs<=0;end
			WDEF1:begin data<=disp;rs<=1;end
			DEF2:begin data<=8'h48;rs<=0;end
			WDEF2:begin data<=disk;rs<=1;end
			DEF3:begin data<=8'h50;rs<=0;end
			WDEF3:begin data<=dism;rs<=1;end
			S0:begin data<=8'h08;rs<=0;end
			S1:begin data<=8'h01;rs<=0;end
			S2:begin data<=8'h06;rs<=0;end
			S3:begin data<=8'h0c;rs<=0;end
			ROW1:begin data<=8'h80;rs<=0;end
			WRITE:begin data<=display;rs<=1;end
			ROW2:begin data<=8'hc0;rs<=0;end
			STOP:begin data<=8'h38;rs<=0;end
			default:;
		endcase
	end
end

reg [3:0]f_cnt;
always@(posedge clk or negedge rst_n)		//写自定义1字符的时序约束
begin
if(!rst_n)
	begin
		f_cnt<=4'd0;;
	end
else if(state_c==WDEF1&&cnt==18'd50_000-1)
	begin
		if(f_cnt==7)
			begin
				f_cnt<=4'd0;
			end
		else
			begin
				f_cnt=f_cnt+1'b1;
			end
	end
end

always@(*)		//写入自定义数据雨
begin
	case(f_cnt)
		4'd0:begin disp<=8'h1f;end
		4'd1:begin disp<=8'h04;end
		4'd2:begin disp<=8'h1f;end
		4'd3:begin disp<=8'h15;end
		4'd4:begin disp<=8'h1f;end
		4'd5:begin disp<=8'h15;end
		4'd6:begin disp<=8'h1f;end
		4'd7:begin disp<=8'h15;end
		default:;
	endcase
end

reg [3:0]f2_cnt;
always@(posedge clk or negedge rst_n)		//写自定义2字符的时序约束
begin
if(!rst_n)
	begin
		f2_cnt<=4'd0;;
	end
else if(state_c==WDEF2&&cnt==18'd50_000-1)
	begin
		if(f2_cnt==7)
			begin
				f2_cnt<=4'd0;
			end
		else
			begin
				f2_cnt=f2_cnt+1'b1;
			end
	end
end

always@(*)		//写入自定义数据浩
begin
	case(f2_cnt)
		4'd0:begin disk<=8'h10;end
		4'd1:begin disk<=8'h08;end
		4'd2:begin disk<=8'h04;end
		4'd3:begin disk<=8'h10;end
		4'd4:begin disk<=8'h08;end
		4'd5:begin disk<=8'h02;end	
		4'd6:begin disk<=8'h0c;end
		4'd7:begin disk<=8'h10;end
		default:;
	endcase
end


reg [3:0]f3_cnt;
always@(posedge clk or negedge rst_n)		//写自定义2字符的时序约束
begin
if(!rst_n)
	begin
		f3_cnt<=4'd0;;
	end
else if(state_c==WDEF3&&cnt==18'd50_000-1)
	begin
		if(f3_cnt==7)
			begin
				f3_cnt<=4'd0;
			end
		else
			begin
				f3_cnt=f3_cnt+1'b1;
			end
	end
end

always@(*)		//写入自定义数据浩
begin
	case(f3_cnt)
		4'd0:begin dism<=8'h0a;end
		4'd1:begin dism<=8'h0f;end
		4'd2:begin dism<=8'h12;end
		4'd3:begin dism<=8'h07;end
		4'd4:begin dism<=8'h00;end
		4'd5:begin dism<=8'h0f;end	
		4'd6:begin dism<=8'h09;end
		4'd7:begin dism<=8'h0f;end
		default:;
	endcase
end

endmodule

