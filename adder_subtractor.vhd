library ieee;
use ieee.std_logic_1164.all;

entity ADDER_SUBTR is
  generic (N: integer:= 4);
  port( addsub : in std_logic;
        a, b : in std_logic_vector (N-1 downto 0);
        s : out std_logic_vector (N-1 downto 0);
        overflow : out std_logic;
        c_out : out std_logic);
end ADDER_SUBTR;

architecture structure of ADDER_SUBTR is
  component FullAdder
    port( a, b, c_in : in std_logic;
          s, c_out : out std_logic);
  end component;

  signal c: std_logic_vector (N downto 0);
  signal ba: std_logic_vector (N-1 downto 0);

begin
  c(0) <= addsub; c_out <= c(N);
  overflow <= c(N) xor c(N-1);
  gi: for i in 0 to N-1 generate
    ba(i) <= b(i) xor addsub;
    fi: FullAdder port map (a=>a(i),b=>ba(i),c_in=>c(i),
                            s=>s(i),c_out=>c(i+1));
  end generate;
end structure;