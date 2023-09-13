-- File       : IF_ID_DIV.vhd

library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity IF_ID_DIV is
  port (
    --INPUTS

    clock, clear : in std_logic;
    Stall : in std_logic;

    --Data
    instruction_address_in : in std_logic_vector(63 downto 0);
    instruction_data_in : in std_logic_vector(31 downto 0);

    --OUTPUTS

    --Data
    instruction_address_out : out std_logic_vector(63 downto 0);
    instruction_data_out : out std_logic_vector(31 downto 0)

  );
end IF_ID_DIV;

architecture behavioral of IF_ID_DIV is

  --INTERNAL SIGNALS

  --Data
  signal instruction_address_input_signal : std_logic_vector(63 downto 0);
  signal instruction_data_input_signal : std_logic_vector(31 downto 0);

  --Data
  signal instruction_address_output_signal : std_logic_vector(63 downto 0);
  signal instruction_data_output_signal : std_logic_vector(31 downto 0);
  
  signal data_clear : std_logic := '0';
  signal load : std_logic := '1';

  begin
  
  -- process(Stall) is
  -- begin
    load <= (NOT Stall); -- when Stall=1 won't update registers
  -- end process;

  --INTERNAL REGISTERS

  --Data
  instruction_address_reg : entity work.reg_64b port map(instruction_address_input_signal, load, clock, clear, instruction_address_output_signal);
  -- process(clear, Flush) is
  -- begin
  --   data_clear <= (clear OR Flush);
  --   report "data_clear in process assigned is !!!!" & std_logic'image(data_clear); 
  --   report "clear in process assigned is !!!!" & std_logic'image(clear);
  --   report "flush in process assigned is !!!!" & std_logic'image(Flush);
  -- end process;
  --clear_OR_Flush : entity work.OR_unit port map(clear, Flush, data_clear);
  instruction_data_reg : entity work.reg_32b port map(instruction_data_input_signal, load, clock, clear, instruction_data_output_signal);


  --WIRING INPUT PORTS
  instruction_address_input_signal <= instruction_address_in;
  instruction_data_input_signal <= instruction_data_in;

  --WIRING OUTPUT PORTS
  instruction_address_out <= instruction_address_output_signal;
  instruction_data_out <= instruction_data_output_signal;

end behavioral;