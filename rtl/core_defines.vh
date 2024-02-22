//wire pcu2ifu_pc_new_req = pcu_pc_sel_i != `PCG_SEL_NORMAL;
//////////////////////////////////////////////////////////////////////////////////
// Copyright by FuxionLab
// 
// Designer     : ZiWei Liu
// Create Date  : 2020/09/25
// Project Name : ZeroCore
// File Name    : core_defines.v
//
// Description  : The parameters of ZeroCore.
//
// Revision: 
// Revision 1.1 - File Created
// Revision 1.3 - CSR Related Addition
// Revision 2.0 - Totally Changed
// Revision 2.3 - Coprocessor Updated
//
//////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
//           ____               _               _____                             //
//          |  _ \             (_)             |  __ \                            //
//          | |_) |  __ _  ___  _   ___        | |__) |__ _  _ __  __ _           //
//          |  _ <  / _` |/ __|| | / __|       |  ___// _` || '__|/ _` |          //
//          | |_) || (_| |\__ \| || (__        | |   | (_| || |  | (_| |          //
//          |____/  \__,_||___/|_| \___|       |_|    \__,_||_|   \__,_|          //
//                                                                                //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

//
// Widths
//
`define CORE_XLEN           6'd32           // core length
`define CORE_ADDRWIDTH      6'd32           // address width
`define CORE_INSTWIDTH      6'd32           // instruction width
`define CORE_DATAWIDTH      6'd32           // data width
`define CORE_IDXWIDTH       3'd5            // register index width
//
// Invalid Parameters
//
`define CORE_NULLADDR       32'd0           // invalid address width
`define CORE_NULLINST       32'h00000013    // NOP instruction
`define CORE_NULLDATA       32'd0           // invalid data width
`define CORE_NULLIDX        5'd0            // invalid register index width

////////////////////////////////////////////////////////////////////////////////////
//              _____  ______          _____  _                                   //
//             |_   _||  ____|        / ____|| |                                  //
//               | |  | |__          | (___  | |_  __ _   __ _   ___              //
//               | |  |  __|          \___ \ | __|/ _` | / _` | / _ \             //
//              _| |_ | |             ____) || |_| (_| || (_| ||  __/             //
//             |_____||_|            |_____/  \__|\__,_| \__, | \___|             //
//                                                        __/ |                   //
//                                                       |___/                    //
////////////////////////////////////////////////////////////////////////////////////

//
// IFU
//
// IFU Handshake
`define IFU_REQ_VALID    1'b1   // request valid
`define IFU_REQ_INVALID  1'b0   // request not valid
`define IFU_RSP_READY    1'b1   // response ready
`define IFU_RSP_NOTREADY 1'b0   // response not ready
//
// IFU Control
//
`define IFU_INST_VALID   1'b1   // ifu instruction valid
`define IFU_INST_INVALID 1'b0   // ifu instruction not valid
`define IFU_BUSY         1'b1   // ifu busy
`define IFU_NOTBUSY      1'b0   // ifu not busy
`define IFU_ERROR        1'b1   // ifu error
`define IFU_NOERROR      1'b0   // ifu no error
`define IFU_READY        1'b1   // ifu ready
`define IFU_NOTREADY     1'b0   // ifu not ready

//
// PCG
//
// PCG Selection
//
`define PCG_SEL_BOOT       3'b000  // initial boot pc from external
`define PCG_SEL_NORMAL     3'b001  // normal pipeline pc
`define PCG_SEL_JUMP       3'b010  // jump pc from ID
`define PCG_SEL_BRANCH     3'b011  // branch pc from EX
`define PCG_SEL_TRAP       3'b100  // trap pc from EMU
`define PCG_SEL_RETURN     3'b101  // return pc from EMU
`define PCG_SEL_MULTICYCLE 3'b110  // wait multicycle 
`define PCG_SEL_MEMACCESS  3'b111  // wait memaccess 

//
// IF Stage
//
// IF IFU Handshake
//
`define IF_INST_READY    1'b1    // IF ready to take instruction
`define IF_INST_NOTREADY 1'b0    // IF not ready to take instruction
//
// IF Handshake
//
`define IF_VALID        1'b1    // if valid
`define IF_INVALID      1'b0    // if not valid
`define IF_READY        1'b1    // if ready
`define IF_NOTREADY     1'b0    // if not ready

////////////////////////////////////////////////////////////////////////////////////
//              _____   _____           _____  _                                  //
//             |_   _| |  __ \         / ____|| |                                 //
//               | |   | |  | |       | (___  | |_  __ _   __ _   ___             //
//               | |   | |  | |        \___ \ | __|/ _` | / _` | / _ \            //
//              _| |_  | |__| |        ____) || |_| (_| || (_| ||  __/            //
//             |_____| |_____/        |_____/  \__|\__,_| \__, | \___|            //
//                                                         __/ |                  //
//                                                        |___/                   //
////////////////////////////////////////////////////////////////////////////////////

// 
// Instruction Opcode
// 
// RV32IM
//
`define ID_OPCODE_ITYPE     7'b0010011
/*      immediate-register instruction
addi    rd rs1 imm12                14..12=0    6..2=0x04 1..0=3
slli    rd rs1 31..25=0  shamt      14..12=1    6..2=0x04 1..0=3
slti    rd rs1 imm12                14..12=2    6..2=0x04 1..0=3
sltiu   rd rs1 imm12                14..12=3    6..2=0x04 1..0=3
xori    rd rs1 imm12                14..12=4    6..2=0x04 1..0=3
srli    rd rs1 31..25=0  shamt      14..12=5    6..2=0x04 1..0=3
srai    rd rs1 31..25=32 shamt      14..12=5    6..2=0x04 1..0=3
ori     rd rs1 imm12                14..12=6    6..2=0x04 1..0=3
andi    rd rs1 imm12                14..12=7    6..2=0x04 1..0=3
*/
`define ID_OPCODE_LUI       7'b0110111
/*      load u-type immediate
lui     rd imm20                                6..2=0x0D 1..0=3
*/
`define ID_OPCODE_AUIPC     7'b0010111
/*      add u-type immediate and pc
auipc   rd imm20                                6..2=0x05 1..0=3
*/
`define ID_OPCODE_RTYPE     7'b0110011
/*      register-register instruction
add     rd rs1 rs2 31..25=0         14..12=0    6..2=0x0C 1..0=3
sub     rd rs1 rs2 31..25=32        14..12=0    6..2=0x0C 1..0=3
sll     rd rs1 rs2 31..25=0         14..12=1    6..2=0x0C 1..0=3
slt     rd rs1 rs2 31..25=0         14..12=2    6..2=0x0C 1..0=3
sltu    rd rs1 rs2 31..25=0         14..12=3    6..2=0x0C 1..0=3
xor     rd rs1 rs2 31..25=0         14..12=4    6..2=0x0C 1..0=3
srl     rd rs1 rs2 31..25=0         14..12=5    6..2=0x0C 1..0=3
sra     rd rs1 rs2 31..25=32        14..12=5    6..2=0x0C 1..0=3
or      rd rs1 rs2 31..25=0         14..12=6    6..2=0x0C 1..0=3
and     rd rs1 rs2 31..25=0         14..12=7    6..2=0x0C 1..0=3
// M
mul     rd rs1 rs2 31..25=1 14..12=0 6..2=0x0C 1..0=3
mulh    rd rs1 rs2 31..25=1 14..12=1 6..2=0x0C 1..0=3
mulhsu  rd rs1 rs2 31..25=1 14..12=2 6..2=0x0C 1..0=3
mulhu   rd rs1 rs2 31..25=1 14..12=3 6..2=0x0C 1..0=3
div     rd rs1 rs2 31..25=1 14..12=4 6..2=0x0C 1..0=3
divu    rd rs1 rs2 31..25=1 14..12=5 6..2=0x0C 1..0=3
rem     rd rs1 rs2 31..25=1 14..12=6 6..2=0x0C 1..0=3
remu    rd rs1 rs2 31..25=1 14..12=7 6..2=0x0C 1..0=3
*/
`define ID_OPCODE_JAL       7'b1101111
/*      jump and link
jal     rd jimm20                               6..2=0x1b 1..0=3
*/ 
`define ID_OPCODE_JALR      7'b1100111
/*      jump and link register
jalr    rd rs1 imm12                14..12=0    6..2=0x19 1..0=3
*/
`define ID_OPCODE_BTYPE     7'b1100011
/*      conditional branch instruction
beq     bimm12hi rs1 rs2 bimm12lo   14..12=0    6..2=0x18 1..0=3
bne     bimm12hi rs1 rs2 bimm12lo   14..12=1    6..2=0x18 1..0=3
blt     bimm12hi rs1 rs2 bimm12lo   14..12=4    6..2=0x18 1..0=3
bge     bimm12hi rs1 rs2 bimm12lo   14..12=5    6..2=0x18 1..0=3
bltu    bimm12hi rs1 rs2 bimm12lo   14..12=6    6..2=0x18 1..0=3
bgeu    bimm12hi rs1 rs2 bimm12lo   14..12=7    6..2=0x18 1..0=3
*/
`define ID_OPCODE_LOAD      7'b0000011
/*      load instruction
lb      rd rs1       imm12          14..12=0    6..2=0x00 1..0=3
lh      rd rs1       imm12          14..12=1    6..2=0x00 1..0=3
lw      rd rs1       imm12          14..12=2    6..2=0x00 1..0=3
lbu     rd rs1       imm12          14..12=4    6..2=0x00 1..0=3
lhu     rd rs1       imm12          14..12=5    6..2=0x00 1..0=3
*/
`define ID_OPCODE_STORE     7'b0100011
/*      store instruction
sb     imm12hi rs1 rs2 imm12lo      14..12=0    6..2=0x08 1..0=3
sh     imm12hi rs1 rs2 imm12lo      14..12=1    6..2=0x08 1..0=3
sw     imm12hi rs1 rs2 imm12lo      14..12=2    6..2=0x08 1..0=3
*/
`define ID_OPCODE_FENCE     7'b0001111
/*      fence instruction
fence   fm pred succ  rs1 14..12=0 rd 6..2=0x03 1..0=3
fence.i imm12   rs1   14..12=1 rd 6..2=0x03 1..0=3
*/
`define ID_OPCODE_SYSTEM    7'b1110011
/*
ecall     11..7=0 19..15=0 31..20=0x000 14..12=0 6..2=0x1C 1..0=3
ebreak    11..7=0 19..15=0 31..20=0x001 14..12=0 6..2=0x1C 1..0=3
mret      11..7=0 19..15=0 31..20=0x302 14..12=0 6..2=0x1C 1..0=3
// Zicsr
csrrw     rd      rs1      imm12        14..12=1 6..2=0x1C 1..0=3
csrrs     rd      rs1      imm12        14..12=2 6..2=0x1C 1..0=3
csrrc     rd      rs1      imm12        14..12=3 6..2=0x1C 1..0=3
csrrwi    rd      rs1      imm12        14..12=5 6..2=0x1C 1..0=3
csrrsi    rd      rs1      imm12        14..12=6 6..2=0x1C 1..0=3
csrrci    rd      rs1      imm12        14..12=7 6..2=0x1C 1..0=3
*/

