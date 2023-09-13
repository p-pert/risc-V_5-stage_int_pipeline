-- File       : forwarding_unit_ALU_TB.vhd

library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity forwarding_unit_ALU_TB is
end forwarding_unit_ALU_TB;

architecture TEST of forwarding_unit_ALU_TB is 

  -- component forwarding_unit_ALU is
  -- 	port (
		-- register_rs1_ID_EX : in std_logic_vector(4 downto 0);
		-- register_rs2_ID_EX : in std_logic_vector(4 downto 0);
		-- register_rd_EX_MEM : in std_logic_vector(4 downto 0);
		-- register_rd_MEM_WB : in std_logic_vector(4 downto 0);
    
		-- EX_MEM_RegWrite : in std_logic;
		-- MEM_WB_RegWrite : in std_logic;

		-- sel_fwd_1 : out std_logic_vector(1 downto 0);
		-- sel_fwd_2 : out std_logic_vector(1 downto 0)
  -- 	);
  -- end component forwarding_unit_ALU;

  signal register_rs1_ID_EX : std_logic_vector(4 downto 0);
  signal register_rs2_ID_EX : std_logic_vector(4 downto 0);
  signal register_rd_EX_MEM : std_logic_vector(4 downto 0);
  signal register_rd_MEM_WB : std_logic_vector(4 downto 0);
  
  signal EX_MEM_RegWrite : std_logic;
  signal MEM_WB_RegWrite : std_logic;

  signal sel_fwd_1 : std_logic_vector(1 downto 0);
  signal sel_fwd_2 : std_logic_vector(1 downto 0);

begin
    
  STIMULUS_GEN: process
    begin
      wait for 10 ns;
      register_rs1_ID_EX <= "00010";
      register_rs2_ID_EX <= "00000";
      register_rd_EX_MEM <= "00010";
      register_rd_MEM_WB <= "00000";
      
      EX_MEM_RegWrite <= '1';
      MEM_WB_RegWrite <= '0';
      -- expect sel_fwd_2 = 01

    wait for 100 ns;   
    
  end process STIMULUS_GEN;


  DUT: entity work.forwarding_unit_ALU
  port map (
    register_rs1_ID_EX => register_rs1_ID_EX,
		register_rs2_ID_EX => register_rs2_ID_EX,
		register_rd_EX_MEM => register_rd_EX_MEM,
		register_rd_MEM_WB => register_rd_MEM_WB,
		EX_MEM_RegWrite => EX_MEM_RegWrite,
		MEM_WB_RegWrite => MEM_WB_RegWrite,
    sel_fwd_1 => sel_fwd_1,
    sel_fwd_2 => sel_fwd_2
		);
  end architecture TEST;

