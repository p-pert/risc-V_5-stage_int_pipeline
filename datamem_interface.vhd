library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.common.all;

entity datamem_interface is
	port (
    clock, MemWrite, MemRead : in std_logic;
    byte_address : in std_logic_vector(63 downto 0); -- the address in risc-V is given in bytes
		write_data : in std_logic_vector(63 downto 0);
		data_format : in std_logic_vector(2 downto 0);
		read_data : out std_logic_vector(63 downto 0);
    debug_misaligned : out std_logic
	);
end entity datamem_interface;

architecture behavioural of datamem_interface is

  signal debug_internal_misaligned : std_logic    := '0';
  --signal debug_membank_0, debug_membank_1, debug_membank_2, debug_membank_3, debug_membank_4 : std_logic_vector(63 downto 0) := (others => '0');

	signal proc_load : std_logic_vector(7 downto 0) := (others => '0');
  signal load : std_logic_vector(7 downto 0)      := (others => '0');

  --type membank_type is array (0 to 7) of std_logic_vector(7 downto 0); -- memory is divided in banks of 8 bytes
  --signal membank_in, membank_out : membank_type;                       -- where up to a doubleword can be stored occupying all 8 bytes.
                                                                         -- A word will be able to occupy the first 32 bits (bytes 3-0) or the second 32 bits (bytes 7-4)
                                                                         -- of a bank. An halfword will be allowed in the 15-0 bits (bytes 1-0) or the 31-16 bits (bytes 3-2) or the
                                                                         -- 47-32 bits or the 63-48 bits. No inbetweens, like an halfword occupying bytes 2-1.
                                                                         -- A single byte can be stored or read from anywhere.
	signal membank_in, membank_out : std_logic_vector(63 downto 0) := (others => '0');
  signal proc_membank_in : std_logic_vector(63 downto 0)         := (others => '0');

	signal membank_address : std_logic_vector(63 downto 0)         := (others => '0');
	signal byte_offset : std_logic_vector(2 downto 0)              := "000";
  
