echo "��ʼ����"
iverilog -g2005-sv -o tb -y .. tb.sv
echo "���ɲ���"
vvp -n tb -lxt2
echo "��ʾ����"
gtkwave tb.lxt
pause