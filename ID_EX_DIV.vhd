-- File       : ID_EX_DIV.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity ID_EX_DIV is
	port (

		--INPUTS

		clock, clear : in std_logic;
    Stall : in std_logic;

    PC_IF_ID                  : in std_logic_vector(63 downto 0);
    register_file_output_1    : in std_logic_vector(63 downto 0);
    register_file_output_2    : in std_logic_vector(63 downto 0);
    immediate                 : in std_logic_vector(63 downto 0);
    insn_bit30_IF_ID          : in std_logic;
    insn_bit25_IF_ID          : in std_logic;
    register_rs2_IF_ID        : in std_logic_vector(4 downto 0);
    register_rs1_IF_ID        : in std_logic_vector(4 downto 0);
    funct3_IF_ID              : in std_logic_vector(2 downto 0);
    register_rd_IF_ID         : in std_logic_vector(4 downto 0);
    insn_bit5_IF_ID           : in std_logic;
    insn_bit3_IF_ID           : in std_logic;

    ID_ALUOp    : in std_logic_vector(1 downto 0);
    ID_ALUSrc1  : in std_logic_vector(1 downto 0);
    ID_ALUSrc2  : in std_logic_vector(1 downto 0);
    ID_MemtoReg : in std_logic;
    ID_RegWrite : in std_logic;
    ID_MemRead  : in std_logic;
    ID_MemWrite : in std_logic;

		--OUTPUTS

    PC_ID_EX                     : out std_logic_vector(63 downto 0);
    register_file_output_1_ID_EX : out std_logic_vector(63 downto 0);
    register_file_output_2_ID_EX : out std_logic_vector(63 downto 0);
    immediate_ID_EX              : out std_logic_vector(63 downto 0);
    insn_bit30_ID_EX             : out std_logic;
    insn_bit25_ID_EX             : out std_logic;
    register_rs2_ID_EX           : out std_logic_vector(4 downto 0);
    register_rs1_ID_EX           : out std_logic_vector(4 downto 0);
    funct3_ID_EX                 : out std_logic_vector(2 downto 0);
    register_rd_ID_EX            : out std_logic_vector(4 downto 0);
    insn_bit5_ID_EX              : out std_logic;
    insn_bit3_ID_EX              : out std_logic;

    ID_EX_ALUOp    : out std_logic_vector(1 downto 0);
    ID_EX_ALUSrc1  : out std_logic_vector(1 downto 0);
    ID_EX_ALUSrc2  : out std_logic_vector(1 downto 0);
    ID_EX_MemtoReg : out std_logic;
    ID_EX_RegWrite : out std_logic;
    ID_EX_MemRead  : out std_logic; 
    ID_EX_MemWrite : out std_logic

	);
end ID_EX_DIV;

