module CPU
(
    clk_i,
    start_i
);

input               clk_i;
input               start_i;

wire zero;
wire jump;
wire branch;
wire MemRead_out;
wire [31:0] ALUresult;
wire [31:0] addpc_out;
wire [31:0] IFIDaddr_o;
wire [31:0] inst_addr, inst;
wire [31:0] signedextend_out;
wire [31:0] IOperand; //Output of SignExtend from IDEX
Control Control(
    .Op_i       (inst[31:26]),
    .RegWrite_o	(),
    .MemtoReg_o	(),
    .Branch_o	(),
    .MemRead_o	(),
    .MemWrite_o	(),
    .RegDst_o   (),
    .ALUOp_o    (),
    .ALUSrc_o   (),
    .Jump_o	(jump)
);



Adder Add_PC(
    .data1_in   (inst_addr),
    .data2_in   (32'd4),
    .data_o     (addpc_out)
);

Adder IAdd (
    .data1_in (IFIDaddr_o), 
    .data2_in (signedextend_out << 2),
    .data_o ()
);

PC PC(
    .clk_i      (clk_i),
    .start_i    (start_i),
    .pc_i       (MUX_PCSrc.data_o),
    .PCWrite_i	(HazardDetection_Unit.PCWrite_o), 
    .pc_o       (inst_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (inst_addr),
    .instr_o    ()
);

wire [31:0] RegSrc;
wire [31:0] RegRSdata_o, RegRTdata_o;
wire [31:0] ALURtSrc;
wire [4:0] IDEX_RTaddr;
wire EXMEMRegWrite_o, MEMWBRegWrite_o;
wire [4:0] EXMEM_RDaddr, MEMWB_RDaddr;

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (inst[25:21]),
    .RTaddr_i   (inst[20:16]),
    .RDaddr_i   (MEMWB_RDaddr),
    .RDdata_i   (RegSrc),
    .RegWrite_i (MEMWBRegWrite_o),
    .RSdata_o   (RegRSdata_o),
    .RTdata_o   (RegRTdata_o)
);

Data_Memory Data_Memory(
    .addr_i (ALUresult),
    .data_i (EXMEM.MemWdata_o),
    .MemWrite_i (EXMEM.MemWrite_o),
    .MemRead_i (EXMEM.MemRead_o),
    .data_o ()
);

wire [31:0] branch_pc;
assign branch_pc = {4'b0, inst[25:0] << 2}; 
MUX32 MUX_PCSrc(
    .data1_i (MUX_Adderdata.data_o),
    .data2_i (branch_pc),    //EXMEM add result
    .select_i (jump),  
    .data_o ()
);

MUX32 MUX_RegSrc(
    .data1_i (MEMWB.ALUdata_o),
    .data2_i (MEMWB.ReadData_o),
    .select_i (MEMWB.MemtoReg_o),
    .data_o (RegSrc)
);

MUX32 MUX_Adderdata(
    .data1_i	(addpc_out),
    .data2_i	(IAdd.data_o),
    .select_i	(branch),
    .data_o	()
);

MUX5 MUX_RegDst(
    .data1_i    (IDEX_RTaddr), 
    .data2_i    (IDEX.RDaddr_o), 
    .select_i   (IDEX.RegDst_o),
    .data_o     ()
);


MUX32 MUX_ALUSrc(
    .data1_i    (ALURtSrc),
    .data2_i    (IOperand),
    .select_i   (IDEX.ALUSrc_o),
    .data_o     ()
);

AND AND_Branch(
    .data1_i	(Control.Branch_o),
    .data2_i	(EQ_Regdata.data_o),
    .data_o	(branch)
);

EQ EQ_Regdata(
    .data1_i	(RegRSdata_o),
    .data2_i	(RegRTdata_o),
    .data_o	()
);

MUX32_3I MUX_ALURsSrc(
    .data1_i    (IDEX.RSdata_o),
    .data2_i    (ALUresult), //ALU result from output of EXMEM
    .data3_i    (RegSrc), //RegWrite data in WB state
    .select_i   (Forwarding_Unit.ForwardA_o),
    .data_o     ()
);

MUX32_3I MUX_ALURtSrc(
    .data1_i    (IDEX.RTdata_o),
    .data2_i    (ALUresult), //ALU result from output of EXMEM
    .data3_i    (RegSrc), //RegWrite data in WB state
    .select_i   (Forwarding_Unit.ForwardB_o),
    .data_o     (ALURtSrc)
);

Sign_Extend Sign_Extend(
    .data_i     (inst[15:0]),
    .data_o     (signedextend_out)
);



ALU ALU(
    .data1_i    (MUX_ALURsSrc.data_o),
    .data2_i    (MUX_ALUSrc.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (),
    .Zero_o     ()
);



ALU_Control ALU_Control(
    .funct_i    (IOperand[5:0]),
    .ALUOp_i    (IDEX.ALUOp_o),
    .ALUCtrl_o  ()
);

IFID IFID(
    .clk_i 	(clk_i),
    .start_i 	(start_i),
    .addr_i 	(addpc_out),
    .inst_i 	(Instruction_Memory.instr_o),
    .Flush_i	(branch | jump),
    .IFIDWrite_i (HazardDetection_Unit.IFIDWrite_o),
    .addr_o	(IFIDaddr_o),
    .inst_o	(inst)
);

IDEX IDEX(
    .clk_i (clk_i), 
    .start_i (start_i), 
    .RegWrite_i (MUX8.data_o[7:7]), 
    .MemtoReg_i (MUX8.data_o[6:6]),  
    .MemRead_i (MUX8.data_o[5:5]), 
    .MemWrite_i (MUX8.data_o[4:4]), 
    .RegDst_i (MUX8.data_o[3:3]), 
    .ALUOp_i (MUX8.data_o[2:1]), 
    .ALUSrc_i (MUX8.data_o[0:0]), 
    .addr_i (IFIDaddr_o), 
    .RSdata_i (Registers.RSdata_o), 
    .RTdata_i (Registers.RTdata_o), 
    .Sign_Extend_i (Sign_Extend.data_o), 
    .Sign_Extend_o (IOperand),
    .RSaddr_i (inst[25:21]),
    .RTaddr_i (inst[20:16]), 
    .RDaddr_i (inst[15:11]), 
    .RegWrite_o (), 
    .MemtoReg_o (), 
    .MemRead_o (MemRead_out), 
    .MemWrite_o (), 
    .RegDst_o (), 
    .ALUOp_o (), 
    .ALUSrc_o (), 
    .addr_o (), 
    .RSdata_o (), 
    .RTdata_o (),
    .RSaddr_o	(),
    .RTaddr_o (IDEX_RTaddr), 
    .RDaddr_o ()
);
EXMEM EXMEM (
    .clk_i (clk_i),
    .start_i (start_i),
    .RegWrite_i (IDEX.RegWrite_o),
    .MemtoReg_i (IDEX.MemtoReg_o),
    .MemRead_i (MemRead_out),
    .MemWrite_i (IDEX.MemWrite_o),
    .ALUdata_i (ALU.data_o),
    .RegWaddr_i (MUX_RegDst.data_o), 
    .MemWdata_i (ALURtSrc),
    .RegWrite_o (EXMEMRegWrite_o),
    .MemtoReg_o (),
    .MemRead_o (),
    .MemWrite_o (),
    .ALUzero_o (),
    .ALUdata_o (ALUresult),
    .RegWaddr_o (EXMEM_RDaddr),
    .MemWdata_o ()
);
MEMWB MEMWB(
	.clk_i (clk_i),
	.start_i (start_i),
	.RegWrite_i (EXMEMRegWrite_o),
	.MemtoReg_i (EXMEM.MemtoReg_o),
	.ReadData_i (Data_Memory.data_o),
	.ALUdata_i (ALUresult),
	.RegWaddr_i (EXMEM_RDaddr),
	.RegWrite_o (MEMWBRegWrite_o),
	.MemtoReg_o (),
	.ReadData_o (),
	.ALUdata_o (),
	.RegWaddr_o (MEMWB_RDaddr)
);

Forwarding_Unit Forwarding_Unit (
    .EXMEMRegWrite_i (EXMEMRegWrite_o),
    .MEMWBRegWrite_i (MEMWBRegWrite_o),
    .IDEXRs_i (IDEX.RSaddr_o),
    .IDEXRt_i (IDEX_RTaddr),
    .EXMEMRd_i (EXMEM_RDaddr),
    .MEMWBRd_i (MEMWB_RDaddr),
    .ForwardA_o (), //for MUX_ALURsSrc_select
    .ForwardB_o ()  //for MUX_ALURtSrc_select
);

wire [7:0] MUX8_data1;
assign MUX8_data1 = {
	    Control.RegWrite_o, 
	    Control.MemtoReg_o, 
	    Control.MemRead_o, 
	    Control.MemWrite_o, 
	    Control.RegDst_o, 
	    Control.ALUOp_o, 
	    Control.ALUSrc_o 
};
MUX8 MUX8(
    .data1_i (MUX8_data1), 
    .data2_i (8'd0), 
    .select_i (HazardDetection_Unit.ControlSrc_o), 
    .data_o ()
);
HazardDetection_Unit HazardDetection_Unit(
    .IDEXMemRead_i (MemRead_out), 
    .IDEXRt_i (IDEX_RTaddr),
    .IFIDRs_i (inst[25:21]), 
    .IFIDRt_i (inst[20:16]), 
    .PCWrite_o (), 
    .IFIDWrite_o (), 
    .ControlSrc_o ()
);


endmodule
