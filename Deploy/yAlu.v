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
assign ex = 0;

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
or or1 (z1, z2[1:1], z2[0:0]);
not m_not(ex, z1);

endmodule