// 
// Custom SIMD Instructions
//
`define ID_CUSTOM_OPCODE_MAC    7'b1011011
/*
macb rs1 rs2 rd
mach rs1 rs2 rd
shfm rs1 rs2 rd
shfs rs1 rs2 rd
shft rs1 rs2 rd
shff rs1 rs2 rd
*/
`define ID_CUSTOM_OPCODE_LDI    7'b0001011
/*
lirw rs1 rs2 rd
lirh rs1 rs2 rd
lirb rs1 rs2 rd
liuw rs1 rd
liuh rs1 rd
liub rs1 rd
*/
`define ID_CUSTOM_OPCODE_STI    7'b0101011
/*
sirw rs1 rs2 rs3
sirh rs1 rs2 rs3
sirb rs1 rs2 rs3
siuw rs1 rs2
siuh rs1 rs2
siub rs1 rs2
*/

// 
// Custom Coprocessor Instructions
//
`define ID_CUSTOM_OPCODE_ZCCI   7'b1111011
/*
read xd xs1 xs2 rd rs1 rs2
write xd xs1 xs2 rd rs1 rs2
load xd xs1 xs2 rd rs1 rs2
store xd xs1 xs2 rd rs1 rs2
*/

//
// Control Signals
//
// Jump/Branch/Memory
//
`define ID_JUMP_FLAG_ENABLE     1'b1    // jump instruction occur
`define ID_JUMP_FLAG_UNABLE     1'b0    // not jump instruction
`define ID_BRANCH_FLAG_ENABLE   1'b1    // branch instruction occur
`define ID_BRANCH_FLAG_UNABLE   1'b0    // not branch instruction
`define ID_MEMORY_FLAG_ENABLE   1'b1    // memory instruction occur
`define ID_MEMORY_FLAG_UNABLE   1'b0    // not memory instruction
//
// Trap/Return
//
`define ID_TRAP_MRET_ENABLE     1'b1    // machine mode return instruction occur
`define ID_TRAP_MRET_UNABLE     1'b0    // not machine mode return instruction
`define ID_TRAP_II_ENABLE       1'b1    // illegal instruction occur
`define ID_TRAP_II_UNABLE       1'b0    // not illegal instruction
`define ID_TRAP_BP_ENABLE       1'b1    // break point instruction occur
`define ID_TRAP_BP_UNABLE       1'b0    // not break point instruction
`define ID_TRAP_MEC_ENABLE      1'b1    // machine mode environment call instruction occur
`define ID_TRAP_MEC_UNABLE      1'b0    // not machine mode environment call instruction
`define ID_TRAP_IM_ENABLE       1'b1    // instruction address misaligned occur
`define ID_TRAP_IM_UNABLE       1'b0    // not instruction address misaligned
//
// MDU Reuse
//
`define ID_MDU_REUSE_READY      1'b1    // ready to reuse
`define ID_MDU_REUSE_NOTREADY   1'b0    // not ready to reuse
`define ID_MULTI_CYCLE          1'b1    // id multi-cycle insturction
`define ID_NOT_MULTI_CYCLE      1'b0    // id has no multi-cycle insturction
//
// Register and Memory
//
`define ID_REG_WR_ENABLE        1'b1    // instruction need register write
`define ID_REG_WR_UNABLE        1'b0    // instruction not need register write
`define ID_REG_RS3_ENABLE       1'b1    // instruction need rd as rs3
`define ID_REG_RS3_UNABLE       1'b0    // instruction not need rd as rs3
`define ID_REG_WR_RS1_ENABLE    1'b1    // instruction need write back rs1
`define ID_REG_WR_RS1_UNABLE    1'b0    // instruction not need write back rs1
`define ID_MEM_RD_ENABLE        1'b1    // instruction need memory read
`define ID_MEM_RD_UNABLE        1'b0    // instruction not need memory read
`define ID_MEM_WR_ENABLE        1'b1    // instruction need memory write
`define ID_MEM_WR_UNABLE        1'b0    // instruction not need memory write
`define ID_MEM_ZCCI_ENABLE      1'b1    // instruction need zcci
`define ID_MEM_ZCCI_UNABLE      1'b0    // instruction not need zcci

