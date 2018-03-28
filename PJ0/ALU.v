module ALU
(
	data1_i  ,
	data2_i  ,
	ALUCtrl_i,
	data_o   ,
	Zero_o   
);

input	[31:0]	data1_i,data2_i;
input	[2:0]	ALUCtrl_i;
output	[31:0]	data_o;
output	Zero_o;
reg		[31:0]	rst;

always@(*)begin
	case(ALUCtrl_i)
		3'b000:rst=data1_i & data2_i;
		3'b001:rst=data1_i | data2_i;
		3'b010:rst=data1_i + data2_i;
		3'b110:rst=data1_i - data2_i;
		3'b011:rst=data1_i * data2_i;
		default:rst=32'd0;
	endcase
end

assign data_o=rst;
assign Zero=(rst==32'd0);
endmodule