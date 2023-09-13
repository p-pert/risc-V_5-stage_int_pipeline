library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity FullAdder is
port (	a: in std_logic;
	b: in std_logic;
	c_in: in std_logic;
	s: out std_logic;
        c_out: out std_logic);
end FullAdder;

architecture BEHAVIORAL of FullAdder is 	
begin

  s <= a xor b xor c_in;
  c_out <= (b and c_in) or (a and b) or (a and c_in);

end BEHAVIORAL;					
