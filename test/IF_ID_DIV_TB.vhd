library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity IF_ID_DIV_TB is
end IF_ID_DIV_TB;

architecture TEST of IF_ID_DIV_TB is 

-- component IF_ID_DIV is
--   port (
--     --INPUTS

--     clock, clear : in std_logic;
--     Flush, Stall: in std_logic;

--     --Data
--     instruction_address_in : in std_logic_vector(63 downto 0);
--     instruction_data_in : in std_logic_vector(31 downto 0);

--     --OUTPUTS

--     --Data
--     instruction_address_out : out std_logic_vector(63 downto 0);
--     instruction_data_out : out std_logic_vector(31 downto 0)

--   );
  signal clock, clear, Flush, Stall: std_logic := '0';
  signal instruction_address_in : std_logic_vector(63 downto 0) := (others => '0');
  signal instruction_data_in : std_logic_vector(31 downto 0) := (others => '0');
  signal instruction_address_out : std_logic_vector(63 downto 0);
  signal instruction_data_out : std_logic_vector(31 downto 0);

  constant clock_period : time    := 10 ns;  -- 100 MHz

begin

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
      clear <= '0'; -- no clear @ powerup...                 
    wait for 20 ns;
      clear <= '1'; -- clearing.....
    wait for 20 ns;
      clear <= '0'; -- end clear
    wait for 3 ns;
      instruction_address_in <= X"0000000000000004";
      instruction_data_in <= X"00000001";
      Flush <= '0';
    wait for 10 ns;
      instruction_address_in <= X"0000000000000008";
      instruction_data_in <= X"00000010";
      Flush <= '0';
    wait for 10 ns;
      instruction_address_in <= X"000000000000000C";
      instruction_data_in <= X"00010010";
      Flush <= '1';
    wait for 10 ns;
      instruction_address_in <= X"0000000000000004";
      instruction_data_in <= X"00000010";
      Flush <= '0';
    wait for 4 ns;
      instruction_address_in <= X"0000000000000008";
      instruction_data_in <= X"10000000";
      Flush <= '0';
    wait for 6 ns;
      instruction_address_in <= X"0000000000000000";
      instruction_data_in <= X"00000000";
      Flush <= '0';
    wait for 10 ns;
      instruction_address_in <= X"0000000000001000";
      instruction_data_in <= X"00000100";
      Flush <= '0';
      Stall <= '1';
    wait for 10 ns;
      instruction_address_in <= X"0000000000001000";
      instruction_data_in <= X"00000100";
      Flush <= '0';
      Stall <= '0';

    wait for 100 ns;   
    
  end process STIMULUS_GEN;


  DUT: entity work.IF_ID_DIV
  port map (
    clock => clock,
    clear => clear,
    Flush => Flush,
    Stall => Stall,
    instruction_address_in => instruction_address_in,
    instruction_data_in => instruction_data_in,
    instruction_address_out => instruction_address_out,
    instruction_data_out => instruction_data_out);
  end architecture TEST;