//
// ID Stage
//
// ID Handshake
//
`define ID_BAKUP_ENABLE     1'b1    // id can backup
`define ID_BAKUP_UNABLE     1'b0    // id cannot backup
`define ID_VALID            1'b1    // id valid
`define ID_INVALID          1'b0    // id not valid
`define ID_READY            1'b1    // id ready
`define ID_NOTREADY         1'b0    // id not ready

////////////////////////////////////////////////////////////////////////////////////
//               ______ __   __         _____  _                                  //
//              |  ____|\ \ / /        / ____|| |                                 //
//              | |__    \ V /        | (___  | |_  __ _   __ _   ___             //
//              |  __|    > <          \___ \ | __|/ _` | / _` | / _ \            //
//              | |____  / . \         ____) || |_| (_| || (_| ||  __/            //
//              |______|/_/ \_\       |_____/  \__|\__,_| \__, | \___|            //
//                                                         __/ |                  //
//                                                        |___/                   //
////////////////////////////////////////////////////////////////////////////////////

//
// ALU
//
// ALU Operation
//
`define ALU_OPT_CAL     2'b00       // calculate : add , sub
`define ALU_OPT_COM     2'b01       // compare   : eq  , ne  , lt  , ge
`define ALU_OPT_LOG     2'b10       // logic     : and , or  , xor
`define ALU_OPT_SHF     2'b11       // shift     : sll , srl , sra
//
// ALU Function
//
`define ALU_FUNC_ONE    2'b00       // add | eq | and | sll
`define ALU_FUNC_TWO    2'b01       // sub | ne | or  | sra
`define ALU_FUNC_THREE  2'b10       //     | lt | xor | srl
`define ALU_FUNC_FOUR   2'b11       //     | ge |     | 

