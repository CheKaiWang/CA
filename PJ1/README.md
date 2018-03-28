Report 
● How do you implement this Pipelined CPU 
修改HW4，加入Data Memory、各種MUX及其他小module以完成required 
function，等可以run cycles再加入Forwarding_unit、IFID、IDEX、
HazardDetection_unit等pipeline會用到的module並將部分module作些許調
整，測試CPU，遇到bug時把許多value print出來並對照各筆instruction. 

 

● Explain the implementation of each module 
a. Adder: 
Output=data1+data2. 
b. ALU: 
Determine what ALU_Control bit is and act the operation. 
c. ALU_Control: 
Assign ALUCtrl.o different numbers from ALUOp_i and funct_i. 
d. AND: 
assign output = data1 & data2. 
e. Control: 
According to Op, set the signals about  mem read/write, jump,etc. 
f. CPU: 
Connect all the .v modules and run. 
g. Data_Memory 
If MemRead is set => assign out = memory[addr_in]. 
If MemWrite is set => assign memory[addr_in] = data. 
h. EQ 
Output = (data1 == data2) ? 1 : 0. 
i. Instruction_Memory 
Output = memory[addr_i>>2]. 
j. PC 
PC = PC+4 after a cycle, but PC = PC if “stall” happens. 
k. Registers 
Assign output register data = register[RS/RTaddr_in], 
if RegWrite is set, let register[RDaddr_in] = input data. 


l. Sign_Extend 
Make the sign extend to 32 bits. 
m. MUX5,MUX8,MUX32 
If select bit is set,output is input1,else oput is input0. 
n. MUX_32I 
If select = 00, output = data1, 
else if select = 01, output = data2, 
else if select = 10, output = data3. 
o. IFID 
If Flushis set, let output addr, inst = 0, 
else if stall is set, let output addr, inst keep, 
else, let output addr, inst = input. 
p. IDEX, EXMEM, MEMWB 
Set output correspond to each input. 
q. HarzardDetection_Unit 
If there are conditions that hazards happen, set some signals. 
r. Forwarding_Unit 
Control the signals notifying how much to forward. 

 

● Problems and solution of this project 
a. wire非常多，容易導致接錯 => debug要檢查很仔細 
b. 誤把output接到registers上，導致output變don’t care => 修好 
c. Pipeline debug相當不易，最好的方法是順著走 
d. Stall 的signal 太晚傳送導致晚stall => 修正stall 時機 