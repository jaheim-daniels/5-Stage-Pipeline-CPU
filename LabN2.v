module LabN;
wire [31:0] PCin;
wire RegDst, RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, jump, branch,
 lw, sw, rtype;
reg INT, clk;
reg [31:0] entryPoint;
reg [2:0] op;
wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, memOut, wb;
wire [25:0] jTarget;
wire [5:0] opCode;
wire zero;

yIF myIF(ins, PCp4, PCin, clk);
yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
yWB myWB(wb, z, memOut, Mem2Reg);
assign wd = wb;
yPC myPC(PCin, PCp4,INT,entryPoint,imm,jTarget,zero,branch,jump);

assign opCode = ins[31:26];
yC1 myC1(rtype, lw, sw, jump, branch, opCode);
yC2 myC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite,
        rtype, lw, sw, branch);

initial
begin
 //------------------------------------Entry point

entryPoint = 128; INT = 1; #1;
 //------------------------------------Run program
 repeat (43)
 begin
  //---------------------------------Fetch an ins
clk = 1; #1; INT = 0;
  //---------------------------------Set control signals
op = 3'b010;
// Add statements to adjust the above defaults

if(ins[31:26]==0)
begin
  if(ins[5:0] == 6'h24)
    op = 3'b000;
  else if(ins[5:0] == 6'h25)
    op = 3'b001;
  else if(ins[5:0] == 6'h20)
    op = 3'b010;
  else if(ins[5:0] == 6'h22)
    op = 3'b110;
  else if(ins[5:0] == 6'h2a)
    op = 3'b111;
end
  //---------------------------------Execute the ins
clk = 0; #1;
  //---------------------------------View results
 #4 $display("%h: rd1=%2d rd2=%2d z=%2d zero=%b wb=%2d",
  ins, rd1, rd2, z, zero, wb);

//---------------------------------Prepare for the next ins

end
$finish;
end
endmodule
