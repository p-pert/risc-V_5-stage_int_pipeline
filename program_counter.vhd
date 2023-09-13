-- File       : program_counter.vhd

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity program_counter is
port (
  clock, reset : in std_logic;
  Stall        : in std_logic;

  new_PC : in std_logic_vector(63 downto 0);
  PC     : out  std_logic_vector(63 downto 0)
);
end program_counter;

architecture Behavioral of program_counter is

  signal load : std_logic := '1';

begin

  load <= (NOT Stall); -- when Stall = '1' won't update register
  internal_register : entity work.reg_64b port map(new_PC, load , clock, reset, PC);

  end Behavioral;