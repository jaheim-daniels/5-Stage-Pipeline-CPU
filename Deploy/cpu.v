module yMux1(z, a, b, c);
output z;
input a, b, c;
wire notC, upper, lower;

not my_not(notC, c);
and upperAnd(upper, a, notC);
and lowerAnd(lower, c, b);
or my_or(z, upper, lower);

endmodule

module yMux(z, a, b, c);
parameter SIZE = 2;
output [SIZE-1:0] z;
input [SIZE-1:0] a, b;
input c;
yMux1 mine[SIZE-1:0](z, a, b, c);
endmodule

module yMux4to1(z, a0,a1,a2,a3, c);
parameter SIZE = 2;
output [SIZE-1:0] z;
input [SIZE-1:0] a0, a1, a2, a3;
input [1:0] c;
wire [SIZE-1:0] zLo, zHi;
yMux #(SIZE) lo(zLo, a0, a1, c[0]);
yMux #(SIZE) hi(zHi, a2, a3, c[0]);
yMux #(SIZE) final(z, zLo, zHi, c[1]);
endmodule

module yAdder1(z, cout, a, b, cin);
output z, cout;
input a, b, cin;
xor left_xor(tmp, a, b);
xor right_xor(z, cin, tmp);
and left_and(outL, a, b);
and right_and(outR, tmp, cin);
or my_or(cout, outR, outL);
endmodule

module yAdder(z, cout, a, b, cin);
output [31:0] z;
output cout;
input [31:0] a, b;
input cin;
wire[31:0] in, out;
yAdder1 mine[31:0](z, out, a, b, in);
assign in[0] = cin;
assign in[31:1] = out[30:0];

endmodule

module yArith(z, cout, a, b, ctrl);
// add if ctrl=0, subtract if ctrl=1
output [31:0] z;
output cout;
input [31:0] a, b;
input ctrl;
wire[31:0] notB, tmp;
wire cin;
// instantiate the components and connect them
// Hint: about 4 lines of code

assign cin = ctrl;
not m_notB[31:0](notB, b);

yMux #(.SIZE(32)) m_yMux(tmp, b, notB, cin);
yAdder m_yAdder(z, cout, a, tmp, cin);

endmodule

module yAlu(z, ex, a, b, op);
input [31:0] a, b;
input [2:0] op;
wire cond;
wire [31:0] orWire, andWire, arith1, slt, sub;
output [31:0] z;
wire [15:0] z16;
wire [7:0] z8;
wire [3:0] z4;
wire [1:0] z2;
wire z1;
output ex;
assign slt[31:1] = 0;

or m_or[31:0] (orWire, a, b);
and m_and[31:0] (andWire, a, b);
yArith m_yArith(arith1, null, a, b, op[2]);