begin

  membank_address <= std_logic_vector(shift_right(unsigned(byte_address), 3)); --Dividing by 8 to get the address of a bank of 8 bytes		
  byte_offset <= byte_address(2 downto 0); --Last 3 bits to know which of the eight 1-byte-blocks we should access

	membank_interface : process (write_data, byte_address, data_format, byte_offset, MemWrite, MemRead, membank_out) is
  begin

		-- membank_address <= std_logic_vector(shift_right(unsigned(byte_address), 3)); --Dividing by 8 to get the address of a bank of 8 bytes
		
    -- byte_offset <= byte_address(2 downto 0); --Last 3 bits to know which of the eight 1-byte-blocks we should access

    debug_internal_misaligned <= '0';

    ------ WRITING  INTERFACE ------

    if (MemWrite = '1') then --writing to memory, data needs to go to the correct place and stay aligned
                            -- Inputting write_data in membank_in --
      
			case data_format is
				when "011" => -- Store doubleword operation, don't do anything to the input
					if (byte_offset = "000") then
						proc_load <= "11111111";
            proc_membank_in(63 downto 0) <= write_data(63 downto 0);

					else --MISALIGNED MEMORY!!!
            debug_internal_misaligned <= '1';
						proc_load <= "00000000"; -- nothing will be stored
            proc_membank_in(63 downto 0) <= (others => '-');
					end if;

			  when "010" => -- Store word
					if (byte_offset = "000") then           
						proc_load <= "00001111"; -- will be stored in the least significant four bytes
            --proc_membank_in <= (63 downto 32 => '-', 31 downto 0 => write_data(31 downto 0)); -- *** THIS DOESN'T WORK BEFORE vhdl 2008 (if I understood correctly) :( !!
            proc_membank_in(63 downto 32) <= (others => '-');
            proc_membank_in(31 downto 0)  <= write_data(31 downto 0);
					elsif (byte_offset = "100") then
						proc_load <= "11110000"; -- will be stored in bytes 7-4
            proc_membank_in(63 downto 32) <= write_data(31 downto 0);
            proc_membank_in(31 downto 0)  <= (others => '-');
					else --MISALIGNED MEMORY!!!
            debug_internal_misaligned <= '1';
						proc_load <= "00000000";
            proc_membank_in(63 downto 0) <= (others => '-');
					end if;

				when "001" => --Store halfword
					if (byte_offset = "000") then
						proc_load <= "00000011"; -- will be stored in the least significant two bytes
            proc_membank_in(63 downto 16) <= (others => '-');
            proc_membank_in(15 downto 0)  <= write_data(15 downto 0);
					elsif (byte_offset = "010") then
						proc_load <= "00001100"; -- will be stored in bytes 3-2
            proc_membank_in(63 downto 32) <= (others => '-');
            proc_membank_in(31 downto 16) <= write_data(15 downto 0);
            proc_membank_in(15 downto 0)  <= (others => '-');
					elsif (byte_offset = "100") then
						proc_load <= "00110000"; -- will be stored in bytes 5-4
            proc_membank_in(63 downto 48) <= (others => '-');
            proc_membank_in(47 downto 32) <= write_data(15 downto 0);
            proc_membank_in(31 downto 0)  <= (others => '-');
          elsif (byte_offset = "110") then
            proc_load <= "11000000"; -- will be stored in bytes 7-6
            proc_membank_in(63 downto 48) <= write_data(15 downto 0);
            proc_membank_in(47 downto 0)  <= (others => '-');
          else --MISALIGNED MEMORY!!!
            debug_internal_misaligned <= '1';
						proc_load <= "00000000";
            proc_membank_in(63 downto 0) <= (others => '-');
					end if;

				when "000" => --Store byte
					if (byte_offset = "000") then
						proc_load <= "00000001"; -- will be stored in byte 0
            proc_membank_in(63 downto 8) <= (others => '-');
            proc_membank_in(7 downto 0)  <= write_data(7 downto 0);
					elsif (byte_offset = "001") then
						proc_load <= "00000010"; -- will be stored in byte 1
            proc_membank_in(63 downto 16) <= (others => '-');
            proc_membank_in(15 downto 8)  <= write_data(7 downto 0);
            proc_membank_in(7 downto 0)   <= (others => '-');
					elsif (byte_offset = "010") then
						proc_load <= "00000100"; -- will be stored in byte 2
            proc_membank_in(63 downto 24) <= (others => '-');
            proc_membank_in(23 downto 16) <= write_data(7 downto 0);
            proc_membank_in(15 downto 0)  <= (others => '-');
					elsif (byte_offset = "011") then
						proc_load <= "00001000"; -- will be stored in byte 3
            proc_membank_in(63 downto 32) <= (others => '-');
            proc_membank_in(31 downto 24) <= write_data(7 downto 0);
            proc_membank_in(23 downto 0)  <= (others => '-');
          elsif (byte_offset = "100") then
            proc_load <= "00010000"; -- will be stored in byte 4
            proc_membank_in(63 downto 40) <= (others => '-');
            proc_membank_in(39 downto 32) <= write_data(7 downto 0);
            proc_membank_in(31 downto 0)  <= (others => '-');
          elsif (byte_offset = "101") then
            proc_load <= "00100000"; -- will be stored in byte 5
            proc_membank_in(63 downto 48) <= (others => '-');
            proc_membank_in(47 downto 40) <= write_data(7 downto 0);
            proc_membank_in(39 downto 0)  <= (others => '-');
          elsif (byte_offset = "110") then
            proc_load <= "01000000"; -- will be stored in byte 6
            proc_membank_in(63 downto 56) <= (others => '-');
            proc_membank_in(55 downto 48) <= write_data(7 downto 0);
            proc_membank_in(47 downto 0)  <= (others => '-');
          elsif (byte_offset = "111") then
            proc_load <= "10000000"; -- will be stored in byte 7
            proc_membank_in(63 downto 56) <= write_data(7 downto 0);
            proc_membank_in(55 downto 0)  <= (others => '-');
          else --MISALIGNED MEMORY!!!
            debug_internal_misaligned <= '1';
            proc_load <= "00000000";
            proc_membank_in(63 downto 0) <= (others => '-');
					end if;

				when others => -- unacceptable data format
          proc_load <= "00000000"; -- nothing will be stored
          proc_membank_in(63 downto 0) <= (others => '-');
			end case;

    ------ READING  INTERFACE ------

		elsif(MemRead = '1')  then --reading operation, data needs to be formatted to be sent to internal registers in the registerfile 
                               -- Connecting membank_out to read_data --
    proc_load <= "00000000";
			case data_format is
				when "011" => --Signed Doubleword operation, don't do anything to the input
					if (byte_offset = "000") then
						read_data <= std_logic_vector(membank_out(63 downto 0));
					else --MISALIGNED MEMORY!!!
            debug_internal_misaligned <= '1';
						read_data <= X"0000000000000000";
					end if;

        when "010" => --Signed word
					if (byte_offset = "000") then -- read least significant four bytes. Sign extend
            for i in 63 downto 32 loop
              read_data(i) <= membank_out(31);
            end loop;
            read_data(31 downto 0) <= membank_out(31 downto 0);
					elsif (byte_offset = "100") then -- read bytes 7-4
            for i in 63 downto 32 loop
              read_data(i) <= membank_out(63);
            end loop;
            read_data(31 downto 0) <= membank_out(63 downto 32);
					else --MISALIGNED MEMORY!!!
              debug_internal_misaligned <= '1';
						read_data <= X"0000000000000000";
					end if;

				when "110" => --Unsigned word
          if (byte_offset = "000") then -- read least significant four bytes. Fill with 0s
            for i in 63 downto 32 loop
              read_data(i) <= '0';
            end loop;
            read_data(31 downto 0) <= membank_out(31 downto 0);
          elsif (byte_offset = "100") then -- read bytes 7-4
            for i in 63 downto 32 loop
             read_data(i) <= '0';
            end loop;
            read_data(31 downto 0) <= membank_out(63 downto 32);
          else --MISALIGNED MEMORY!!!
              debug_internal_misaligned <= '1';
            read_data <= X"0000000000000000";
          end if;

        when "001" => --Signed halfword
          if (byte_offset = "000") then -- read least significant two bytes. Sign extend
            for i in 63 downto 16 loop
              read_data(i) <= membank_out(15);
            end loop;
            read_data(15 downto 0) <= membank_out(15 downto 0);
          elsif (byte_offset = "010") then -- read bytes 3-2
            for i in 63 downto 16 loop
              read_data(i) <= membank_out(31);
            end loop;
            read_data(15 downto 0) <= membank_out(31 downto 16);
          elsif (byte_offset = "100") then -- read bytes 5-4
            for i in 63 downto 16 loop
              read_data(i) <= membank_out(47);
            end loop;
            read_data(15 downto 0) <= membank_out(47 downto 32);
          elsif (byte_offset = "110") then -- read bytes 6-7
            for i in 63 downto 16 loop
              read_data(i) <= membank_out(63);
            end loop;
            read_data(15 downto 0) <= membank_out(63 downto 48); 
          else --MISALIGNED MEMORY!!!
              debug_internal_misaligned <= '1';
            read_data <= X"0000000000000000";
					end if;

        when "101" => --Unsigned halfword
          if (byte_offset = "000") then -- read least significant two bytes. Fill with 0s
            for i in 63 downto 16 loop
              read_data(i) <= '0';
            end loop;
            read_data(15 downto 0) <= membank_out(15 downto 0);
          elsif (byte_offset = "010") then -- read bytes 3-2
            for i in 63 downto 16 loop
              read_data(i) <= '0';
            end loop;
            read_data(15 downto 0) <= membank_out(31 downto 16);
          elsif (byte_offset = "100") then -- read bytes 5-4
            for i in 63 downto 16 loop
              read_data(i) <= '0';
            end loop;
            read_data(15 downto 0) <= membank_out(47 downto 32);
          elsif (byte_offset = "110") then -- read bytes 6-7
            for i in 63 downto 16 loop
              read_data(i) <= '0';
            end loop;
          read_data(15 downto 0) <= membank_out(63 downto 48); 
          else --MISALIGNED MEMORY!!!
              debug_internal_misaligned <= '1';
            read_data <= X"0000000000000000";
					end if;
        
        when "000" => --Signed byte
          if (byte_offset = "000") then -- read byte 0. Sign extend
            for i in 63 downto 8 loop
              read_data(i) <= membank_out(7);
            end loop;
            read_data(7 downto 0) <= membank_out(7 downto 0);
          elsif (byte_offset = "001") then -- read byte 1
            for i in 63 downto 8 loop
              read_data(i) <= membank_out(15);
            end loop;
            read_data(7 downto 0) <= membank_out(15 downto 8);
          elsif (byte_offset = "010") then -- read byte 2
            for i in 63 downto 8 loop
              read_data(i) <= membank_out(23);
            end loop;
            read_data(7 downto 0) <= membank_out(23 downto 16);
          elsif (byte_offset = "011") then -- read byte 3
            for i in 63 downto 8 loop
              read_data(i) <= membank_out(31);
            end loop;
            read_data(7 downto 0) <= membank_out(31 downto 24);
          elsif (byte_offset = "100") then -- read byte 4
            for i in 63 downto 8 loop
              read_data(i) <= membank_out(39);
            end loop;
            read_data(7 downto 0) <= membank_out(39 downto 32);
          elsif (byte_offset = "101") then -- read byte 5
            for i in 63 downto 8 loop
              read_data(i) <= membank_out(47);
            end loop;
            read_data(7 downto 0) <= membank_out(47 downto 40);
          elsif (byte_offset = "110") then -- read byte 6
            for i in 63 downto 8 loop
              read_data(i) <= membank_out(55);
            end loop;
            read_data(7 downto 0) <= membank_out(55 downto 48);
          elsif (byte_offset = "111") then -- read byte 7
            for i in 63 downto 8 loop
              read_data(i) <= membank_out(63);
            end loop;
            read_data(7 downto 0) <= membank_out(63 downto 56);
          else --MISALIGNED MEMORY!!!
              debug_internal_misaligned <= '1';
            read_data <= X"0000000000000000";
					end if;
        
        when "100" => --Unsigned byte
          if (byte_offset = "000") then -- read byte 0. Fill with 0s
            for i in 63 downto 8 loop
              read_data(i) <= '0';
            end loop;
            read_data(7 downto 0) <= membank_out(7 downto 0);
          elsif (byte_offset = "001") then -- read byte 1
            for i in 63 downto 8 loop
              read_data(i) <= '0';
            end loop;
            read_data(7 downto 0) <= membank_out(15 downto 8);
          elsif (byte_offset = "010") then -- read byte 2
            for i in 63 downto 8 loop
              read_data(i) <= '0';
            end loop;
            read_data(7 downto 0) <= membank_out(23 downto 16);
          elsif (byte_offset = "011") then -- read byte 3
            for i in 63 downto 8 loop
              read_data(i) <= '0';
            end loop;
            read_data(7 downto 0) <= membank_out(31 downto 24);
          elsif (byte_offset = "100") then -- read byte 4
            for i in 63 downto 8 loop
              read_data(i) <= '0';
            end loop;
            read_data(7 downto 0) <= membank_out(39 downto 32);
          elsif (byte_offset = "101") then -- read byte 5
            for i in 63 downto 8 loop
              read_data(i) <= '0';
            end loop;
            read_data(7 downto 0) <= membank_out(47 downto 40);
          elsif (byte_offset = "110") then -- read byte 6
            for i in 63 downto 8 loop
              read_data(i) <= '0';
            end loop;
            read_data(7 downto 0) <= membank_out(55 downto 48);
          elsif (byte_offset = "111") then -- read byte 7
            for i in 63 downto 8 loop
              read_data(i) <= '0';
            end loop;
            read_data(7 downto 0) <= membank_out(63 downto 56);
          else --MISALIGNED MEMORY!!!
              debug_internal_misaligned <= '1';
            read_data <= X"0000000000000000";
					end if;
    			
				when others => -- unacceptable data format
					read_data <= X"0000000000000000"; 
			end case;
    else --neither writing nor reading
      proc_load <= "00000000";
      read_data <= X"0000000000000000"; 
		end if;
	end process membank_interface;

  load <= proc_load;
  membank_in <= proc_membank_in;
  debug_misaligned <= debug_internal_misaligned;