//
// MDU
//
// MDU Operation
//
`define MDU_OPT_INV     2'b00       // mdu shut down
`define MDU_OPT_MUL     2'b01       // multiply : mul, mulh
`define MDU_OPT_DIV     2'b10       // divide   : div, rem
//
// MDU Function
//
`define MDU_FUNC_ONE    2'b00       // mul    | div
`define MDU_FUNC_TWO    2'b01       // mulh   | rem
`define MDU_FUNC_THREE  2'b10       // mulhsu | 
//
// MDU Reuse
//
`define MDU_REUSE_UNABLE    1'b0    // result can not be reused
`define MDU_REUSE_ENABLE    1'b1    // result can be reused
//
// MDU Handshake
//
`define MDU_VALID            1'b1   // mdu valid
`define MDU_INVALID          1'b0   // mdu not valid
`define MDU_READY            1'b1   // mdu ready
`define MDU_NOTREADY         1'b0   // mdu not ready

//
// MAC
//
// MAC Operation
//
`define MAC_OPT_INV     2'b00       // mac shut down
`define MAC_OPT_MAC     2'b01       // mac     : mach, macb
`define MAC_OPT_SHF     2'b10       // shuffle : shfm, shfs, shft, shff
//
// MAC Function
//
`define MAC_FUNC_ONE    2'b00       // mach | shfm
`define MAC_FUNC_TWO    2'b01       // macb | shfs
`define MAC_FUNC_THREE  2'b10       //      | shft
`define MAC_FUNC_FOUR   2'b11       //      | shff

//
// EX Stage
//
// General Controls
//
`define EX_JUMP_FLAG_ENABLE     1'b1    // branch jump
`define EX_JUMP_FLAG_UNABLE     1'b0    // branch not jump
`define EX_EXTENSION_SIGN       1'b1    // sign extension or signed calculate
`define EX_EXTENSION_ZERO       1'b0    // zero extension or unsigned calculate
//
// Calculate Mode
//
`define EX_MODE_ALU             2'b00   // all RV32I instructions : integer instructions
                                        // some SIMD instructions : self increase memory access
