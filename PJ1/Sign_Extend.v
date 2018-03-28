module Sign_Extend
(
	data_i,
	data_o
);

input	[15:0]	data_i;
output	[31:0]	data_o;
reg		[31:0]	data_o;

always@(data_i)begin
	data_o[15:0] = data_i[15:0];
	data_o[31:16]= {16{data_i[15]}};
end

endmodule