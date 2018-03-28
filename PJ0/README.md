HW4_Reportb04902015 王哲愷 
1. Coding Environment 

Windows10 

2. Module Implementation explanation 

從 hw4.pdf 上的圖就能看出 CPU.v 中各個 module 的功能 

例如: 

Adder.v 讓 PC+4、 

Control.v 從 instruction[31-26]判斷要做什麼、 

MUX5/32.v 由 Control 傳來的訊息決定 output 哪個 data、 

Redisters.v 將 instruction 分段存放、 

Sign_extened.v 讓16bit 的 instruction1變32bit、 

ALU_Control.v 控制讓 ALU 做最後的運算並存入 Registers。 

以上這些都在 CPU.v 中連接起來。 