architecture behavioral of ID_EX_DIV is

  signal load : std_logic := '1';

	--INTERNAL SIGNALS

    --INPUTS

	  signal internal_PC_IF_ID                  : std_logic_vector(63 downto 0);
    signal internal_register_file_output_1    : std_logic_vector(63 downto 0);
    signal internal_register_file_output_2    : std_logic_vector(63 downto 0);
    signal internal_immediate                 : std_logic_vector(63 downto 0);
    signal internal_insn_bit30_IF_ID          : std_logic;
    signal internal_insn_bit25_IF_ID          : std_logic;
    signal internal_register_rs2_IF_ID        : std_logic_vector(4 downto 0);
    signal internal_register_rs1_IF_ID        : std_logic_vector(4 downto 0);
    signal internal_funct3_IF_ID              : std_logic_vector(2 downto 0);
    signal internal_register_rd_IF_ID         : std_logic_vector(4 downto 0);
    signal internal_insn_bit5_IF_ID           : std_logic;
    signal internal_insn_bit3_IF_ID           : std_logic;

    signal internal_ID_ALUOp    : std_logic_vector(1 downto 0);
    signal internal_ID_ALUSrc1  : std_logic_vector(1 downto 0);
    signal internal_ID_ALUSrc2  : std_logic_vector(1 downto 0);
    signal internal_ID_MemtoReg : std_logic;
    signal internal_ID_RegWrite : std_logic;
    signal internal_ID_MemRead  : std_logic;
    signal internal_ID_MemWrite : std_logic;

		--OUTPUTS

    signal internal_PC_ID_EX                     : std_logic_vector(63 downto 0);
    signal internal_register_file_output_1_ID_EX : std_logic_vector(63 downto 0);
    signal internal_register_file_output_2_ID_EX : std_logic_vector(63 downto 0);
    signal internal_immediate_ID_EX              : std_logic_vector(63 downto 0);
    signal internal_insn_bit30_ID_EX             : std_logic;
    signal internal_insn_bit25_ID_EX             : std_logic;
    signal internal_register_rs2_ID_EX           : std_logic_vector(4 downto 0);
    signal internal_register_rs1_ID_EX           : std_logic_vector(4 downto 0);
    signal internal_funct3_ID_EX                 : std_logic_vector(2 downto 0);
    signal internal_register_rd_ID_EX            : std_logic_vector(4 downto 0);
    signal internal_insn_bit5_ID_EX              : std_logic;
    signal internal_insn_bit3_ID_EX              : std_logic;

    signal internal_ID_EX_ALUOp    : std_logic_vector(1 downto 0);
    signal internal_ID_EX_ALUSrc1  : std_logic_vector(1 downto 0);
    signal internal_ID_EX_ALUSrc2  : std_logic_vector(1 downto 0);
    signal internal_ID_EX_MemtoReg : std_logic;
    signal internal_ID_EX_RegWrite : std_logic;
    signal internal_ID_EX_MemRead  : std_logic; 
    signal internal_ID_EX_MemWrite : std_logic;