-- MEMBANK MADE OF EIGHT 1-byte-blocks:
  datamem_7 : entity work.datamem port map(clock => clock, 
                                           write_enable => load(7), 
                                           address => membank_address(MEMBANK_ADDRESS_range downto 0),
                                           datain => membank_in(63 downto 56),
                                           dataout => membank_out(63 downto 56));

	datamem_6 : entity work.datamem port map(clock, load(6), membank_address(MEMBANK_ADDRESS_range downto 0), membank_in(55 downto 48), membank_out(55 downto 48));
	datamem_5 : entity work.datamem port map(clock, load(5), membank_address(MEMBANK_ADDRESS_range downto 0), membank_in(47 downto 40), membank_out(47 downto 40));
	datamem_4 : entity work.datamem port map(clock, load(4), membank_address(MEMBANK_ADDRESS_range downto 0), membank_in(39 downto 32), membank_out(39 downto 32));
	datamem_3 : entity work.datamem port map(clock, load(3), membank_address(MEMBANK_ADDRESS_range downto 0), membank_in(31 downto 24), membank_out(31 downto 24));
	datamem_2 : entity work.datamem port map(clock, load(2), membank_address(MEMBANK_ADDRESS_range downto 0), membank_in(23 downto 16), membank_out(23 downto 16));
	datamem_1 : entity work.datamem port map(clock, load(1), membank_address(MEMBANK_ADDRESS_range downto 0), membank_in(15 downto 8) , membank_out(15 downto 8) );
	datamem_0 : entity work.datamem port map(clock, load(0), membank_address(MEMBANK_ADDRESS_range downto 0), membank_in(7 downto 0)  , membank_out(7 downto 0)  );


  -- -- debug/test bubble sort.c 
  -- debug_datamem_7_0 : entity work.datamem port map(clock, '0', "111111111", X"00", debug_membank_0(63 downto 56));
  -- debug_datamem_6_0 : entity work.datamem port map(clock, '0', "111111111", X"00", debug_membank_0(55 downto 48));
  -- debug_datamem_5_0 : entity work.datamem port map(clock, '0', "111111111", X"00", debug_membank_0(47 downto 40));
  -- debug_datamem_4_0 : entity work.datamem port map(clock, '0', "111111111", X"00", debug_membank_0(39 downto 32));
  -- debug_datamem_3_0 : entity work.datamem port map(clock, '0', "111111111", X"00", debug_membank_0(31 downto 24));
  -- debug_datamem_2_0 : entity work.datamem port map(clock, '0', "111111111", X"00", debug_membank_0(23 downto 16));
  -- debug_datamem_1_0 : entity work.datamem port map(clock, '0', "111111111", X"00", debug_membank_0(15 downto 8) );
  -- debug_datamem_0_0 : entity work.datamem port map(clock, '0', "111111111", X"00", debug_membank_0(7 downto 0)  );

  -- debug_datamem_7_1 : entity work.datamem port map(clock, '0', "111111110", X"00", debug_membank_1(63 downto 56));
  -- debug_datamem_6_1 : entity work.datamem port map(clock, '0', "111111110", X"00", debug_membank_1(55 downto 48));
  -- debug_datamem_5_1 : entity work.datamem port map(clock, '0', "111111110", X"00", debug_membank_1(47 downto 40));
  -- debug_datamem_4_1 : entity work.datamem port map(clock, '0', "111111110", X"00", debug_membank_1(39 downto 32));
  -- debug_datamem_3_1 : entity work.datamem port map(clock, '0', "111111110", X"00", debug_membank_1(31 downto 24));
  -- debug_datamem_2_1 : entity work.datamem port map(clock, '0', "111111110", X"00", debug_membank_1(23 downto 16));
  -- debug_datamem_1_1 : entity work.datamem port map(clock, '0', "111111110", X"00", debug_membank_1(15 downto 8) );
  -- debug_datamem_0_1 : entity work.datamem port map(clock, '0', "111111110", X"00", debug_membank_1(7 downto 0)  );

  -- debug_datamem_7_2 : entity work.datamem port map(clock, '0', "111111101", X"00", debug_membank_2(63 downto 56));
  -- debug_datamem_6_2 : entity work.datamem port map(clock, '0', "111111101", X"00", debug_membank_2(55 downto 48));
  -- debug_datamem_5_2 : entity work.datamem port map(clock, '0', "111111101", X"00", debug_membank_2(47 downto 40));
  -- debug_datamem_4_2 : entity work.datamem port map(clock, '0', "111111101", X"00", debug_membank_2(39 downto 32));
  -- debug_datamem_3_2 : entity work.datamem port map(clock, '0', "111111101", X"00", debug_membank_2(31 downto 24));
  -- debug_datamem_2_2 : entity work.datamem port map(clock, '0', "111111101", X"00", debug_membank_2(23 downto 16));
  -- debug_datamem_1_2 : entity work.datamem port map(clock, '0', "111111101", X"00", debug_membank_2(15 downto 8) );
  -- debug_datamem_0_2 : entity work.datamem port map(clock, '0', "111111101", X"00", debug_membank_2(7 downto 0)  );

  -- debug_datamem_7_3 : entity work.datamem port map(clock, '0', "111111100", X"00", debug_membank_3(63 downto 56));
  -- debug_datamem_6_3 : entity work.datamem port map(clock, '0', "111111100", X"00", debug_membank_3(55 downto 48));
  -- debug_datamem_5_3 : entity work.datamem port map(clock, '0', "111111100", X"00", debug_membank_3(47 downto 40));
  -- debug_datamem_4_3 : entity work.datamem port map(clock, '0', "111111100", X"00", debug_membank_3(39 downto 32));
  -- debug_datamem_3_3 : entity work.datamem port map(clock, '0', "111111100", X"00", debug_membank_3(31 downto 24));
  -- debug_datamem_2_3 : entity work.datamem port map(clock, '0', "111111100", X"00", debug_membank_3(23 downto 16));
  -- debug_datamem_1_3 : entity work.datamem port map(clock, '0', "111111100", X"00", debug_membank_3(15 downto 8) );
  -- debug_datamem_0_3 : entity work.datamem port map(clock, '0', "111111100", X"00", debug_membank_3(7 downto 0)  );

  -- debug_datamem_7_4 : entity work.datamem port map(clock, '0', "111111011", X"00", debug_membank_4(63 downto 56));
  -- debug_datamem_6_4 : entity work.datamem port map(clock, '0', "111111011", X"00", debug_membank_4(55 downto 48));
  -- debug_datamem_5_4 : entity work.datamem port map(clock, '0', "111111011", X"00", debug_membank_4(47 downto 40));
  -- debug_datamem_4_4 : entity work.datamem port map(clock, '0', "111111011", X"00", debug_membank_4(39 downto 32));
  -- debug_datamem_3_4 : entity work.datamem port map(clock, '0', "111111011", X"00", debug_membank_4(31 downto 24));
  -- debug_datamem_2_4 : entity work.datamem port map(clock, '0', "111111011", X"00", debug_membank_4(23 downto 16));
  -- debug_datamem_1_4 : entity work.datamem port map(clock, '0', "111111011", X"00", debug_membank_4(15 downto 8) );
  -- debug_datamem_0_4 : entity work.datamem port map(clock, '0', "111111011", X"00", debug_membank_4(7 downto 0)  );

end architecture behavioural;