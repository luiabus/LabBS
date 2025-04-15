/******************************FILE HEAD**********************************
 * file_name         : parseGGA.v
 * function          : 解析xxGGA报文，获取UTC时间、经纬度、海拔
 * author            : 今朝无言
 * version & date    : 2021/10/14 & v1.0
 *************************************************************************/
module parseGGA(
	input					rx_clk	,
	input					rx_valid	,
	input			[7:0]	rx_data	,  
		
	output	reg 			output_valid = 0			,		//接收指令结束，上升沿对齐'\n'字符出现时刻，下降沿对齐$xxGGA后面的','的出现时刻的下一时刻
		
	output	reg		[4:0]	hh				,				//UTC时间，整数，时  0~24
	output	reg		[5:0]	mm				,				//UTC时间，整数，分  0~59
	output	reg		[5:0]	ss				,				//UTC时间，整数，秒  0~59
	output	wire	[16:0]	utc_time

);
//xxGGA格式: $xxGGA,time,lat,NS,lon,EW,quality,numSV,HDOP,alt,altUnit,sep,sepUnit,diffAge,diffStation*cs<CR><LF>
//time格式: hhmmss.ss
//lat格式: ddmm.mmmmm
//lon格式: dddmm.mmmmm
//alt格式: numeric，一位小数

reg		[4:0]	cntField;		//当前读取第几个域，以','分隔
reg 	[3:0]	cntChar;		//当前读取域中的第几个字符

reg				start	= 1'b0;	//NMEA报文的接收标志，以$开始，到\n结束
reg		[7:0]	charBuffer;
reg		[1:0]	corrNum	= 2'd0;	//比对是否为xxGGA，当corrNum=3时，表示"GGA"字符通过测试，该条报文即xxGGA

wire	[3:0]	num;			//若charBuffer为字符0~9，则将之转换为数字0~9
wire			isnum;

//将字符0~9转换为数字0~9
Char2Num Char2Num_inst(
	.Char(charBuffer),
	.Num(num),
	.isNum(isnum)
);

always @(posedge rx_clk) begin  //改成232通信串口驱动
	if (rx_valid) begin
		
	charBuffer	<= rx_data;

	//-----------------------接收NMEA报文数据-----------------------------
	if(rx_data == "$") begin			//接收到$，标志着NMEA数据的起始
		start		<= 1'b1;
		cntField	<= 5'd0;
		cntChar		<= 4'd0;
		corrNum		<= 2'd0;
	end
	else if(start) begin
		if(rx_data == "\n") begin		//收到\n，标志NMEA报文结束  遇到“.”直接结束
			start		<= 1'b0;
			output_valid		<= 1'b1;
		end
		else if(rx_data == "," || 
				rx_data == "*") begin	//收到','或'*'，为域的分隔符
			cntField	<= cntField + 1'b1;
			cntChar		<= 4'd0;
		end
		else begin							//收到其他字符
			cntChar		<= cntChar + 1'b1;
		end
	end
	else begin
		start		<= 1'b0;
		cntField	<= 5'd0;
		cntChar		<= 4'd0;
		corrNum		<= 2'd0;
	end
	
	//------------------------判断是否为xxGGA----------------------------
	if(cntField == 5'd0) begin
		if(cntChar == 4'd3 && charBuffer == "G") begin
			corrNum <= corrNum + 1'b1;
		end
		else if(cntChar == 4'd4 && charBuffer == "G") begin
			corrNum <= corrNum + 1'b1;
		end
		else if(cntChar == 4'd5 && charBuffer == "A") begin
			corrNum <= corrNum + 1'b1;
		end
	end
	if(corrNum == 2'd3) begin	//检测到是"xxGGA"，开启解析
		output_valid <= 1'b0;
		corrNum	<= 2'b0;
	end
	
	//---------------------------解析xxGGA------------------------------
	if(output_valid == 1'b0) begin
		//解析UTC时间
		if(cntField == 5'd1) begin
			if(cntChar == 4'd1) begin		//UTC-hh
				hh	<= num*4'd10;
			end
			else if(cntChar == 4'd2) begin
				hh	<= hh + num;
			end
			else if(cntChar == 4'd3) begin	//UTC-mm
				mm	<= num*4'd10;
			end
			else if(cntChar == 4'd4) begin
				mm	<= mm + num;
			end
			else if(cntChar == 4'd5) begin	//UTC-ss
				ss	<= num*4'd10;
			end
			else if(cntChar == 4'd6) begin
				ss	<= ss + num;
			end
		end
	end
	end
end

assign	utc_time[16:12]	=	hh;
assign	utc_time[11:6]	=	mm;
assign	utc_time[5:0]	=	ss;

endmodule
//END OF parseGGA.v FILE***************************************************

/******************************FILE HEAD**********************************
 * file_name         : Char2Num.v
 * function          : 若Char为字符0~9，将之转化为数字0~9
 * author            : 今朝无言
 * version & date    : 2021/10/14 & v1.0
 *************************************************************************/
module Char2Num(
	input 		[7:0]	Char,
	output		[3:0]	Num,
	output	reg			isNum
);

always@(*)begin
	case(Char)
		"0": isNum <= 1;
		"1": isNum <= 1;
		"2": isNum <= 1;
		"3": isNum <= 1;
		"4": isNum <= 1;
		"5": isNum <= 1;
		"6": isNum <= 1;
		"7": isNum <= 1;
		"8": isNum <= 1;
		"9": isNum <= 1;
		default: isNum <= 0;
	endcase
end

assign Num = isNum? Char - "0" : 4'hff;

endmodule
//END OF Char2Num.v FILE***************************************************

