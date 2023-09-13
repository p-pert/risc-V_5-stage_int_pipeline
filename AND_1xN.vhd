-- AND between a bit and a generic N-std_logic_vector
-- The bit can be used as a control signal to let 
-- the vector pass only if ctrl='1'

library ieee;
use ieee.std_logic_1164.all;

entity AND_1xN is
  generic (N: INTEGER:= 64);
  port(
    b : in std_logic; -- bit
    v : in std_logic_vector(N-1 downto 0); -- N-vector
    v_out : out std_logic_vector(N-1 downto 0)
  );
  end AND_1xN;

  architecture structure of AND_1xN is
    begin
      gi: for i in 0 to N-1 generate
        v_out(i) <= b AND v(i);
      end generate;
  end structure;