xor(cond, a[31], b[31]);
yArith m_yArith2(sub, null, a, b, 1'b1);
yMux1 m_yMux1(slt[0], sub[31], a[31], cond);
yMux4to1 #(32) m_yMux4to1(z, andWire, orWire, arith1, slt, op[1:0]);

or or16[15:0] (z16, z[15:0], z[31:16]);
or or8[7:0]  (z8, z16[7:0], z16[15:8]);
or or4[3:0] (z4, z[3:0], z[7:4]);
or or2[1:0]  (z2, z4[1:0], z16[3:2]);
or or1 (z1, z2[1], z2[0]);
not m_not(ex, z1);

endmodule

module yIF(ins, PCp4, PCin, clk);
output [31:0] ins, PCp4;
input [31:0] PCin;
wire ex;
wire[31:0] PC_reg;
input clk;

register #(32) PCreg(PC_reg, PCin, clk, 1'b1);
yAlu m_alu3(PCp4, ex, 4, PC_reg, 3'b010);
mem data(ins, PC_reg, ,clk, 1'b1, 1'b0);

endmodule


module yID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
output [31:0] rd1, rd2, imm;
output [25:0] jTarget;
input [31:0] ins, wd;
input RegDst, RegWrite, clk;
wire[4:0] rn1, rn2, wn;

assign rn1 = ins[25:21];
assign rn2 = ins[20:16];
yMux #(5) mux(wn, rn2, ins[15:11], RegDst);

assign imm[15:0] = ins[15:0];
yMux #(16) se(imm[31:16], 16'b0, 16'hffff, ins[15]);

assign jTarget = ins[25:0];
rf rfile(rd1, rd2, rn1, rn2, wn, wd, clk, RegWrite);

endmodule

module yEX(z, zero, rd1, rd2, imm, op, ALUSrc);
output [31:0] z;
output zero;
input [31:0] rd1, rd2, imm;
input [2:0] op;
input ALUSrc;
wire [31:0] b;

yMux #(32) mux(b, rd2, imm, ALUSrc);
yAlu alu(z, zero, rd1, b, op);

endmodule

module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
output [31:0] memOut;
input [31:0] exeOut, rd2;
input clk, MemRead, MemWrite;

mem data(memOut, exeOut, rd2, clk, MemRead, MemWrite);
endmodule


module yWB(wb, exeOut, memOut, Mem2Reg);
output [31:0] wb;
input [31:0] exeOut, memOut;
input Mem2Reg;

yMux #(32) mux(wb, exeOut, memOut, Mem2Reg);
endmodule


module yPC(PCin, PCp4,INT,entryPoint,imm,jTarget,zero,branch,jump);
output [31:0] PCin;
input [31:0] PCp4, entryPoint, imm, jumpX4;
input [25:0] jTarget;
input INT, zero, branch, jump;

wire [31:0] immX4, bTarget, choiceA, choiceB;
wire doBranch, zf;

assign immX4[31:2] = imm[29:0];
assign immX4[1:0] = 2'b00;

assign jumpX4[31:28] = PCp4[31:28];
assign jumpX4[27:2] = jTarget[25:0];
assign jumpX4[1:0] = 2'b00;

yAlu myALU(bTarget, zf, PCp4, immX4, 3'b010);
and (doBranch, branch, zero);

yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);
yMux #(32) mux2(choiceB, choiceA, jumpX4, jump);
yMux #(32) mux3(PCin, choiceB, entryPoint, INT);

endmodule

module yC1(rtype, lw, sw, jump, branch, opCode);
output rtype, lw, sw, jump, branch;
input [5:0] opCode;
wire not5, not4, not3, not2, not1, not0;

not (not5, opCode[5]);
not (not4, opCode[4]);
not (not3, opCode[3]);
not (not2, opCode[2]);
not (not1, opCode[1]);
not (not0, opCode[0]);
//MIPS

//rtype
and(rtype, not5, not4, not3, not2, not1, not0);

//lw opcode
and (lw, opCode[5], not4, not3, not2, opCode[1], opCode[0]);
//sw opcode
and(sw, opCode[5], not4, opCode[3], not2, opCode[1], opCode[0]);

//branch opcode
and(branch, not5, not4, not3, opCode[2], not1, not0);

//jump opcode
and(jump, not5, not4, not3, not2, opCode[1], not0);
endmodule

module yC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite,
           rtype, lw, sw, branch);

output RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite;
input rtype, lw, sw, branch;

assign RegDst = rtype;
nor(ALUSrc, rtype, branch);
nor(RegWrite, sw, branch);

assign Mem2Reg = lw;
assign MemRead = lw;
assign MemWrite = sw;
endmodule


module yC3(ALUop, rtype, branch);
output [1:0] ALUop;
input rtype, branch;

// build the circuit
// Hint: you can do it in only 2 lines
assign ALUop[0] = branch;
assign ALUop[1] = rtype;

endmodule


module yC4(op, ALUop, fnCode);
output [2:0] op;
input [5:0] fnCode;
input [1:0] ALUop;
wire wire1, wire2;
// instantiate and connect

or (wire1, fnCode[0], fnCode[3]);
and(op[0], wire1, ALUop[1]);
and (wire2, ALUop[1], fnCode[1]);
or (op[2], wire2, ALUop[0]);
nand(op[1], fnCode[2], ALUop[1]);
endmodule

module yChip(ins, rd2, wb, entryPoint, INT, clk);
output [31:0] ins, rd2, wb;
input [31:0] entryPoint;
input INT, clk;

wire [31:0] PCin;
wire RegDst, RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, jump, branch,
 lw, sw, rtype;
wire [1:0] ALUop;
wire [2:0] op;
wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, memOut, wb;
wire [25:0] jTarget;
wire [5:0] opCode, fnCode;
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

assign fnCode = ins[5:0];
yC3 myC3(ALUop, rtype, branch);
yC4 myC4(op, ALUop, fnCode);

endmodule
