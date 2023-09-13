-- File       : control_unit_TB.vhd
-- This is a bit obsolete

-- OPCODES
-- constant op_load     : std_logic_vector(6 downto 0) := "0000011";
-- --constant op_misc_mem : std_logic_vector(6 downto 0) := "0001111";
-- constant op_imm      : std_logic_vector(6 downto 0) := "0010011";
-- --constant op_auipc    : std_logic_vector(6 downto 0) := "0010111";
-- constant op_store    : std_logic_vector(6 downto 0) := "0100011";
-- constant op_Rtype   : std_logic_vector(6 downto 0) := "0110011"; -- find better name, not really Rtype
-- --constant op_lui      : std_logic_vector(6 downto 0) := "0110111";
-- constant op_branch   : std_logic_vector(6 downto 0) := "1100011";
-- --constant op_jalr     : std_logic_vector(6 downto 0) := "1100111";
-- --constant op_jal      : std_logic_vector(6 downto 0) := "1101111";
-- --constant op_system   : std_logic_vector(6 downto 0) := "1110011";


library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity control_unit_TB is
end control_unit_TB;

architecture TEST of control_unit_TB is 

  -- component control_unit is
  -- 	port (
      -- instruction : in std_logic_vector(31 downto 0);
      -- immediate : out std_logic_vector(63 downto 0);
      -- ALUOp   : out std_logic_vector(1 downto 0);
      -- ALUSrc1 : out std_logic_vector(1 downto 0);
      -- ALUSrc2 : out std_logic_vector(1 downto 0);
      -- MemtoReg : out std_logic;
      -- RegWrite : out std_logic;
      -- MemRead  : out std_logic;
      -- MemWrite : out std_logic;
      -- IsBranch : out std_logic;
      -- Jump     : out std_logic;
      -- IsJalr   : out std_logic;
      -- ID_Flush : out std_logic
  -- 	);
  -- end component control_unit;

  signal instruction : std_logic_vector(31 downto 0);
  signal immediate : std_logic_vector(63 downto 0);
  signal ALUOp : std_logic_vector(1 downto 0);
  signal ALUSrc1 : std_logic_vector(1 downto 0);
  signal ALUSrc2 : std_logic_vector(1 downto 0);
  signal MemtoReg : std_logic;
  signal RegWrite : std_logic;
  signal MemRead  : std_logic;
  signal MemWrite : std_logic;
  signal IsBranch : std_logic;
  signal Jump     : std_logic;
  signal IsJalr   : std_logic;
  signal ID_Flush : std_logic;

begin
    
  STIMULUS_GEN: process
    begin
    wait for 10 ns;
      instruction <= "00000000000100000000000000000011"; --load rs1, rs2 = 0 immediate = 1 (decimal)
    wait for 10 ns;
      instruction <= "00000001111100000000010000010011"; -- type-I shamt SLI
    -- wait for 10 ns;
    --   instruction <= "00000001111100000001010000010011"; --
    wait for 100 ns;   
    
  end process STIMULUS_GEN;


  DUT: entity work.control_unit
  port map (
    instruction => instruction,
		immediate => immediate,
		ALUOp => ALUOp,
		ALUSrc1 => ALUSrc1,
    ALUSrc2 => ALUSrc2,
		MemtoReg => MemtoReg,
		RegWrite => RegWrite,
		MemRead => MemRead,
		MemWrite => MemWrite,
		IsBranch => IsBranch,
    Jump => Jump,
    IsJalr => IsJalr,
    ID_Flush => ID_Flush);
  end architecture TEST;

