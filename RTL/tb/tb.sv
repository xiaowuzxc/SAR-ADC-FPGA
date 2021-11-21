`timescale 1ns/100ps

module tb(); /* this is automatically generated */
	parameter ADC_WIDTH = 8;
	logic                 cmp;
	logic                 start;
	logic [ADC_WIDTH-1:0] DACF;
	logic                 eoc;
	logic                 den;
	logic [ADC_WIDTH-1:0] Dout;

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(0.5) clk = ~clk;
	end
	// cmp
	initial begin
		cmp <= '0;
		forever #(1) cmp = ~cmp;
	end
	// 
	logic rst_n;
	initial begin
		rst_n <= '0;
		start <= '0;
		#10
		rst_n <= '1;
		#5
		start <= '1;
		#1
		start <= '0;
		#4
		start <= '1;
		#1
		start <= '0;
		#10
		start <= '1;
		#1
		start <= '0;
		#15
		$finish;
	end









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

	// dump wave
	initial begin
    	$dumpfile("tb.lxt");  //生成lxt的文件名称
    	$dumpvars(0, test);   //tb中实例化的仿真目标实例名称
	end

endmodule
