`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: ALU
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: ALU unit of RISCV CPU
//////////////////////////////////////////////////////////////////////////////////

//功能和接口说明
	//ALU接受两个操作数，根据AluContrl的不同，进行不同的计算操作，将计算结果输出到AluOut
	//AluContrl的类型定义在Parameters.v中

`include "Parameters.v"   
module ALU(
    input wire [31:0] Operand1,
    input wire [31:0] Operand2,
    input wire [3:0] AluContrl,
    output reg [31:0] AluOut
    );    
    
    // 请补全此处代码
    case (AluContrl)
        `SLL:       AluOut <= Operand1 << Operand2[4:0];    // shift left logic
        `SRL:       AluOut <= Operand1 >> Operand2[4:0];    // shift right logic
        `SRA:       AluOut <= $signed(Operand1) >>> Operand2[4:0];  //shif right arithmetic
        `ADD:       AluOut <= Operand1 + Operand2;  // add
        `SUB:       AluOut <= Operand1 - Operand2;  // sub
        `XOR:       AluOut <= Operand1 ^ Operand2;  // bit xor
        `OR:        AluOut <= Operand1 | Operand2;  // bit or
        `AND:       AluOut <= Operand1 & Operand2;  // bit and
        `SLT:       AluOut <= $signed(Operand1) < $signed(Operand2) ? 32'b1 : 32'b0;    //set less than
        `SLTU:      AluOut <= Operand1 < Operand2 ? 32'b1 : 32'b0;  //set less than unsigned
        `LUI:       AluOut <= Operand2; //load upper immediate
        default:    AluOut <= 32'hxxxxxxxx;
    endcase

endmodule

