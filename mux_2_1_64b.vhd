library ieee;
use ieee.std_logic_1164.all;

entity mux_2_1_64b is
	port (
		selection : in std_logic;
		input_0, input_1 : in std_logic_vector(63 downto 0);
		output_0 : out std_logic_vector(63 downto 0)
	);
end mux_2_1_64b;

architecture behavioral of mux_2_1_64b is
begin
  -- mux_2_1_64b_proc : process(selection, input_0, input_1)
  -- begin
	--   case selection is
  --     when '0'    => output_0 <= input_0;
  --     when '1'    => output_0 <= input_1;
  --     when others => output_0 <= input_0;
  --   end case;
  -- end process mux_2_1_64b_proc;
  with selection select
    output_0 <=
    input_0 when '0',
    input_1 when '1',
    input_0 when others;
end architecture behavioral;