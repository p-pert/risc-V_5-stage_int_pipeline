-- File       : MEM_WB_DIV.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity MEM_WB_DIV is
	port (

		--INPUTS

		clock, clear : in std_logic;

    datamem_output    : in std_logic_vector(63 downto 0);
    ALU_output_EX_MEM : in std_logic_vector(63 downto 0);
    register_rd_EX_MEM : in std_logic_vector(4 downto 0);
    
    EX_MEM_MemToReg : in std_logic;
    EX_MEM_RegWrite : in std_logic;

		--OUTPUTS

    datamem_output_MEM_WB : out std_logic_vector(63 downto 0);
    ALU_output_MEM_WB     : out std_logic_vector(63 downto 0);
    register_rd_MEM_WB : out std_logic_vector(4 downto 0);

    MEM_WB_MemToReg : out std_logic;
    MEM_WB_RegWrite : out std_logic

	);
end MEM_WB_DIV;

architecture behavioral of MEM_WB_DIV is

	--INTERNAL SIGNALS

  --INPUTS

  signal internal_datamem_output    : std_logic_vector(63 downto 0);
  signal internal_ALU_output_EX_MEM : std_logic_vector(63 downto 0);
  signal internal_register_rd_EX_MEM : std_logic_vector(4 downto 0);

  signal internal_EX_MEM_MemToReg : std_logic;
  signal internal_EX_MEM_RegWrite : std_logic;

  --OUTPUTS

  signal internal_datamem_output_MEM_WB    : std_logic_vector(63 downto 0);
  signal internal_ALU_output_MEM_WB : std_logic_vector(63 downto 0);
  signal internal_register_rd_MEM_WB : std_logic_vector(4 downto 0);

  signal internal_MEM_WB_MemToReg : std_logic;
  signal internal_MEM_WB_RegWrite : std_logic;

begin

	--INTERNAL REGISTERS

  datamem_output_reg : entity work.reg_64b port map(internal_datamem_output, '1', clock, clear, internal_datamem_output_MEM_WB);
  ALU_output_reg     : entity work.reg_64b port map(internal_ALU_output_EX_MEM, '1', clock, clear, internal_ALU_output_MEM_WB);
  register_rd_reg : entity work.reg_5b port map(internal_register_rd_EX_MEM, '1', clock, clear, internal_register_rd_MEM_WB);

  MemtoReg_reg : entity work.reg_1b port map(internal_EX_MEM_MemToReg, '1', clock, clear, internal_MEM_WB_MemToReg);
  RegWrite_reg : entity work.reg_1b port map(internal_EX_MEM_RegWrite, '1', clock, clear, internal_MEM_WB_RegWrite);
  
	--WIRING INPUT PORTS

  internal_datamem_output    <= datamem_output;
  internal_ALU_output_EX_MEM <= ALU_output_EX_MEM;
  internal_register_rd_EX_MEM <= register_rd_EX_MEM;

  internal_EX_MEM_MemtoReg <= EX_MEM_MemToReg;
  internal_EX_MEM_RegWrite <= EX_MEM_RegWrite;

	--WIRING OUTPUT PORTS

  datamem_output_MEM_WB <= internal_datamem_output_MEM_WB;
  ALU_output_MEM_WB     <= internal_ALU_output_MEM_WB;
  register_rd_MEM_WB <= internal_register_rd_MEM_WB;

  MEM_WB_MemtoReg <= internal_MEM_WB_MemToReg;
  MEM_WB_RegWrite <= internal_MEM_WB_RegWrite;

end behavioral;