-- File       : multiplier_divider_TB.vhd


library IEEE;
use ieee.std_logic_1164.all;
use work.all;
use work.common.all

entity multiplier_divider_TB is
end multiplier_divider_TB;

architecture TEST of multiplier_divider_TB is 

-- component multiplier_divider is
  -- port (
  --   clock : in std_logic;
  --   clear : in std_logic;
  --   A : in std_logic_vector(63 downto 0 );
  --   B : in std_logic_vector(63 downto 0 );
  --   IsM : in std_logic;
  --   IsD : in std_logic;
  --   IsSignedOp : in std_logic;
  --   DorW : in std_logic;
  --   result : out std_logic_vector(127 downto 0);
  --   BUSY : out std_logic;
  --   exc_type : out exc_type_t
  --   );
-- end component multiplier_divider;


signal clock : std_logic := '0';
signal clear : std_logic := '0';
signal A : std_logic_vector(63 downto 0 ) := (others => '0');
signal B : std_logic_vector(63 downto 0 ) := (others => '0');
signal IsM : std_logic := '0';
signal IsD : std_logic := '0';
signal IsSignedOp : std_logic := '1';
signal DorW : std_logic := '0'; -- double or word

signal result : std_logic_vector(127 downto 0);
signal BUSY : std_logic;
signal exc_type : exc_type_t;

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
      -- DorW <= '1';
      A <= (others => '0');
      B <= (others => '0');
    wait for 95 ns; 
      A(2) <= '1'; -- A=4
      B(4) <= '1'; -- B=16
      IsM  <= '1';
      IsSignedOp <= '0';
    wait for 800 ns;
      A <= (others=>'0'); 
      B <= (others=>'0'); 
      IsM <= '0';
    wait for 20 ns;
      A <= (others=>'1'); 
      B <= (others=>'1'); 
      IsM  <= '1';
      -- THE RESULT SHOULD BE FFFFFFFFFFFFFFFE0000000000000001 (3.4028237e+38)
    wait for 800 ns;
      A <= (others=>'0'); 
      B <= (others=>'0'); 
      IsM  <= '0';
    wait for 20 ns;
      A(4) <= '1'; --16
      B(2) <= '1'; --4
      IsD  <= '1';
    wait for 800 ns;
      A <= (others=>'0'); 
      B <= (others=>'0'); 
      IsD  <= '0';
    wait for 20 ns;
      A(4) <= '1'; 
      A(0) <= '1'; --A=17
      B(2) <= '1'; --B=4
      IsD  <= '1';
    wait for 800 ns;
      A <= (others=>'0'); 
      B <= (others=>'0'); 
      IsD  <= '0';
    wait for 20 ns;
      A <= X"FFFFFFFFFFFFFFF0"; -- A = -16
      B <= X"FFFFFFFFFFFFFFFC"; -- B = -4 
      IsM  <= '1';
      IsSignedOp <= '1';
    wait for 800 ns;
      A <= (others=>'0'); 
      B <= (others=>'0'); 
      IsM  <= '0';
    wait for 20 ns;
      A <= X"FFFFFFFFFFFFFFF0"; -- A = -16
      B <= X"FFFFFFFFFFFFFFFC"; -- B = -4 
      IsD  <= '1';
    wait for 800 ns;
      A <= (others=>'0'); 
      B <= (others=>'0'); 
      IsD  <= '0';
    wait for 20 ns;
      A <= X"FFFFFFFFFFFFFFF0"; -- A = -16
      B(2) <= '1'; -- B = 4 
      IsM  <= '1'; --expect result = -64 (FFFF...FFC0) 
    wait for 800 ns;
      A <= (others=>'0'); 
      B <= (others=>'0'); 
      IsM  <= '0';
    wait for 20 ns;
      A <= X"FFFFFFFFFFFFFFFC"; -- A = -4
      B(4) <= '1'; -- B = 16 
      IsD  <= '1'; --expect result = 0 WITH remaninder =-4 so 128 bits written: [FFFF...FFFC]&[0000...0000]  
    wait for 800 ns;
      A <= (others=>'0'); 
      B <= (others=>'0'); 
      IsD  <= '0';
    wait for 20 ns;
      A <= X"FF3FFFFeFFF01F1C"; -- A = who cares
      -- B = 0 
      IsM  <= '1'; 
    wait for 800 ns;
      A <= (others=>'0'); 
      B <= (others=>'0'); 
      IsM  <= '0';
    wait for 20 ns;
      A <= X"FFFFFFFFFFFFFFFC"; -- A = -4
      -- B = 0 
      IsD  <= '1'; -- division by zero
    wait for 800 ns;
      A <= (others=>'0'); 
      B <= (others=>'0'); 
      IsD  <= '0';
    wait for 20 ns;

  end process STIMULUS_GEN;


  DUT: entity work.multiplier_divider
  port map (
    clock => clock,
    clear => clear,
    A => A,
    B => B, 
    IsM => IsM,
    IsD => IsD,
    IsSignedOp => IsSignedOp,
    DorW => DorW,
    result => result,
    BUSY => BUSY, 
    exc_type => exc_type
  );
  end architecture TEST;