`define EX_MODE_CSR             2'b01   // all csr instructions: read, write/set/clear
`define EX_MODE_MDU             2'b10   // all RV32M instructions : multiplication and division
//
// Operand Mode
//
`define EX_OPR_INVALID          2'b00   // no operands needed
`define EX_OPR_PCIMM            2'b01   // op1 = pc , op2 = imm
`define EX_OPR_RS1RS2           2'b10   // op1 = rs1, op2 = rs2
`define EX_OPR_RS1IMM           2'b11   // op1 = rs1, op2 = imm
//
// EX Handshake with MDU
//
`define EX_MDU_VALID        1'b1    // ex mdu instruction valid
`define EX_MDU_INVALID      1'b0    // ex has no mdu instruciton
`define EX_MDU_READY        1'b1    // ex ready to take mdu result
`define EX_MDU_NOTREADY     1'b0    // ex not ready to take mdu result
//
// EX Multi-Cycle
//
`define EX_MULTI_CYCLE_FINISH       1'b1    // ex multi-cycle insturction
`define EX_MULTI_CYCLE_NOTFINISH    1'b0    // ex has no multi-cycle insturction
//
// EX Handshake
//
`define EX_BAKUP_ENABLE     1'b1    // ex can backup
`define EX_BAKUP_UNABLE     1'b0    // ex cannot backup
`define EX_VALID            1'b1    // ex valid
`define EX_INVALID          1'b0    // ex not valid
`define EX_READY            1'b1    // ex ready
`define EX_NOTREADY         1'b0    // ex not ready

