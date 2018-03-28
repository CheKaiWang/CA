module ALU_Control
(
	funct_i,
	ALUOp_i,
	ALUCtrl_o
);

input	[5:0]	funct_i;
input	[1:0]	ALUOp_i;
output	[2:0]	ALUCtrl_o;

assign ALUCtrl_o =	(ALUOp_i==2'b00)?	3'b010:
						(ALUOp_i==2'b10)?	3'b001:	
						(ALUOp_i==2'b01)?	3'b110:	
						(funct_i==6'b100000)?	3'b010:	
						(funct_i==6'b100010)?	3'b110:	
						(funct_i==6'b100101)?	3'b001:	
						(funct_i==6'b100100)?	3'b000:	
						(funct_i==6'b011000)?	3'b011:	
						(funct_i==6'b101010)?	3'b111:	
														3'b010;
endmodule