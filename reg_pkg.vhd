-- File       : reg_pkg.vhd

-- could have used generic...
---------------------------------------------------
-- reg_64b
---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg_64b is
	port (
		reg_in : in std_logic_vector(63 downto 0);
		load, clock, clear : in std_logic;
		reg_out : out std_logic_vector(63 downto 0)
	);
end reg_64b;

architecture description of reg_64b is
	signal internal_value : std_logic_vector(63 downto 0) := X"0000000000000000";
begin
	process (clock, clear, load)
	begin
		if (clear = '1') then
			internal_value <= X"0000000000000000";
		elsif falling_edge(clock) then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		end if;

	end process;
  reg_out <= internal_value;
end description;

---------------------------------------------------
-- reg_32b
---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg_32b is
	port (
		reg_in : in std_logic_vector(31 downto 0);
		load, clock, clear : in std_logic;
		reg_out : out std_logic_vector(31 downto 0)
	);
end reg_32b;

architecture description of reg_32b is 
	signal internal_value : std_logic_vector(31 downto 0) := X"00000000";
begin
	process (clock, clear, load)
	begin
		if (clear = '1') then
			internal_value <= X"00000000";
		elsif falling_edge(clock) then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		end if;

	end process;
  reg_out <= internal_value;
end description;

---------------------------------------------------
-- reg_64b_rising edge
---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg_64b_rising_edge is
	port (
		reg_in : in std_logic_vector(63 downto 0);
		load, clock, clear : in std_logic;
		reg_out : out std_logic_vector(63 downto 0)
	);
end reg_64b_rising_edge;

architecture description of reg_64b_rising_edge is 
	signal internal_value : std_logic_vector(63 downto 0) := X"0000000000000000";
begin
	process (clock, clear, load)
	begin
		if (clear = '1') then
			internal_value <= X"0000000000000000";
		elsif rising_edge(clock) then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		end if;

	end process;
  reg_out <= internal_value;
end description;

---------------------------------------------------
-- reg_1b
---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg_1b is
	port (
		reg_in : in std_logic;
		load, clock, clear : in std_logic;
		reg_out : out std_logic
	);
end reg_1b;

architecture description of reg_1b is
	signal internal_value : std_logic := '0';
begin
	process (clock, clear, load)
	begin
		if (clear = '1') then
			internal_value <= '0';
		elsif falling_edge(clock) then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		end if;

	end process;
  reg_out <= internal_value;
end description;

---------------------------------------------------
-- reg_2b
---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg_2b is
	port (
		reg_in : in std_logic_vector(1 downto 0);
		load, clock, clear : in std_logic;
		reg_out : out std_logic_vector(1 downto 0)
	);
end reg_2b;

architecture description of reg_2b is
	signal internal_value : std_logic_vector(1 downto 0) := "00";
begin
	process (clock, clear, load)
	begin
		if (clear = '1') then
			internal_value <= "00";
		elsif falling_edge(clock) then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		end if;

	end process;
  reg_out <= internal_value;
end description;

---------------------------------------------------
-- reg_3b
---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg_3b is
	port (
		reg_in : in std_logic_vector(2 downto 0);
		load, clock, clear : in std_logic;
		reg_out : out std_logic_vector(2 downto 0)
	);
end reg_3b;

architecture description of reg_3b is
	signal internal_value : std_logic_vector(2 downto 0) := "000";
begin
	process (clock, clear, load)
	begin
		if (clear = '1') then
			internal_value <= "000";
		elsif falling_edge(clock) then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		end if;

	end process;
  reg_out <= internal_value;
end description;

---------------------------------------------------
-- reg_5b
---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg_5b is
	port (
		reg_in : in std_logic_vector(4 downto 0);
		load, clock, clear : in std_logic;
		reg_out : out std_logic_vector(4 downto 0)
	);
end reg_5b;

architecture description of reg_5b is
	signal internal_value : std_logic_vector(4 downto 0) := "00000";
begin
	process (clock, clear, load)
	begin
		if (clear = '1') then
			internal_value <= "00000";
		elsif falling_edge(clock) then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		end if;

	end process;
  reg_out <= internal_value;
end description;

---------------------------------------------------
-- reg_7b
---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg_7b is
	port (
		reg_in : in std_logic_vector(6 downto 0);
		load, clock, clear : in std_logic;
		reg_out : out std_logic_vector(6 downto 0)
	);
end reg_7b;

architecture description of reg_7b is
	signal internal_value : std_logic_vector(6 downto 0) := "0000000";
begin
	process (clock, clear, load)
	begin
		if (clear = '1') then
			internal_value <= "0000000";
		elsif falling_edge(clock) then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		end if;

	end process;
  reg_out <= internal_value;
end description;



---------------------------------------------------
-- reg_128b
---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg_128b is
	port (
		reg_in : in std_logic_vector(127 downto 0);
		load, clock, clear : in std_logic;
		reg_out : out std_logic_vector(127 downto 0)
	);
end reg_128b;

architecture description of reg_128b is
	signal internal_value : std_logic_vector(127 downto 0) := (others => '0');
begin
	process (clock, clear, load)
	begin
		if (clear = '1') then
			internal_value <= (others => '0');
		elsif falling_edge(clock) then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		end if;

	end process;
  reg_out <= internal_value;
end description;


---------------------------------------------------
-- reg_65b
---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg_65b is
	port (
		reg_in : in std_logic_vector(64 downto 0);
		load, clock, clear : in std_logic;
		reg_out : out std_logic_vector(64 downto 0)
	);
end reg_65b;

architecture description of reg_65b is
	signal internal_value : std_logic_vector(64 downto 0) := (others => '0');
begin
	process (clock, clear, load)
	begin
		if (clear = '1') then
			internal_value <= (others => '0');
		elsif falling_edge(clock) then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		end if;

	end process;
  reg_out <= internal_value;
end description;