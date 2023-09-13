library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux_3_1 is
	port (
		selection : in std_logic_vector(1 downto 0);
		input_0, input_1, input_2 : in std_logic_vector(63 downto 0);
		output_0 : out std_logic_vector(63 downto 0)
	);
end mux_3_1;

architecture behavioral of mux_3_1 is
begin
  -- mux_3_1_proc : process(selection, input_0, input_1, input_2)
  -- begin
  --   case selection is
  --     when "00"    => output_0 <= input_0;
  --     when "01"    => output_0 <= input_1;
  --     when "10"    => output_0 <= input_2;
  --     when others  => output_0 <= X"0000000000000000";
  --   end case;
  -- end process mux_3_1_proc;
  with selection select
    output_0 <=
    input_0 when "00",
    input_1 when "01",
    input_2 when "10",
    X"0000000000000000" when others;
end architecture behavioral;