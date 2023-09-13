library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity program_counter_TB is
end program_counter_TB;

architecture TEST of program_counter_TB is 	

  -- component program_counter is
  -- port (	
  --   clock, reset : in std_logic;
  --   Stall        : in std_logic;

  --   new_PC : in std_logic_vector(63 downto 0);
  --   PC     : out  std_logic_vector(63 downto 0)
  -- );
  -- end component;

  signal clock : std_logic := '0';
  signal reset : std_logic := '0';
  signal Stall : std_logic := '0';

  signal new_PC, PC : std_logic_vector(63 downto 0);

  -- simulation specific
  constant clock_period : time    := 10 ns;  -- 100 MHz

begin

  -- -- create a clock
  -- clock <= '0' when done else (NOT clock) after clock_period / 2;

  -- Generatore del clock

  clock_GEN: process
  begin
    clock <= '0';
    wait for clock_period/2;
    clock <= '1';
    wait for clock_period/2;
  end process clock_GEN;

  STIMULUS_GEN: process
  begin
      reset <= '0'; -- no reset @ powerup...
      Stall <= '0';
      new_PC <= X"0000000000000000";
                  
    wait for 50 ns;
      reset <= '1'; -- resetting.....
    wait for 20 ns;
      reset <= '0'; -- end reset
    wait for 47 ns; -- powerupped

  -- After reset PC should be 0. 
  -- Now input a new_PC increased to 4, 3ns before the rising edge of the clock
      new_PC <= X"0000000000000004";
      -- PC should update to 4
    wait for 3 ns;
    -- new clock cycle begins. 
    -- Before it completes the instructions in the pipeline stages
    -- should serve the new_PC to the program counter register:
    wait for 7 ns;
      new_PC <= X"0000000000000008";
    wait for 3 ns; -- cycle completed
    -- new cycle
    wait for 7 ns; -- now letr's try a Stall
      Stall <= '1';
      new_PC <= X"000000000000000C";
    wait for 3 ns; -- cycle completed
    -- new cycle
    wait for 7 ns;
      Stall <= '0'; -- in this cycle stall returns to 0
      new_PC <= X"000000000000000C";
    
    wait for 10 ns; 
      Stall <= '0'; -- now PC should update to 000C

    wait for 200 ns;
      reset <= '1';
    wait for 200 ns;
      reset <= '0';
    wait for 200 ns;
      Stall <= '1';
      new_PC <= X"0000000000000004";
    
    wait for 200 ns;
      reset <= '1';
    wait for 200 ns;
      reset <= '0';
    wait for 200 ns;
      new_PC <= X"0000000000000004";
      Stall <= '1';  
  
    wait for 150000 ns;
  end process STIMULUS_GEN;

DUT: entity work.program_counter
  Port Map (
    clock => clock,
    reset => reset,
    Stall => Stall,
    new_PC => new_PC,
    PC => PC);

end architecture TEST;