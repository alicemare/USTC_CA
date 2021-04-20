`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
//功能和接口说明
    //ControlUnit       是本CPU的指令译码器，组合逻辑电路
//输入
    // Op               是指令的操作码部分
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的寄存器写入模式
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的值写入寄存器,
    // MemWriteD        共4bit，采用独热码格式，对于data memory的32bit字按byte进行写入,MemWriteD=0001表示只写入最低1个byte，和xilinx bram的接口类似
    // LoadNpcD==1      表示将NextPC输出到ResultM
    // RegReadD         表示A1和A2对应的寄存器值是否被使用到了，用于forward的处理
    // BranchTypeD      表示不同的分支类型，所有类型定义在Parameters.v中
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v中
    // AluSrc2D         表示Alu输入源2的选择
    // AluSrc1D         表示Alu输入源1的选择
    // ImmType          表示指令的立即数格式
//实验要求  
    //补全模块  

`include "Parameters.v"   
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,
    output wire JalD,
    output wire JalrD,
    output reg [2:0] RegWriteD,
    output wire MemToRegD,
    output reg [3:0] MemWriteD,
    output wire LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    output wire [1:0] AluSrc2D,
    output wire AluSrc1D,
    output reg [2:0] ImmType        
    ); 
    
    assign JalD = (Op == 7'b1101111);
    assign JalrD = (Op == 7'b1100111);
    assign op2_src = !(Op == 7'b0110011);
    assign LoadNpcD = (Op == 7'b1101111 || Op == 7'b1100111);
    assign AluSrc1D = (Op == 7'b0010111);
    assign AluSrc2D = (Op == 7'b0010011) && ((Fn3 == 3'b001) || (Fn3 == 3'b101)) ? 2'b01 : ((Op == 7'b0110011 || Op == 7'b1100011) ? 2'b00 : 2'b10);

    always@(*)
    begin
        case (Op) //opcode
            7'b0110011: begin //R-type
                case (Fn3) //funct3
                    3'b000: begin //ADD&SUB
                        case (Fn7)//funct7
                            7'b0000000: begin //ADD
                                AluContrlD <= `ADD;
                                BranchTypeD <= `NOBRANCH;
                                RegReadD <= 2'b11;  // 2 reg used
                                RegWriteD <= `LW;   // write 32bit to Register
                                MemToRegD <= 0;     
                                MemWriteD <= 4'b0000;//不需要写入data memory
                                ImmType <= `RTYPE;   //立即数类型为RTYPE，表示不使用立即数
                            end
                            7'b0100000: begin //SUB
                                AluContrlD <= `SUB;
                                BranchTypeD <= `NOBRANCH;
                                RegReadD <= 2'b11;
                                RegWriteD <= `Lw;
                                MemToRegD <= 0;     
                                MemWriteD <= 4'b0000;//不需要写入data memory
                                ImmType <= `RTYPE;
                            end
                            default: begin //illegal
                                AluContrlD <= 4'bxxxx;
                                BranchTypeD <= 3'bxxx;
                                RegReadD <= 2'bxx;
                                RegWriteD <= 3'bxxx;
                                MemToRegD <= x;     
                                MemWriteD <= 4'bxxxx;
                                ImmType <= 3'bxxx;
                            end
                        endcase
                    end
                    3'b001: begin //SLL
                        AluContrlD <= `SLL;
                        BranchTypeD <= `NOBRANCH;
                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    3'b010: begin //SLT
                        AluContrlD <= `SLT;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    3'b011: begin //SLTU
                        AluContrlD <= `SLTU;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    3'b100: begin //XOR
                        AluContrlD <= `XOR;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    3'b101: begin //SRL&SRA
                        case (Fn7)
                            7'b0000000: begin //SRL
                                AluContrlD <= `SRL;
                                BranchTypeD <= `NOBRANCH;

                                RegReadD <= 2'b11;
                                RegWriteD <= 1'b1;

                                ImmType <= `RTYPE;
                            end
                            7'b0100000: begin //SRA
                                AluContrlD <= `SRA;
                                BranchTypeD <= `NOBRANCH;

                                RegReadD <= 2'b11;
                                RegWriteD <= 1'b1;

                                ImmType <= `RTYPE;
                            end
                            default: begin
                                AluContrlD <= 4'bxxxx;
                                BranchTypeD <= 3'bxxx;

                                RegReadD <= 2'bxx;
                                RegWriteD <= 1'bx;

                                ImmType <= 3'bxxx;
                            end
                        endcase
                    end
                    3'b110: begin //OR
                        AluContrlD <= `OR;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    3'b111: begin //AND
                        AluContrlD <= `AND;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    default: begin
                        AluContrlD <= 4'bxxxx;
                        BranchTypeD <= 3'bxxx;

                        RegReadD <= 2'bxx;
                        RegWriteD <= 1'bx;

                        ImmType <= 3'bxxx;
                    end
                endcase
            end
            7'b0010011: begin //I-type
                case (Fn3) //funct3
                    3'b000: begin //ADDI
                        AluContrlD <= `ADD;//运算类型
                        BranchTypeD <= `NOBRANCH;//不进行跳转

                        RegReadD <= 2'b10;//只用了reg1，没有用reg2
                        RegWriteD <= 1'b1;//需要写回寄存器

                        ImmType <= `ITYPE;//涉及的立即数为ITYPE立即数
                    end
                    3'b001: begin //SLLI
                        AluContrlD <= `SLL;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `ITYPE;
                    end
                    3'b010: begin //SLTI
                        AluContrlD <= `SLT;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `ITYPE;
                    end
                    3'b011: begin //SLTIU
                        AluContrlD <= `SLTU;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `ITYPE;
                    end
                    3'b100: begin //XORI
                        AluContrlD <= `XOR;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `ITYPE;
                    end
                    3'b101: begin //SRL&SRA
                        case (Fn7)
                            7'b0000000: begin //SRLI
                                AluContrlD <= `SRL;
                                BranchTypeD <= `NOBRANCH;

                                RegReadD <= 2'b10;
                                RegWriteD <= 1'b1;

                                ImmType <= `ITYPE;
                            end
                            7'b0100000: begin //SRAI
                                AluContrlD <= `SRA;
                                BranchTypeD <= `NOBRANCH;

                                RegReadD <= 2'b10;
                                RegWriteD <= 1'b1;

                                ImmType <= `ITYPE;
                            end
                            default: begin
                                AluContrlD <= 4'bxxxx;
                                BranchTypeD <= 3'bxxx;

                                RegReadD <= 2'bxx;
                                RegWriteD <= 1'bx;

                                ImmType <= 3'bxxx;
                            end
                        endcase
                    end
                    3'b110: begin //ORI
                        AluContrlD <= `OR;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `ITYPE;
                    end
                    3'b111: begin //ANDI
                        AluContrlD <= `AND;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `ITYPE;
                    end
                    default: begin
                        AluContrlD <= 4'bxxxx;
                        BranchTypeD <= 3'bxxx;

                        RegReadD <= 2'bxx;
                        RegWriteD <= 1'bx;

                        ImmType <= 3'bxxx;
                    end
                endcase
            end
            7'b0110111: begin //LUI
                AluContrlD <= `LUI;//运算类型
                BranchTypeD <= `NOBRANCH;//不进行跳转

                RegReadD <= 2'b00;//reg1和reg2都没有使用
                RegWriteD <= 1'b1;//需要写回寄存器

                ImmType <= `UTYPE;//立即数类型为UTYPE
            end
            7'b0010111: begin //AUIPC
                AluContrlD <= `ADD;
                BranchTypeD <= `NOBRANCH;

                RegReadD <= 2'b00;
                RegWriteD <= 1'b1;

                ImmType <= `UTYPE;
            end
            7'b1101111: begin //JAL
                AluContrlD <= `ADD;//ALU加
                BranchTypeD <= `NOBRANCH;//不进行条件跳转

                RegReadD <= 2'b00;//两个寄存器都不使用
                RegWriteD <= 1'b1;//需要写回寄存器

                ImmType <= `JTYPE;//采用JTYPE立即数
            end
            7'b1100111: begin //JALR
                AluContrlD <= `ADD;
                BranchTypeD <= `NOBRANCH;

                RegReadD <= 2'b10;
                RegWriteD <= 1'b1;

                ImmType <= `ITYPE;
            end
            7'b1100011: begin //BRANCH
                case (Fn3)
                    3'b000: begin //BEQ
                        AluContrlD <= `ADD;//无影响
                        BranchTypeD <= `BEQ;//分支类型为BEQ

                        RegReadD <= 2'b11;//两个寄存器都要使用
                        RegWriteD <= 1'b0;//不写寄存器

                        ImmType <= `BTYPE;//采用B类立即数
                    end
                    3'b001: begin //BNE
                        AluContrlD <= `ADD;
                        BranchTypeD <= `BNE;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b0;

                        ImmType <= `BTYPE;
                    end
                    3'b100: begin //BLT
                        AluContrlD <= `ADD;
                        BranchTypeD <= `BLT;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b0;

                        ImmType <= `BTYPE;
                    end
                    3'b101: begin //BGE
                        AluContrlD <= `ADD;
                        BranchTypeD <= `BGE;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b0;

                        ImmType <= `BTYPE;
                    end
                    3'b110: begin //BLTU
                        AluContrlD <= `ADD;
                        BranchTypeD <= `BLTU;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b0;

                        ImmType <= `BTYPE;
                    end
                    3'b111: begin //BGEU
                        AluContrlD <= `ADD;
                        BranchTypeD <= `BGEU;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b0;

                        ImmType <= `BTYPE;
                    end
                    default: begin
                        AluContrlD <= 4'bxxxx;
                        BranchTypeD <= 3'bxxx;

                        RegReadD <= 2'bxx;
                        RegWriteD <= 1'bx;

                        ImmType <= 3'bxxx;
                    end
                endcase
            end
            7'b0000011: begin //LOAD
                case (Fn3)
                    3'b000: begin //LB
                        AluContrlD <= `ADD;//需要执行加法
                        BranchTypeD <= `NOBRANCH;//不分支

                        RegReadD <= 2'b10;//只用reg1
                        RegWriteD <= 1'b1;//写寄存器

                        ImmType <= `ITYPE;//采用I类立即数
                    end
                    3'b001: begin //LH
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `ITYPE;
                    end
                    3'b010: begin //LW
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `ITYPE;
                    end
                    3'b100: begin //LBU
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `ITYPE;
                    end
                    3'b101: begin //LHU
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `ITYPE;
                    end
                    default: begin
                        AluContrlD <= 4'bxxxx;
                        BranchTypeD <= 3'bxxx;

                        RegReadD <= 2'bxx;
                        RegWriteD <= 1'bx;

                        ImmType <= 3'bxxx;
                    end
                endcase
            end
            7'b0100011: begin //STORE
                case (Fn3)
                    3'b000: begin //SB
                        AluContrlD <= `ADD;//需要执行加法
                        BranchTypeD <= `NOBRANCH;//不分支

                        RegReadD <= 2'b11;//reg1和reg2都要用
                        RegWriteD <= 1'b0;//不写寄存器

                        ImmType <= `STYPE;//采用S类立即数
                    end 
                    3'b001: begin //SH
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b0;

                        ImmType <= `STYPE;
                    end
                    3'b010: begin //SW
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b11;
                        RegWriteD <= 1'b0;

                        ImmType <= `STYPE;
                    end
                    default: begin
                        AluContrlD <= 4'bxxxx;
                        BranchTypeD <= 3'bxxx;

                        RegReadD <= 2'bxx;
                        RegWriteD <= 1'bx;

                        ImmType <= 3'bxxx;
                    end
                endcase
            end
            7'b1110011: begin //SYSTEM 只实现了CSR相关指令
                case (Fn3)
                    3'b001: begin //CSRRW
                        AluContrlD <= `ADD;//不需要ALU操作，采用默认的ADD
                        BranchTypeD <= `NOBRANCH;//不branch

                        RegReadD <= 2'b10;//需要使用到reg1的值
                        RegWriteD <= 1'b1;//需要写寄存器

                        ImmType <= `RTYPE;//不涉及到立即数
                    end
                    3'b010: begin //CSRRS
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    3'b011: begin //CSRRC
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b10;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    3'b101: begin //CSRRWI
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b00;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    3'b110: begin //CSRRSI
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b00;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    3'b111: begin //CSRRCI
                        AluContrlD <= `ADD;
                        BranchTypeD <= `NOBRANCH;

                        RegReadD <= 2'b00;
                        RegWriteD <= 1'b1;

                        ImmType <= `RTYPE;
                    end
                    default: begin
                        AluContrlD <= 4'bxxxx;
                        BranchTypeD <= 3'bxxx;

                        RegReadD <= 2'bxx;
                        RegWriteD <= 1'bx;

                        ImmType <= 3'bxxx;
                    end
                endcase
            end
            default: begin
                AluContrlD <= 4'bxxxx;
                BranchTypeD <= 3'bxxx;

                RegReadD <= 2'bxx;
                RegWriteD <= 1'bx;

                ImmType <= 3'bxxx;
            end
        endcase
    end
    

endmodule

