-- File       : multiplier_TB.vhd


library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity multiplier_TB is
end multiplier_TB;

architecture TEST of multiplier_TB is 

-- component multiplier is
  -- port ( 
  -- clock : in std_logic; 
  -- clear : in std_logic;
  -- A : in std_logic_vector(63 downto 0 );
  -- B : in std_logic_vector(63 downto 0 );
  -- IsM : in std_logic;
  -- result : out std_logic_vector(127 downto 0);
  -- M_IsActive : out std_logic
  -- -- Stall_M : out std_logic
-- );
-- end component multiplier;


signal clock : std_logic := '0';
signal clear : std_logic := '0';
signal A : std_logic_vector(63 downto 0 ) := (others => '0');
signal B : std_logic_vector(63 downto 0 ) := (others => '0');
signal IsM : std_logic := '0';

signal result : std_logic_vector(127 downto 0);
signal M_IsActive : std_logic;

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
      A <= (others => '0');
      B <= (others => '0');
    wait for 95 ns; 
      A(2) <= '1'; -- A=4
      B(4) <= '1'; -- B=16
      IsM  <= '1';
    wait for 1000 ns;
      IsM <= '0';
    wait for 200 ns;
      A <= (others=>'1'); 
      B <= (others=>'1'); 
      IsM  <= '1';
      -- THE RESULT SHOULD BE FFFFFFFFFFFFFFFE0000000000000001 (3.4028237e+38)
    wait for 1000 ns;


  end process STIMULUS_GEN;


  DUT: entity work.multiplier
  port map (
    clock => clock,
    clear => clear,
    A => A,
    B => B, 
    IsM => IsM,
    result => result,
    M_IsActive => M_IsActive
  );
  end architecture TEST;
