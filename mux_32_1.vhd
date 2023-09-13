-- File       : mux_32_1.vhd

library ieee;
use ieee.std_logic_1164.all;

entity mux_32_1 is
	port (
		selection : in std_logic_vector(4 downto 0);
		input_0, input_1, input_2, input_3, input_4, input_5, input_6, input_7, input_8, input_9, input_10, input_11, input_12, input_13, input_14, input_15, input_16, input_17,
		input_18, input_19, input_20, input_21, input_22, input_23, input_24, input_25, input_26, input_27, input_28, input_29, input_30, input_31 : in std_logic_vector(63 downto 0);
		output_0 : out std_logic_vector(63 downto 0)
	);
end mux_32_1;

architecture behavioral of mux_32_1 is
begin
  -- mux_32_1_proc: process(selection, input_0, input_1, input_2, input_3, input_4, input_5, input_6, input_7, input_8, input_9, input_10, input_11, input_12, input_13, input_14, input_15, input_16, input_17,
  -- input_18, input_19, input_20, input_21, input_22, input_23, input_24, input_25, input_26, input_27, input_28, input_29, input_30, input_31)
  -- begin   
  --   case selection is
  --     when "00000" => output_0 <= input_0;
  --     when "00001" => output_0 <= input_1; 
  --     when "00010" => output_0 <= input_2; 
  --     when "00011" => output_0 <= input_3; 
  --     when "00100" => output_0 <= input_4; 
  --     when "00101" => output_0 <= input_5; 
  --     when "00110" => output_0 <= input_6; 
  --     when "00111" => output_0 <= input_7; 
  --     when "01000" => output_0 <= input_8; 
  --     when "01001" => output_0 <= input_9; 
  --     when "01010" => output_0 <= input_10;
  --     when "01011" => output_0 <= input_11;
  --     when "01100" => output_0 <= input_12;
  --     when "01101" => output_0 <= input_13;
  --     when "01110" => output_0 <= input_14;
  --     when "01111" => output_0 <= input_15;
  --     when "10000" => output_0 <= input_16;
  --     when "10001" => output_0 <= input_17;
  --     when "10010" => output_0 <= input_18;
  --     when "10011" => output_0 <= input_19;
  --     when "10100" => output_0 <= input_20;
  --     when "10101" => output_0 <= input_21;
  --     when "10110" => output_0 <= input_22;
  --     when "10111" => output_0 <= input_23;
  --     when "11000" => output_0 <= input_24;
  --     when "11001" => output_0 <= input_25;
  --     when "11010" => output_0 <= input_26;
  --     when "11011" => output_0 <= input_27;
  --     when "11100" => output_0 <= input_28;
  --     when "11101" => output_0 <= input_29;
  --     when "11110" => output_0 <= input_30;
  --     when "11111" => output_0 <= input_31;
  --     when others  => output_0 <= X"0000000000000000";
  --   end case;
  -- end process mux_32_1_proc;

  with selection select
    output_0 <=
    input_0 when "00000",
    input_1 when "00001",
    input_2 when "00010",
    input_3 when "00011",
    input_4 when "00100",
    input_5 when "00101",
    input_6 when "00110",
    input_7 when "00111",
    input_8 when "01000",
    input_9 when "01001",
    input_10 when "01010",
    input_11 when "01011",
    input_12 when "01100",
    input_13 when "01101",
    input_14 when "01110",
    input_15 when "01111",
    input_16 when "10000",
    input_17 when "10001",
    input_18 when "10010",
    input_19 when "10011",
    input_20 when "10100",
    input_21 when "10101",
    input_22 when "10110",
    input_23 when "10111",
    input_24 when "11000",
    input_25 when "11001",
    input_26 when "11010",
    input_27 when "11011",
    input_28 when "11100",
    input_29 when "11101",
    input_30 when "11110",
    input_31 when "11111",
    X"0000000000000000" when others;
end architecture behavioral;