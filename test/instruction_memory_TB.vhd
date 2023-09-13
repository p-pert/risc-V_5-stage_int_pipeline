library IEEE;
use ieee.std_logic_1164.all;

entity instruction_memory_TB is
end instruction_memory_TB;

architecture TEST of instruction_memory_TB is 	

  signal pc_in : std_logic_vector(63 downto 0);
  signal instruction_out : std_logic_vector(31 downto 0);

begin

  STIMULUS_GEN: process
  begin
      pc_in <= (others => '0');
                  
    wait for 50 ns;
    pc_in <= X"0000000000000004";
    wait for 50 ns;
    pc_in <= X"0000000000000008";
    wait for 50 ns;
    pc_in <= X"000000000000000C";
    wait for 50 ns;
    pc_in <= X"0000000000000004";
    wait for 50 ns;
    pc_in <= X"0000000000000008";
    wait for 50 ns;
    pc_in <= X"0000000000000020";
    wait for 50 ns;
    pc_in <= X"0000000000000024"; -- with current ins_memory, should be going overbounds and taken as pc=0
    wait for 50 ns;
    pc_in <= X"0000000000000028"; -- same
    wait for 50 ns;
    pc_in <= X"0000000000000002"; -- with current ins_memory, should be taken as if pc=0
    wait for 50 ns;
    pc_in <= X"0000000000000005"; -- should be taken as if pc=4
    
  
    wait for 1500 ns;
  end process STIMULUS_GEN;

DUT: entity work.instruction_memory
  Port Map (
    pc_in => pc_in,
    instruction_out => instruction_out
    );

end architecture TEST;