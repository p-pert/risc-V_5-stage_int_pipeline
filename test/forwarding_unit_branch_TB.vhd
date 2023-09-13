-- File       : forwarding_unit_branch_TB.vhd

library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity forwarding_unit_branch_TB is
end forwarding_unit_branch_TB;

architecture TEST of forwarding_unit_branch_TB is 

  -- component forwarding_unit_branch is
  -- 	port (
		-- register_rs2_IF_ID : in std_logic_vector(4 downto 0);
		-- register_rs1_IF_ID : in std_logic_vector(4 downto 0);
		-- register_rd_EX_MEM : in std_logic_vector(4 downto 0);
    
		-- EX_MEM_RegWrite : in std_logic;

		-- sel_fwd_branch_1 : out std_logic;
		-- sel_fwd_branch_2 : out std_logic
  -- 	);
  -- end component forwarding_unit_branch;

  signal register_rs2_IF_ID : std_logic_vector(4 downto 0);
  signal register_rs1_IF_ID : std_logic_vector(4 downto 0);
  signal register_rd_EX_MEM : std_logic_vector(4 downto 0);
     
  signal EX_MEM_RegWrite : std_logic;

  signal sel_fwd_branch_1 : std_logic;
  signal sel_fwd_branch_2 : std_logic;

begin
    
  STIMULUS_GEN: process
    begin
      wait for 10 ns;
      register_rs1_IF_ID <= "00010";
      register_rs2_IF_ID <= "00000";
      register_rd_EX_MEM <= "00010";
      
      EX_MEM_RegWrite <= '1';
      -- expect sel_fwd_branch_1 = 1

    wait for 100 ns;   
    
  end process STIMULUS_GEN;


  DUT: entity work.forwarding_unit_branch
  port map (
    register_rs2_IF_ID => register_rs2_IF_ID,
		register_rs1_IF_ID => register_rs1_IF_ID,
		register_rd_EX_MEM => register_rd_EX_MEM,
		EX_MEM_RegWrite => EX_MEM_RegWrite,
    sel_fwd_branch_1 => sel_fwd_branch_1,
    sel_fwd_branch_2 => sel_fwd_branch_2
		);
  end architecture TEST;

