echo "开始编译"
iverilog -g2005-sv -o tb -y .. tb.sv
echo "生成波形"
vvp -n tb -lxt
echo "显示波形"
gtkwave tb.lxt
pause