////////////////////////////////////////////////////////////////////////////////////
//         __  __  ______  __  __           _____  _                              //
//        |  \/  ||  ____||  \/  |         / ____|| |                             //
//        | \  / || |__   | \  / |        | (___  | |_  __ _   __ _   ___         //
//        | |\/| ||  __|  | |\/| |         \___ \ | __|/ _` | / _` | / _ \        //
//        | |  | || |____ | |  | |         ____) || |_| (_| || (_| ||  __/        //
//        |_|  |_||______||_|  |_|        |_____/  \__|\__,_| \__, | \___|        //
//                                                             __/ |              //
//                                                            |___/               //
////////////////////////////////////////////////////////////////////////////////////

//
// LSU
//
// Read Enable
//
`define LSU_READ_ENABLE     1'b1    // load instruction
`define LSU_READ_UNABLE     1'b0    // store instrucion
// LSU Handshake
`define LSU_REQ_VALID       1'b1    // request valid
`define LSU_REQ_INVALID     1'b0    // request not valid
`define LSU_RSP_READY       1'b1    // response ready
`define LSU_RSP_NOTREADY    1'b0    // response not ready
//
// LSU Control
//
`define LSU_BUSY        1'b1    // lsu busy
`define LSU_NOTBUSY     1'b0    // lsu not busy
`define LSU_ERROR       1'b1    // lsu error
`define LSU_NOERROR     1'b0    // lsu no error
`define LSU_READY       1'b1    // lsu ready
`define LSU_NOTREADY    1'b0    // lsu not ready
`define LSU_VALID       1'b1    // lsu valid
`define LSU_INVALID     1'b0    // lsu not valid

//
// CCU
//
// CCU Handshake
`define CCU_REQ_VALID       1'b1    // request valid
`define CCU_REQ_INVALID     1'b0    // request not valid
`define CCU_RSP_READY       1'b1    // response ready
`define CCU_RSP_NOTREADY    1'b0    // response not ready
//
// CCU Control
//
`define CCU_BUSY        1'b1    // ccu busy
`define CCU_NOTBUSY     1'b0    // ccu not busy
`define CCU_ERROR       1'b1    // ccu error
`define CCU_NOERROR     1'b0    // ccu no error
`define CCU_READY       1'b1    // ccu ready
`define CCU_NOTREADY    1'b0    // ccu not ready
`define CCU_VALID       1'b1    // ccu valid
`define CCU_INVALID     1'b0    // ccu not valid

