-- File       : EX_MEM_DIV.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity EX_MEM_DIV is
	port (

		--INPUTS

		clock, clear : in std_logic;

    ALU_output    : in std_logic_vector(63 downto 0);
    mux_fwd_2_out : in std_logic_vector(63 downto 0);
    funct3_ID_EX : in std_logic_vector(2 downto 0);
    register_rd_ID_EX : in std_logic_vector(4 downto 0);

    ID_EX_MemtoReg : in std_logic;
    ID_EX_RegWrite : in std_logic;
    ID_EX_MemRead  : in std_logic; 
    ID_EX_MemWrite : in std_logic;

		--OUTPUTS

    ALU_output_EX_MEM    : out std_logic_vector(63 downto 0);
    mux_fwd_2_out_EX_MEM : out std_logic_vector(63 downto 0);
    funct3_EX_MEM : out std_logic_vector(2 downto 0);
    register_rd_EX_MEM  : out std_logic_vector(4 downto 0);

    EX_MEM_MemtoReg : out std_logic;
    EX_MEM_RegWrite : out std_logic;
    EX_MEM_MemRead  : out std_logic; 
    EX_MEM_MemWrite : out std_logic

	);
end EX_MEM_DIV;

architecture behavioral of EX_MEM_DIV is

	--INTERNAL SIGNALS

  --INPUTS

  signal internal_ALU_output    : std_logic_vector(63 downto 0);
  signal internal_mux_fwd_2_out : std_logic_vector(63 downto 0);
  signal internal_funct3_ID_EX : std_logic_vector(2 downto 0);
  signal internal_register_rd_ID_EX : std_logic_vector(4 downto 0);

  signal internal_ID_EX_MemtoReg : std_logic;
  signal internal_ID_EX_RegWrite : std_logic;
  signal internal_ID_EX_MemRead  : std_logic; 
  signal internal_ID_EX_MemWrite : std_logic;

  --OUTPUTS

  signal internal_ALU_output_EX_MEM    : std_logic_vector(63 downto 0);
  signal internal_mux_fwd_2_out_EX_MEM : std_logic_vector(63 downto 0);
  signal internal_funct3_EX_MEM : std_logic_vector(2 downto 0);
  signal internal_register_rd_EX_MEM  : std_logic_vector(4 downto 0);

  signal internal_EX_MEM_MemtoReg : std_logic;
  signal internal_EX_MEM_RegWrite : std_logic;
  signal internal_EX_MEM_MemRead  : std_logic; 
  signal internal_EX_MEM_MemWrite : std_logic;

begin

	--INTERNAL REGISTERS

  ALU_output_reg    : entity work.reg_64b port map(internal_ALU_output, '1', clock, clear, internal_ALU_output_EX_MEM);
  mux_fwd_2_out_reg : entity work.reg_64b port map(internal_mux_fwd_2_out, '1', clock, clear, internal_mux_fwd_2_out_EX_MEM);
  funct3_reg : entity work.reg_3b port map(internal_funct3_ID_EX, '1', clock, clear, internal_funct3_EX_MEM);
  register_rd_reg : entity work.reg_5b port map(internal_register_rd_ID_EX, '1', clock, clear, internal_register_rd_EX_MEM);

  MemtoReg_reg : entity work.reg_1b port map(internal_ID_EX_MemtoReg, '1', clock, clear, internal_EX_MEM_MemtoReg);
  RegWrite_reg : entity work.reg_1b port map(internal_ID_EX_RegWrite, '1', clock, clear, internal_EX_MEM_RegWrite);
  MemRead_reg  : entity work.reg_1b port map(internal_ID_EX_MemRead, '1', clock, clear, internal_EX_MEM_MemRead);
  MemWrite_reg : entity work.reg_1b port map(internal_ID_EX_MemWrite, '1', clock, clear, internal_EX_MEM_MemWrite);

	--WIRING INPUT PORTS

  internal_ALU_output        <= ALU_output;
  internal_mux_fwd_2_out     <= mux_fwd_2_out;
  internal_funct3_ID_EX      <= funct3_ID_EX;
  internal_register_rd_ID_EX <= register_rd_ID_EX;

  internal_ID_EX_MemtoReg <= ID_EX_MemtoReg;
  internal_ID_EX_RegWrite <= ID_EX_RegWrite;
  internal_ID_EX_MemRead  <= ID_EX_MemRead;
  internal_ID_EX_MemWrite <= ID_EX_MemWrite;

	--WIRING OUTPUT PORTS

  ALU_output_EX_MEM    <= internal_ALU_output_EX_MEM;
  mux_fwd_2_out_EX_MEM <= internal_mux_fwd_2_out_EX_MEM;
  funct3_EX_MEM        <= internal_funct3_EX_MEM;
  register_rd_EX_MEM   <= internal_register_rd_EX_MEM;

  EX_MEM_MemtoReg <= internal_EX_MEM_MemtoReg;
  EX_MEM_RegWrite <= internal_EX_MEM_RegWrite;
  EX_MEM_MemRead  <= internal_EX_MEM_MemRead;
  EX_MEM_MemWrite <= internal_EX_MEM_MemWrite;

end behavioral;