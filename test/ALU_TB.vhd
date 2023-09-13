-- File       : ALU_TB.vhd

library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity ALU_TB is
end ALU_TB;

architecture TEST of ALU_TB is 

  -- component ALU is
  -- 	port (
        -- operand_1, operand_2 : in std_logic_vector(63 downto 0);
        -- ALUOp : in std_logic_vector(1 downto 0);
        -- insn_bit_30 : in std_logic;
        -- funct3 : in std_logic_vector(2 downto 0);
        -- ALU_output : out std_logic_vector(63 downto 0)
  -- 	);
  -- end component ALU;

  signal operand_1, operand_2 : std_logic_vector(63 downto 0);
  signal ALUOp : std_logic_vector(1 downto 0);
  signal insn_bit_30 : std_logic;
  signal funct3 : std_logic_vector(2 downto 0);
  signal ALU_output : std_logic_vector(63 downto 0);

begin
    
  STIMULUS_GEN: process
    begin
    wait for 10 ns;
      operand_1 <= X"7200000000000001"; -- don't care
      operand_2 <= X"1200000500000001"; -- don't care
      ALUOp <= "01"; -- BRANCH
      insn_bit_30 <= '1'; -- don't care
      funct3 <= "010"; -- don't care

    wait for 10 ns;
      operand_1 <= X"0000000000000006"; -- 6
      operand_2 <= X"0000000000000001"; -- 1
      ALUOp <= "00"; -- LOAD / STORE expect ALU_output = 6+1
      insn_bit_30 <= '0'; -- don't care
      funct3 <= "011"; -- don't care


    wait for 10 ns;
      operand_1 <= X"FFFFFFFFFFFFFFFF"; -- now try with a negatvie number -1
      operand_2 <= X"0000000000000006"; -- 6
      ALUOp <= "00"; -- LOAD / STORE expect ALU_output = -1+6
      insn_bit_30 <= '0'; -- don't care
      funct3 <= "011"; -- don't care

    wait for 10 ns;
      operand_1 <= X"0000000000000006"; -- 6
      operand_2 <= X"0000000000000006"; -- 6
      ALUOp <= "10"; -- R-type / I-type 
      insn_bit_30 <= '1'; -- SUB expect ALU_output = 6-6
      funct3 <= "000"; -- ADD/SUB (check above)
    
    wait for 10 ns;
      operand_1 <= X"0000000000000001"; -- 1
      operand_2 <= X"0000000000000004"; -- 4
      ALUOp <= "10"; -- R-type / I-type 
      insn_bit_30 <= '0'; -- don't care
      funct3 <= "001"; -- SLL expect ALU_output =0...0001 shifted-logically by 4 bits left

    wait for 10 ns;
      operand_1 <= X"8800000000000001"; --
      operand_2 <= X"00000000FFFFFFF0"; -- only lower five bits will be taken for shifting so 10000 (16 decimal)
      ALUOp <= "10"; -- R-type / I-type 
      insn_bit_30 <= '0'; -- SRL expect ALU_output =10001000...01 shifted-logically by 16 bits right
      funct3 <= "101"; -- SRL/SRA (check above)

    wait for 10 ns;
      operand_1 <= X"8800000000000001"; -- 
      operand_2 <= X"00000000FFFFFFF0"; -- only lower five bits will be taken for shifting so 10000 (16 decimal)
      ALUOp <= "10"; -- R-type / I-type 
      insn_bit_30 <= '1'; -- SRA expect ALU_output =10001000...01 shifted-arithmetically by 16 bits right
      funct3 <= "101"; -- SRL/SRA (check above)

    wait for 10 ns;
      operand_1 <= X"800000000000001F"; -- negative
      operand_2 <= X"00000000000000FF"; -- positive
      ALUOp <= "10"; -- R-type / I-type 
      insn_bit_30 <= 'U'; -- don't care
      funct3 <= "010"; -- SLT expect ALU_output = 1
    
    wait for 10 ns;
      operand_1 <= X"0000000000000004"; -- 1
      operand_2 <= X"0000000000000001"; -- 4
      ALUOp <= "10"; -- R-type / I-type 
      insn_bit_30 <= 'U'; -- don't care
      funct3 <= "010"; -- SLT expect ALU_output = 0
    
    wait for 10 ns;
      operand_1 <= X"0000000000000000"; -- 0
      operand_2 <= X"80000000000000FF"; -- would be negative, but taken unsigned
      ALUOp <= "10"; -- R-type / I-type 
      insn_bit_30 <= 'X'; -- don't care
      funct3 <= "011"; -- SLTU expect ALU_output = 1
    
    wait for 10 ns;
      operand_1 <= X"0000000000000000"; -- 0
      operand_2 <= X"0000000000000000"; -- 0
      ALUOp <= "10"; -- R-type / I-type 
      insn_bit_30 <= 'X'; -- don't care
      funct3 <= "011"; -- SLTU expect ALU_output = 0
      
    -- other tests...
      
    wait for 100 ns;   
    
  end process STIMULUS_GEN;


  DUT: entity work.ALU
  port map (
    operand_1 => operand_1,
		operand_2 => operand_2,
		ALUOp => ALUOp,
		insn_bit_30 => insn_bit_30,
		funct3 => funct3,
		ALU_output => ALU_output
		);
  end architecture TEST;