//
// MEM Stage
//
// Data Size
//
`define MEM_SIZE_BYTE   2'b00   // 8-bit data
`define MEM_SIZE_HALF   2'b01   // 16-bit data
`define MEM_SIZE_WORD   2'b10   // 32-bit data
`define MEM_SIZE_DBWD   2'b11   // 64-bit data
//
// Trap
//
`define MEM_TRAP_LF_ENABLE       1'b1    // load access fault occur
`define MEM_TRAP_LF_UNABLE       1'b0    // not load access fault
`define MEM_TRAP_SF_ENABLE       1'b1    // store access fault occur
`define MEM_TRAP_SF_UNABLE       1'b0    // not store access fault
`define MEM_TRAP_LM_ENABLE       1'b1    // load address misaligned occur
`define MEM_TRAP_LM_UNABLE       1'b0    // not load address misaligned
`define MEM_TRAP_SM_ENABLE       1'b1    // store address misaligned occur
`define MEM_TRAP_SM_UNABLE       1'b0    // not store address misaligned
//
// MEM Handshake
//
`define MEM_VALID           1'b1    // mem valid
`define MEM_INVALID         1'b0    // mem not valid
`define MEM_READY           1'b1    // mem ready
`define MEM_NOTREADY        1'b0    // mem not ready

////////////////////////////////////////////////////////////////////////////////////
//    _____   _____  _____      _____               _       _                     //
//   / ____| / ____||  __ \    |  __ \             (_)     | |                    //
//  | |     | (___  | |__) |   | |__) | ___   __ _  _  ___ | |_  ___  _ __  ___   //
//  | |      \___ \ |  _  /    |  _  / / _ \ / _` || |/ __|| __|/ _ \| '__|/ __|  //
//  | |____  ____) || | \ \    | | \ \|  __/| (_| || |\__ \| |_|  __/| |   \__ \  //
//   \_____||_____/ |_|  \_\   |_|  \_\\___| \__, ||_||___/ \__|\___||_|   |___/  //
//                                            __/ |                               //
//                                           |___/                                //
////////////////////////////////////////////////////////////////////////////////////

//
// Basic
//
`define CSR_ADDRWIDTH   4'd12       // CSR address width
`define CSR_NULLADDR    12'd0       // CSR default address
`define CSR_NULLDATA    32'd0       // invalid CSR will return this data
//
// Read/Write/Set/Clear
//
`define CSR_READ_ENABLE     1'b1    // csr read
`define CSR_READ_UNABLE     1'b0    // not csr read
`define CSR_WRITE_ENABLE    1'b1    // csr write
`define CSR_WRITE_UNABLE    1'b0    // not csr write
`define CSR_SET_ENABLE      1'b1    // csr set
`define CSR_SET_UNABLE      1'b0    // not csr set
`define CSR_CLEAR_ENABLE    1'b1    // csr clear
`define CSR_CLEAR_UNABLE    1'b0    // not csr clear

//
// Interrupt Related
//
// Trap Address
//
`define CSR_TRAP_ADDR       32'd0   // default trap address
`define CSR_TRAP_BASE       30'd0   // trap address base
`define CSR_TRAP_MODE_DIR   2'b00   // trap address direct mode
`define CSR_TRAP_MADE_VEC   2'b01   // trap address vector mode
//
// Interrupt Bit
//
`define CSR_CAUSE_INT       1'b1    // interrupt
`define CSR_CAUSE_EXCP      1'b0    // exception
//
// Exception Code
//
`define CSR_INT_INV         31'd0   // invalid interrupt
`define CSR_INT_MSI         31'd3   // machine mode software interrupt
`define CSR_INT_MTI         31'd7   // machine mode timer interrupt
`define CSR_INT_MEI         31'd11  // machine mode external interrupt
`define CSR_EXCP_ILLINST    31'd2   // illegal instruction exception
`define CSR_EXCP_BREAKPOINT 31'd3   // break point exception
`define CSR_EXCP_MENVCALL   31'd11  // machine mode environment call exception
`define CSR_EXCP_INSTFAULT  31'd1   // instruction fault exception
`define CSR_EXCP_LOADFAULT  31'd5   // load fault exception
`define CSR_EXCP_STOREFAULT 31'd7   // store fault exception
`define CSR_EXCP_INSTMA     31'd0   // instruction address misaligned exception
`define CSR_EXCP_LOADMA     31'd4   // load address misaligned exception
`define CSR_EXCP_STOREMA    31'd6   // store address misaligned exception


