-- File       : datapath_TB.vhd


library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;
use work.common.all;

entity datapath_TB is
end datapath_TB;

architecture TEST of datapath_TB is 

-- component datapath is
--   port(
--     clock, reset : in std_logic;
--     debug_regbank_array : out t_regbank_array
-- );
-- end component datapath;

  signal clock : std_logic := '0';
  signal reset : std_logic := '0';

  signal debug_regbank_array : t_regbank_array := (others => (others => '0'));
  signal debug_write_enable : boolean := FALSE;

  -- simulation specific
  constant clock_period : time    := 10 ns;  -- 100 MHz

begin

  -- Generatore del clock

  clock_GEN: process
  begin
    clock <= '1';
    wait for clock_period/2;
    clock <= '0';
    wait for clock_period/2;
  end process clock_GEN;
    
  STIMULUS_GEN: process
    begin
      reset <= '1';                  
    wait for 27 ns;
      reset <= '0'; -- end reset
    wait for 3 ns;
    wait for 8500 ns;
      debug_write_enable <= TRUE;
    wait for 100 ns;
  end process STIMULUS_GEN;

  DUT: entity work.datapath
  port map (
    clock => clock,
		reset => reset,
    debug_regbank_array => debug_regbank_array);

    -- debug_WRITING_REG_FILE_DATA: process(debug_write_enable) is
    --   file reg_data_file    : text open write_mode is "output_file.txt";
    --   variable row          : line;
      
    -- begin
    --   if(debug_write_enable) then
    --     report "****** Writing on output_file.txt ******";
    --     for i in 0 to 31 loop
    --       write(row, character('x'), left , 1);
    --       write(row, i, left , 10);
    --       write(row, to_bitvector(debug_regbank_array(i)), right, 64);
    --       writeLine(reg_data_file, row);
    --     end loop;
    --   end if;
    -- end process debug_WRITING_REG_FILE_DATA;

end architecture TEST;