begin

  load <= (NOT Stall); -- when Stall=1 won't update registers

	--INTERNAL REGISTERS

  PC_reg                     : entity work.reg_64b port map(internal_PC_IF_ID, load, clock, clear, internal_PC_ID_EX);
  register_file_output_1_reg : entity work.reg_64b port map(internal_register_file_output_1, load, clock, clear, internal_register_file_output_1_ID_EX);
  register_file_output_2_reg : entity work.reg_64b port map(internal_register_file_output_2, load, clock, clear, internal_register_file_output_2_ID_EX);  
  immediate_reg              : entity work.reg_64b port map(internal_immediate, load, clock, clear, internal_immediate_ID_EX);             
  insn_bit30_reg : entity work.reg_1b port map(internal_insn_bit30_IF_ID, load, clock, clear, internal_insn_bit30_ID_EX);
  insn_bit25_reg : entity work.reg_1b port map(internal_insn_bit25_IF_ID, load, clock, clear, internal_insn_bit25_ID_EX);
  register_rs2_reg : entity work.reg_5b port map(internal_register_rs2_IF_ID, load, clock, clear, internal_register_rs2_ID_EX);
  register_rs1_reg : entity work.reg_5b port map(internal_register_rs1_IF_ID, load, clock, clear, internal_register_rs1_ID_EX);
  funct3_reg : entity work.reg_3b port map(internal_funct3_IF_ID, load, clock, clear, internal_funct3_ID_EX);
  register_rd_reg  : entity work.reg_5b port map(internal_register_rd_IF_ID, load, clock, clear, internal_register_rd_ID_EX);
  insn_bit5_reg  : entity work.reg_1b port map(internal_insn_bit5_IF_ID, load, clock, clear, internal_insn_bit5_ID_EX);
  insn_bit3_reg  : entity work.reg_1b port map(internal_insn_bit3_IF_ID, load, clock, clear, internal_insn_bit3_ID_EX);

  ALUOp_reg   : entity work.reg_2b port map(internal_ID_ALUOp, load, clock, clear, internal_ID_EX_ALUOp);
  ALUSrc1_reg : entity work.reg_2b port map(internal_ID_ALUSrc1, load, clock, clear, internal_ID_EX_ALUSrc1);
  ALUSrc2_reg : entity work.reg_2b port map(internal_ID_ALUSrc2, load, clock, clear, internal_ID_EX_ALUSrc2);
  MemtoReg_reg : entity work.reg_1b port map(internal_ID_MemtoReg, load, clock, clear, internal_ID_EX_MemtoReg);
  RegWrite_reg : entity work.reg_1b port map(internal_ID_RegWrite, load, clock, clear, internal_ID_EX_RegWrite);
  MemRead_reg  : entity work.reg_1b port map(internal_ID_MemRead, load, clock, clear, internal_ID_EX_MemRead);
  MemWrite_reg : entity work.reg_1b port map(internal_ID_MemWrite, load, clock, clear, internal_ID_EX_MemWrite);

	--WIRING INPUT PORTS

  internal_PC_IF_ID                  <= PC_IF_ID;
  internal_register_file_output_1    <= register_file_output_1;
  internal_register_file_output_2    <= register_file_output_2;
  internal_immediate                 <= immediate;
  internal_insn_bit30_IF_ID          <= insn_bit30_IF_ID;
  internal_insn_bit25_IF_ID          <= insn_bit25_IF_ID;
  internal_register_rs2_IF_ID        <= register_rs2_IF_ID;
  internal_register_rs1_IF_ID        <= register_rs1_IF_ID;
  internal_funct3_IF_ID              <= funct3_IF_ID;
  internal_register_rd_IF_ID         <= register_rd_IF_ID;
  internal_insn_bit5_IF_ID           <= insn_bit5_IF_ID;
  internal_insn_bit3_IF_ID           <= insn_bit3_IF_ID;

  internal_ID_ALUOp    <= ID_ALUOp;
  internal_ID_ALUSrc1  <= ID_ALUSrc1;
  internal_ID_ALUSrc2  <= ID_ALUSrc2;
  internal_ID_MemtoReg <= ID_MemtoReg;
  internal_ID_RegWrite <= ID_RegWrite;
  internal_ID_MemRead  <= ID_MemRead;
  internal_ID_MemWrite <= ID_MemWrite;

	--WIRING OUTPUT PORTS

  PC_ID_EX                     <= internal_PC_ID_EX;
  register_file_output_1_ID_EX <= internal_register_file_output_1_ID_EX;
  register_file_output_2_ID_EX <= internal_register_file_output_2_ID_EX;
  immediate_ID_EX              <= internal_immediate_ID_EX;
  insn_bit30_ID_EX             <= internal_insn_bit30_ID_EX;
  insn_bit25_ID_EX             <= internal_insn_bit25_ID_EX;
  register_rs2_ID_EX           <= internal_register_rs2_ID_EX;
  register_rs1_ID_EX           <= internal_register_rs1_ID_EX;
  funct3_ID_EX                 <= internal_funct3_ID_EX;
  register_rd_ID_EX            <= internal_register_rd_ID_EX;
  insn_bit5_ID_EX              <= internal_insn_bit5_ID_EX;
  insn_bit3_ID_EX              <= internal_insn_bit3_ID_EX;

  ID_EX_ALUOp    <= internal_ID_EX_ALUOp;
  ID_EX_ALUSrc1  <= internal_ID_EX_ALUSrc1;
  ID_EX_ALUSrc2  <= internal_ID_EX_ALUSrc2;
  ID_EX_MemtoReg <= internal_ID_EX_MemtoReg;
  ID_EX_RegWrite <= internal_ID_EX_RegWrite;
  ID_EX_MemRead  <= internal_ID_EX_MemRead;
  ID_EX_MemWrite <= internal_ID_EX_MemWrite;

end behavioral;