////////////////////////////////////////////////////////////////////////////////////
//              _____  _______  _____          _    _         _  _                //
//             / ____||__   __||  __ \        | |  | |       (_)| |               //
//            | |        | |   | |__) |       | |  | | _ __   _ | |_              //
//            | |        | |   |  _  /        | |  | || '_ \ | || __|             //
//            | |____    | |   | | \ \        | |__| || | | || || |_              //
//             \_____|   |_|   |_|  \_\        \____/ |_| |_||_| \__|             //
//                                                                                //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

//
// PCU
//
// PCU IF Flush
//
`define PCU_IF_FLUSH_READY      1'b1    // IF ready to flush
`define PCU_IF_FLUSH_NOTREADY   1'b0    // IF not ready to flush
`define PCU_IF_FLUSH_ALREADY    1'b1    // IF already flush
`define PCU_IF_FLUSH_NOTYET     1'b0    // IF not flush yet
//
// Flush Mode
//
`define PCU_FLUSH_MODE_NONE     4'b0000 // no flush
`define PCU_FLUSH_MODE_INT      4'b1100 // interrupt flush: IF, ID
`define PCU_FLUSH_MODE_EXP_II   4'b1100 // illegal instruction flush: IF, ID
`define PCU_FLUSH_MODE_EXP_BP   4'b1100 // break point flush: IF, ID
`define PCU_FLUSH_MODE_EXP_EC   4'b1100 // environment call flush: IF, ID
`define PCU_FLUSH_MODE_EXP_IF   4'b1000 // instruction fetch fault flush: IF
`define PCU_FLUSH_MODE_EXP_LF   4'b1111 // load access fault flush: IF, ID, EX, MEM
`define PCU_FLUSH_MODE_EXP_SF   4'b1111 // store access fault flush: IF, ID, EX, MEM
`define PCU_FLUSH_MODE_EXP_IM   4'b1110 // instruction address misaligned flush: IF, ID
`define PCU_FLUSH_MODE_EXP_LM   4'b1110 // load address misaligned flush: IF, ID, EX
`define PCU_FLUSH_MODE_EXP_SM   4'b1110 // store address misaligned flush: IF, ID, EX
//
// Flush Signals
//
`define PCU_IF_FLUSH            1'b1    // IF flush
`define PCU_IF_NOFLUSH          1'b0    // IF no flush
`define PCU_ID_FLUSH            1'b1    // ID flush
`define PCU_ID_NOFLUSH          1'b0    // ID no flush
`define PCU_EX_FLUSH            1'b1    // EX flush
`define PCU_EX_NOFLUSH          1'b0    // EX no flush
`define PCU_MEM_FLUSH           1'b1    // MEM flush
`define PCU_MEM_NOFLUSH         1'b0    // MEM no flush

//
// CTR
//
// Counter Control
//
`define CTR_CPU_ACTIVE_ON       1'b1    // cpu is working
`define CTR_CPU_ACTIVE_OFF      1'b0    // cpu is halt
`define CTR_PC_RETIRE_ON        1'b1    // incturction is retired
`define CTR_PC_RETIRE_OFF       1'b0    // no incturction is retired