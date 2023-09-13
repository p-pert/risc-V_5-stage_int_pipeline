-- File       : hazard_unit_TB.vhd

library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity hazard_unit_TB is
end hazard_unit_TB;

architecture TEST of hazard_unit_TB is 

  -- component hazard_unit is
  -- 	port (
      -- register_rs2_IF_ID : in std_logic_vector(4 downto 0);
      -- register_rs1_IF_ID : in std_logic_vector(4 downto 0);
      -- register_rd_ID_EX  : in std_logic_vector(4 downto 0);
      -- register_rd_EX_MEM : in std_logic_vector(4 downto 0);
      
      -- ID_EX_MemRead  : in std_logic;
      -- EX_MEM_MemRead : in std_logic;
      -- IsBranch       : in std_logic;
      -- ID_EX_RegWrite : in std_logic;

		  -- Stall : out std_logic
  -- 	);
  -- end component hazard_unit;

  signal register_rs2_IF_ID : std_logic_vector(4 downto 0) := "00000";
  signal register_rs1_IF_ID : std_logic_vector(4 downto 0) := "00000";
  signal register_rd_ID_EX  : std_logic_vector(4 downto 0) := "00000";
  signal register_rd_EX_MEM : std_logic_vector(4 downto 0) := "00000";
     
  signal ID_EX_MemRead  : std_logic := '0';
  signal EX_MEM_MemRead : std_logic := '0';
  signal IsBranch       : std_logic := '0';
  signal ID_EX_RegWrite : std_logic := '0';

  signal Stall : std_logic;

begin
    
  STIMULUS_GEN: process
    begin

      wait for 10 ns;
        register_rs1_IF_ID <= "00001";
        register_rs2_IF_ID <= "00000";
        register_rd_ID_EX <= "00001";
        register_rd_EX_MEM <= "00010";
        ID_EX_MemRead <= '1';
        EX_MEM_MemRead <= '0';
        IsBranch <= '0';
        ID_EX_RegWrite <= '0';
        -- expected a stall
      wait for 10 ns;
        register_rs1_IF_ID <= "00000";
        register_rs2_IF_ID <= "01000";
        register_rd_ID_EX <= "00001";
        register_rd_EX_MEM <= "01000";
        ID_EX_MemRead <= '0';
        EX_MEM_MemRead <= '1';
        IsBranch <= '0';
        ID_EX_RegWrite <= '0';
        -- expected no stall
      wait for 10 ns;
        register_rs1_IF_ID <= "00000";
        register_rs2_IF_ID <= "01000";
        register_rd_ID_EX <= "00001";
        register_rd_EX_MEM <= "01000";
        ID_EX_MemRead <= '0';
        EX_MEM_MemRead <= '1';
        IsBranch <= '1';
        ID_EX_RegWrite <= '0';
        -- expected a stall
      wait for 10 ns;
        register_rs1_IF_ID <= "00000";
        register_rs2_IF_ID <= "00000";
        register_rd_ID_EX <= "00001";
        register_rd_EX_MEM <= "00000";
        ID_EX_MemRead <= '0';
        EX_MEM_MemRead <= '1';
        IsBranch <= '1';
        ID_EX_RegWrite <= '0';
        -- expected no stall
      wait for 10 ns;
        register_rs1_IF_ID <= "00101";
        register_rs2_IF_ID <= "00000";
        register_rd_ID_EX <= "00101";
        register_rd_EX_MEM <= "00000";
        ID_EX_MemRead <= '0';
        EX_MEM_MemRead <= '0';
        IsBranch <= '1';
        ID_EX_RegWrite <= '1';
        -- expected a stall
      wait for 10 ns;
        register_rs1_IF_ID <= "10101";
        register_rs2_IF_ID <= "11000";
        register_rd_ID_EX <= "00101";
        register_rd_EX_MEM <= "11100";
        ID_EX_MemRead <= '1';
        EX_MEM_MemRead <= '1';
        IsBranch <= '1';
        ID_EX_RegWrite <= '1';
        -- expected no stall

    wait for 100 ns;   
    
  end process STIMULUS_GEN;


  DUT: entity work.hazard_unit
  port map (
    register_rs2_IF_ID => register_rs2_IF_ID,
		register_rs1_IF_ID => register_rs1_IF_ID,
		register_rd_ID_EX => register_rd_ID_EX,
		register_rd_EX_MEM => register_rd_EX_MEM,
		ID_EX_MemRead => ID_EX_MemRead,
		EX_MEM_MemRead => EX_MEM_MemRead,
    IsBranch => IsBranch,
    ID_EX_RegWrite => ID_EX_RegWrite,
    Stall => Stall
		);
  end architecture TEST;

