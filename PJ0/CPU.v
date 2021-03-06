module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

Control Control(
    .Op_i       (Instruction_Memory.instr_o[31:26]),
    .RegDst_o   (),
    .ALUOp_o    (),
    .ALUSrc_o   (),
    .RegWrite_o ()
);

Adder Add_PC(
    .data1_in   (PC.pc_o),
    .data2_in   (32'd4),
    .data_o     ()
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (Add_PC.data_o),
    .pc_o       ()
);

Instruction_Memory Instruction_Memory(
    .addr_i     (PC.pc_o),
    .instr_o    ()
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (Instruction_Memory.instr_o[25:21]),
    .RTaddr_i   (Instruction_Memory.instr_o[20:16]),
    .RDaddr_i   (MUX_RegDst.data_o),
    .RDdata_i   (ALU.data_o),
    .RegWrite_i (Control.RegWrite_o), 
    .RSdata_o   (), 
    .RTdata_o   () 
);

MUX5 MUX_RegDst(
    .data1_i    (Instruction_Memory.instr_o[20:16]),
    .data2_i    (Instruction_Memory.instr_o[15:11]),
    .select_i   (Control.RegDst_o),
    .data_o     ()
);

MUX32 MUX_ALUSrc(
    .data1_i    (Registers.RTdata_o),
    .data2_i    (Sign_Extend.data_o),
    .select_i   (Control.ALUSrc_o),
    .data_o     ()
);

Sign_Extend Sign_Extend(
    .data_i     (Instruction_Memory.instr_o[15:0]),
    .data_o     ()
);
  
ALU ALU(
    .data1_i    (Registers.RSdata_o),
    .data2_i    (MUX_ALUSrc.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct_i    (Instruction_Memory.instr_o[5:0]),
    .ALUOp_i    (Control.ALUOp_o),
    .ALUCtrl_o  ()
);

endmodule