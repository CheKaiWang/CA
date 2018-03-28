module Control
(
	Op_i,
	RegDst_o,
	ALUOp_o,
	ALUSrc_o,
	RegWrite_o
);

input	[5:0]	Op_i;
output	RegDst_o,ALUSrc_o,RegWrite_o;
output	[1:0]	ALUOp_o;

assign	RegWrite_o=	(Op_i==6'b000000)?	1:
						(Op_i==6'b001101)?	1:
						(Op_i==6'b001000)?	1:
						(Op_i==6'b100011)?	1:
												0;

assign	ALUSrc_o=	(Op_i==6'b000000)?	0:
						(Op_i==6'b000100)?	0:
												1;

assign	RegDst_o=	(Op_i==6'b000000)?	1:0;

assign	ALUOp_o=	(Op_i==6'b000000)?	2'b11:
						(Op_i==6'b001101)?	2'b10:
						(Op_i==6'b000100)?	2'b01:
													2'b00;
endmodule