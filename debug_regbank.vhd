-- File       : debug_regbank.vhd

-- For visualizing registers content in gtkwave

library IEEE;
use ieee.std_logic_1164.all;
use work.common.all;

entity debug_regbank is
  port (
  debug_regbank_array: in t_regbank_array
  );
end debug_regbank;

architecture behavioural of debug_regbank is
  signal x0_reg_data : std_logic_vector(63 downto 0);
	signal x1_reg_data : std_logic_vector(63 downto 0);
	signal x2_reg_data : std_logic_vector(63 downto 0);
	signal x3_reg_data : std_logic_vector(63 downto 0);
	signal x4_reg_data : std_logic_vector(63 downto 0);
	signal x5_reg_data : std_logic_vector(63 downto 0);
	signal x6_reg_data : std_logic_vector(63 downto 0);
	signal x7_reg_data : std_logic_vector(63 downto 0);
  signal x8_reg_data : std_logic_vector(63 downto 0);
	signal x9_reg_data : std_logic_vector(63 downto 0);
	signal x10_reg_data : std_logic_vector(63 downto 0);
	signal x11_reg_data : std_logic_vector(63 downto 0);
	signal x12_reg_data : std_logic_vector(63 downto 0);
	signal x13_reg_data : std_logic_vector(63 downto 0);
	signal x14_reg_data : std_logic_vector(63 downto 0);
	signal x15_reg_data : std_logic_vector(63 downto 0);
	signal x16_reg_data : std_logic_vector(63 downto 0);
	signal x17_reg_data : std_logic_vector(63 downto 0);
	signal x18_reg_data : std_logic_vector(63 downto 0);
	signal x19_reg_data : std_logic_vector(63 downto 0);
	signal x20_reg_data : std_logic_vector(63 downto 0);
	signal x21_reg_data : std_logic_vector(63 downto 0);
	signal x22_reg_data : std_logic_vector(63 downto 0);
	signal x23_reg_data : std_logic_vector(63 downto 0);
	signal x24_reg_data : std_logic_vector(63 downto 0);
	signal x25_reg_data : std_logic_vector(63 downto 0);
	signal x26_reg_data : std_logic_vector(63 downto 0);
	signal x27_reg_data : std_logic_vector(63 downto 0);
	signal x28_reg_data : std_logic_vector(63 downto 0);
	signal x29_reg_data : std_logic_vector(63 downto 0);
	signal x30_reg_data : std_logic_vector(63 downto 0);
	signal x31_reg_data : std_logic_vector(63 downto 0);
begin

  x0_reg_data  <= debug_regbank_array(0); 
	x1_reg_data  <= debug_regbank_array(1); 
	x2_reg_data  <= debug_regbank_array(2); 
	x3_reg_data  <= debug_regbank_array(3); 
	x4_reg_data  <= debug_regbank_array(4); 
	x5_reg_data  <= debug_regbank_array(5); 
	x6_reg_data  <= debug_regbank_array(6); 
	x7_reg_data  <= debug_regbank_array(7); 
  x8_reg_data  <= debug_regbank_array(8); 
	x9_reg_data  <= debug_regbank_array(9); 
	x10_reg_data <= debug_regbank_array(10); 
	x11_reg_data <= debug_regbank_array(11); 
	x12_reg_data <= debug_regbank_array(12); 
	x13_reg_data <= debug_regbank_array(13); 
	x14_reg_data <= debug_regbank_array(14); 
	x15_reg_data <= debug_regbank_array(15); 
	x16_reg_data <= debug_regbank_array(16); 
	x17_reg_data <= debug_regbank_array(17); 
	x18_reg_data <= debug_regbank_array(18); 
	x19_reg_data <= debug_regbank_array(19); 
	x20_reg_data <= debug_regbank_array(20); 
	x21_reg_data <= debug_regbank_array(21); 
	x22_reg_data <= debug_regbank_array(22); 
	x23_reg_data <= debug_regbank_array(23); 
	x24_reg_data <= debug_regbank_array(24); 
	x25_reg_data <= debug_regbank_array(25); 
	x26_reg_data <= debug_regbank_array(26); 
	x27_reg_data <= debug_regbank_array(27); 
	x28_reg_data <= debug_regbank_array(28); 
	x29_reg_data <= debug_regbank_array(29); 
	x30_reg_data <= debug_regbank_array(30); 
	x31_reg_data <= debug_regbank_array(31); 

  end architecture behavioural;