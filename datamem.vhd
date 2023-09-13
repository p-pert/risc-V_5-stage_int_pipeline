library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.common.all;

entity datamem is
  port (
    clock : in  std_logic;
    write_enable : in  std_logic;
    address : in  std_logic_vector(MEMBANK_ADDRESS_range downto 0);
    datain  : in  std_logic_vector(7 downto 0);
    dataout : out std_logic_vector(7 downto 0)
  );
end entity datamem;


architecture RTL of datamem is
  signal membank_506, membank_507, membank_508, membank_509, membank_510, membank_511 : std_logic_vector(7 downto 0);

  type ram_type is array (0 to (MEM_SIZE_in_banks - 1)) of std_logic_vector(7 downto 0);
  signal ram : ram_type := (others => (others => '0'));
  signal read_address : std_logic_vector(MEMBANK_ADDRESS_range downto 0);

begin

 RamProc: process(clock, write_enable, datain, address)

 begin
   if falling_edge(clock) then
     if write_enable = '1' then
       ram(to_integer(unsigned(address))) <= datain;
     end if;

       read_address <= address;
   end if;
 end process RamProc;

 dataout <= ram(to_integer(unsigned(address)));

 -- debug/test bubble_sort.c --
      -- some locations for visualizing in gtkwave
 membank_511 <= ram(511);
 membank_510 <= ram(510);
 membank_509 <= ram(509);
 membank_508 <= ram(508);
 membank_507 <= ram(507);
 membank_506 <= ram(506);

end architecture RTL;