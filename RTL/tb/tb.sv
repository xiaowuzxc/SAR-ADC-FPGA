`timescale 1ns/100ps
module tb(); /* this is automatically generated */

`define random_test //定义则使用随机值测试
//`define ANL_vol 0.35//测试数据，模拟电压输入，有效数据范围(0,1)
//以上只有其中一个可以被define
`define ADC_bits 8 // SRC ADC位宽，多少位宽就需要多少周期进行转换
parameter ADC_WIDTH = `ADC_bits;
`ifdef random_test
logic [ADC_WIDTH-1:0]test_sig = $random();
`else
parameter vol_input = `ANL_vol;//
parameter test_sig = vol_input*(2**ADC_WIDTH-1);
`endif





//两次测试时间间隔
parameter timeoffset = 4;

//测试用信号
logic clk;
logic rst_n;
logic cmp;
logic start;
logic [ADC_WIDTH-1:0] DACF;
logic eoc;
logic den;
logic [ADC_WIDTH-1:0] Dout;

// clk
initial begin
	clk = '0;
	forever #(0.5) clk = ~clk;
end

//启动测试
initial begin
	adcrst();//复位系统
	#1
	startsw();//启动转换
	#(ADC_WIDTH+timeoffset)
	startsw();//再次转换
	#(ADC_WIDTH+timeoffset)
	$finish;

end

//比较器建模，+输入为test_sig，-输入为DACF，输出cmp，产生测试激励
always@(*) begin
	if(DACF>test_sig)
		cmp = '0;
	else
		cmp = '1;
end

task startsw;//启动转换
	start <= '0;
	@(posedge clk)
	start <= '1;
	@(posedge clk)
	start <= '0;
endtask : startsw

task adcrst;//复位任务
	rst_n <= '0;
	start <= '0;
	#10
	rst_n <= '1;
	#5;
endtask : adcrst


//例化SRC ADC控制器
SAR_ADC #(
		.ADC_WIDTH(ADC_WIDTH)
	) test (
		.clk   (clk),
		.rst_n (rst_n),
		.cmp   (cmp),
		.start (start),
		.DACF  (DACF),
		.eoc   (eoc),
		.den   (den),
		.Dout  (Dout)
	);

// 输出波形
initial begin
	$dumpfile("tb.lxt");  //生成lxt的文件名称
	$dumpvars(0, test);   //tb中实例化的仿真目标实例名称
end

endmodule
