-- File       : branch_comparator_TB.vhd

library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity branch_comparator_TB is
end branch_comparator_TB;

architecture TEST of branch_comparator_TB is 

  -- component branch_comparator is
  --   port (
  --     IsBranch         : in std_logic;
  --     funct3 : in std_logic_vector(2 downto 0);
  --     sel_fwd_branch_1 : in std_logic;
  --     sel_fwd_branch_2 : in std_logic;
  --     register_file_output_1 : in std_logic_vector(63 downto 0);
  --     register_file_output_2 : in std_logic_vector(63 downto 0);
  --     ALU_output_EX_MEM      : in std_logic_vector(63 downto 0);
  --     BranchCmp        : out std_logic
  --   );
  -- end component branch_comparator;

  signal IsBranch : std_logic;
  signal funct3 : std_logic_vector(2 downto 0);
  signal sel_fwd_branch_1 : std_logic;
  signal sel_fwd_branch_2 : std_logic;
  signal register_file_output_1 : std_logic_vector(63 downto 0);
  signal register_file_output_2 : std_logic_vector(63 downto 0);
  signal ALU_output_EX_MEM      : std_logic_vector(63 downto 0);
  signal BranchCmp         : std_logic;

begin
    
  STIMULUS_GEN: process
  begin
    wait for 10 ns;
      IsBranch <= '0';
      funct3 <= "XXX";
      sel_fwd_branch_1 <= '0'; -- operand 1 is reg_out
      sel_fwd_branch_2  <= '0'; -- operand 2 is reg_out
      register_file_output_1 <= X"0000000000000001"; -- 1 
      register_file_output_2 <= X"0000000000000011"; -- 3
      ALU_output_EX_MEM <= X"0000000000000001"; -- 1
      --Expect BranchCmp = 1 (default for no IsBranch)

    wait for 10 ns;
      IsBranch <= '1';
      funct3 <= "000"; -- BEQ
      sel_fwd_branch_1 <= '0'; -- operand 1 is reg_out
      sel_fwd_branch_2  <= '0'; -- operand 2 is reg_out
      register_file_output_1 <= X"0000000000000001"; -- 1 
      register_file_output_2 <= X"0000000000000011"; -- 3
      ALU_output_EX_MEM <= X"0000000000000001"; -- 1
      --Expect BranchCmp = 0 (IsBranch but not taken)

    wait for 10 ns;
      IsBranch <= '1';
      funct3 <= "000"; -- BEQ
      sel_fwd_branch_1 <= '0'; -- operand 1 is reg_out
      sel_fwd_branch_2  <= '1'; -- operand 2 is alu_out
      register_file_output_1 <= X"0000000000000001"; -- 1 
      register_file_output_2 <= X"0000000000000011"; -- 3
      ALU_output_EX_MEM <= X"0000000000000001"; -- 1
      --Expect BranchCmp = 1 (branch taken)
    
    wait for 10 ns;
      IsBranch <= '1';
      funct3 <= "000"; -- BEQ
      sel_fwd_branch_1 <= '0'; -- operand 1 is reg_out
      sel_fwd_branch_2  <= '0'; -- operand 1 is reg_out
      register_file_output_1 <= X"F400050001000001"; --
      register_file_output_2 <= X"F400050001000001"; -- equal
      ALU_output_EX_MEM <= X"0000000000000001"; -- unused
      --Expect BranchCmp = 1 (branch taken)
    
    wait for 10 ns;
      IsBranch <= '1';
      funct3 <= "001"; -- BNE
      sel_fwd_branch_1 <= '0'; -- operand 1 is reg_out
      sel_fwd_branch_2  <= '0'; -- operand 2 is reg_out
      register_file_output_1 <= X"F000000000000001"; -- 
      register_file_output_2 <= X"F000000000000011"; -- not equal
      ALU_output_EX_MEM <= X"0000000000000001"; -- unused
      --Expect BranchCmp = 1 (branch taken)
    
    wait for 10 ns;
      IsBranch <= '1';
      funct3 <= "001"; -- BNE
      sel_fwd_branch_1 <= '0'; -- operand 1 is reg_out
      sel_fwd_branch_2  <= '0'; -- operand 2 is reg_out
      register_file_output_1 <= X"F000F00500040011"; --  
      register_file_output_2 <= X"F000F00500040011"; -- equal
      ALU_output_EX_MEM <= X"0000000000000001"; -- unused
      --Expect BranchCmp = 0 (IsBranch but not taken)

    wait for 10 ns;
      IsBranch <= '1';
      funct3 <= "100"; -- BLT
      sel_fwd_branch_1 <= '1'; -- operand 1 is alu_out
      sel_fwd_branch_2  <= '0'; -- operand 2 is reg_out
      register_file_output_1 <= X"7200000000000001"; -- unused
      register_file_output_2 <= X"7000000000000001"; -- operand2
      ALU_output_EX_MEM <= X"0000000000000001"; -- operand1<operand2
      --Expect BranchCmp = 1 (branch taken)
    
    wait for 10 ns;
      IsBranch <= '1';
      funct3 <= "100"; -- BLT
      sel_fwd_branch_1 <= '1'; -- operand 1 is alu_out
      sel_fwd_branch_2  <= '0'; -- operand 2 is reg_out
      register_file_output_1 <= X"7200000000000001"; -- unused
      register_file_output_2 <= X"F000000000000001"; -- operand2 (now negative)
      ALU_output_EX_MEM <= X"0000000000000001"; -- operand1>operand2
      --Expect BranchCmp = 0 (IsBranch but not taken)
      
    wait for 10 ns;
      IsBranch <= '1';
      funct3 <= "100"; -- BLT
      sel_fwd_branch_1 <= '1'; -- operand 1 is alu_out
      sel_fwd_branch_2  <= '0'; -- operand 2 is reg_out
      register_file_output_1 <= X"F200000000000001"; -- unused
      register_file_output_2 <= X"80FFF00000000001"; -- operand2 (negative)
      ALU_output_EX_MEM <= X"00C0300000A00001"; -- operand1>operand2
      --Expect BranchCmp = 0 (IsBranch but not taken)
    
    wait for 10 ns;
      IsBranch <= '1';
      funct3 <= "110"; -- BLTU
      sel_fwd_branch_1 <= '0'; -- operand 1 is reg_out
      sel_fwd_branch_2  <= '0'; -- operand 2 is reg_out
      register_file_output_1 <= X"8000000000000000"; -- operand1 (would be negative if signed)
      register_file_output_2 <= X"7000000000000000"; -- operand2<operand1 bec. unsigned
      ALU_output_EX_MEM <= X"F000000000000001"; -- unused
      --Expect BranchCmp = 0 (IsBranch but not taken)
    
    wait for 10 ns;
      IsBranch <= '1';
      funct3 <= "110"; -- BLTU
      sel_fwd_branch_1 <= '0'; -- operand 1 is reg_out
      sel_fwd_branch_2  <= '0'; -- operand 2 is reg_out
      register_file_output_1 <= X"7000000000000000"; -- operand1
      register_file_output_2 <= X"8000000000000000"; -- operand1<operand2 bec. unsigned
      ALU_output_EX_MEM <= X"F000000000000001"; -- unused
      --Expect BranchCmp = 1 (brunch taken)
    
    -- need to test others
    wait for 100 ns;   
    
  end process STIMULUS_GEN;


  DUT: entity work.branch_comparator
  Port Map (
    IsBranch => IsBranch,
		funct3 => funct3,
		sel_fwd_branch_1 => sel_fwd_branch_1,
		sel_fwd_branch_2 => sel_fwd_branch_2,
		register_file_output_1 => register_file_output_1,
		register_file_output_2 => register_file_output_2,
		ALU_output_EX_MEM => ALU_output_EX_MEM,
		BranchCmp => BranchCmp );
  end architecture TEST;

