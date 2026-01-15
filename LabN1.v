module LabN;
wire [31:0] PCin;
reg RegDst, RegWrite, clk, ALUSrc, MemRead, MemWrite, Mem2Reg, jump, branch;
reg INT;
reg [31:0] entryPoint;
reg [2:0] op;
wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, memOut, wb;
wire [25:0] jTarget;
wire zero;

yIF myIF(ins, PCp4, PCin, clk);
yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
yWB myWB(wb, z, memOut, Mem2Reg);
yPC myPC(PCin, PCp4,INT,entryPoint,imm,jTarget,zero,branch,jump);
assign wd = wb;


initial
begin
 //------------------------------------Entry point
//PCin = 128;
entryPoint = 128; INT = 1; #1;
 //------------------------------------Run program
 repeat (43)
 begin
  //---------------------------------Fetch an ins
clk = 1; #1; INT = 0;
  //---------------------------------Set control signals
RegDst = 0; RegWrite = 0; ALUSrc = 1; op = 3'b010; jump = 0; branch = 0;
// Add statements to adjust the above defaults

if(ins[31:26]==0)
begin
  RegDst = 1;
  RegWrite = 1;
  ALUSrc = 0;
  Mem2Reg = 0;
  MemRead = 0;
  MemWrite = 0;
  //add ins
  if(ins[5:0] == 6'b100000)
    op = 3'b010;
    //or ins
  else if(ins[5:0] == 6'b100101)
    op = 3'b001;
end
else if(ins[31:26] == 2)
 begin
  RegDst = 0;
  RegWrite = 0;
  ALUSrc = 1;
  Mem2Reg = 0;
  MemRead = 0;
  jump = 1;
  MemWrite = 0;
end
//addi
else if(ins[31:26] == 8)
 begin
  RegDst = 0;
  RegWrite = 1;
  ALUSrc = 1;
  Mem2Reg = 0;
  MemRead = 0;
  MemWrite = 0;
end

//lw
else if(ins[31:26] == 35)
 begin
  RegDst = 0;
  RegWrite = 1;
  ALUSrc = 1;
  Mem2Reg = 1;
  MemRead = 1;
  MemWrite = 0;
end
//sw
else if(ins[31:26] == 43)
 begin
  RegDst = 0;
  RegWrite = 1;
  ALUSrc = 1;
  Mem2Reg = 0;
  MemRead = 0;
  MemWrite = 0;
end
//beq
else if(ins[31:26] == 4)
 begin
  RegDst = 0;
  RegWrite = 0;
  ALUSrc = 0;
  Mem2Reg = 0;
  MemRead = 0;
  MemWrite = 0;
  branch = 1;
end

  //---------------------------------Execute the ins
clk = 0; #1;
  //---------------------------------View results
#4 $display("%h: rd1=%2d rd2=%2d z=%2d zero=%b wb=%2d",
  ins, rd1, rd2, z, zero, wb);

//---------------------------------Prepare for the next ins
/*
if(INT == 1)
  PCin = entryPoint;
else
  if(ins[31:26] == 4 && zero == 1)
    PCin = PCp4 + (imm << 2);
  else if(ins[31:26] == 2)
    PCin = jTarget << 2;
  else
    PCin = PCp4;
*/
end
$finish;
end
endmodule
