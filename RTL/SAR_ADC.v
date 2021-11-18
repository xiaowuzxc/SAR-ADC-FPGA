module SAR_ADC #(
	parameter ADC_WIDTH = 8 //ADC位宽，单位bit，和DAC匹配，最大不超过255
)(
	input clk,// 时钟
	input rst_n,// 低电平复位，异步复位同步释放
	input cmp,// 比较器输出
	input start,// 启动信号，上升沿触发
	output reg [ADC_WIDTH-1:0]DACF,// DAC逐次逼近
	output reg eoc,// 转换结束，高电平脉冲
	output reg den,// 结果有效，高电平有效
	output reg [ADC_WIDTH-1:0]Dout// 结果输出
);
//*************************************************
// 寄存器、连线、状态机等定义
//*************************************************
//****reg***
reg start_r;//启动信号打一拍
reg ADCI_en;//高电平转换进行中
reg [7:0]adc_cnt;//逐次逼近计数器
//***wire***



//*************************************************
// 启动信号，上升沿触发
//*************************************************
always @(posedge clk or negedge rst_n) begin
	if(~rst_n)
		start_r <= 1'b0;
	else 
		start_r <= start;
end

//*************************************************
// 转换状态机
//*************************************************
//***状态机参数***
reg [1:0]nst;//下一状态
reg [1:0]cst;//当前状态

parameter IDLE =2'd0;//空闲状态
parameter ADCI =2'd1;//转换中

//***状态转移***
always @(posedge clk or negedge rst_n) begin : proc_
	if(~rst_n)
		cst <= IDLE;
	else
		cst <= nst;
end

//***下一状态切换***
always @(*) begin
	case (cst)
		IDLE: 
			if(start==1'b1 && start_r==1'b0)//等待上升沿
				nst = ADCI;
			else
				nst = IDLE;
		ADCI:
			if(ADCI_en)
				nst = ADCI;
			else
				nst = IDLE;
		default: nst = IDLE;
	endcase
end

//***状态机输出***
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		adc_cnt <= 0;
		eoc <= 1'b0;
		DACF <= 0;
		Dout <= 0;
		den <= 1'b0;
		ADCI_en <= 1'b0;
	end 
	else begin
		case (cst)
			IDLE: 
				begin
					DACF <= 0;
					eoc <= 1'b0;//结果输出脉冲结束
					adc_cnt <= 0;
					if(start==1'b1 && start_r==1'b0)
						ADCI_en <= 1'b1;//进入转换
				end

			ADCI:
				begin
					den <= 1'b0;
					Dout <= 0;
					adc_cnt <= adc_cnt+1;
					case (adc_cnt)
						0: DACF[ADC_WIDTH-1-adc_cnt] <= 1'b1;

						ADC_WIDTH:
							begin//转换最后一位，结束后输出，回归IDLE状态
								eoc <= 1'b1;//结果输出脉冲
								den <= 1'b1;//结果有效
								Dout <= {DACF[ADC_WIDTH-1:1],cmp};//结果缓存
							end
					
						default: 
							begin
								DACF[ADC_WIDTH-1-adc_cnt] <= 1'b1;
								DACF[ADC_WIDTH-adc_cnt] <= cmp;
								if(adc_cnt==ADC_WIDTH-1)
									ADCI_en <= 1'b0;//提前一周期转换结束，因为状态转移需要一个周期
							end
					endcase
				end

			default: /* default */;
		endcase
	end
end

endmodule