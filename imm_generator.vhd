-- File       : imm_generator.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity imm_generator is
	port (
    --clock : in std_logic;
		instruction_in : in std_logic_vector(31 downto 0);
		immediate_out  : out std_logic_vector(63 downto 0)
	);
end entity imm_generator;

architecture Behavioral of imm_generator is


  type imm_type_t is (IMM_NONE, IMM_I, IMM_S, IMM_SB, IMM_U, IMM_UJ, IMM_I_shamt, IMM_I_64shamt);

	signal internal_instruction : std_logic_vector (31 downto 0) := X"00000000";
	signal internal_immediate   : std_logic_vector (63 downto 0) := X"0000000000000000";

begin
  
  decode_proc : process (internal_instruction) is
    
    variable opcode   : std_logic_vector(6 downto 0);
    variable funct3 : std_logic_vector(2 downto 0);
    variable imm_type : imm_type_t := IMM_NONE;

  begin  -- process decode_proc

    opcode := internal_instruction(6 downto 0);
    funct3 := internal_instruction(14 downto 12);

    if(opcode = op_lui OR opcode = op_auipc) then imm_type := IMM_U;
    elsif(opcode = op_jal) then imm_type := IMM_UJ;
    elsif(opcode = op_branch) then imm_type := IMM_SB;
    elsif(opcode = op_store) then imm_type := IMM_S;
    elsif(opcode = op_imm AND (funct3 = "001" OR funct3 = "101")) then imm_type := IMM_I_64shamt;
    elsif(opcode = op_imm_w AND (funct3 = "001" OR funct3 = "101")) then imm_type := IMM_I_shamt;
    elsif(opcode = op_jalr OR opcode = op_load OR opcode = op_imm OR opcode = op_imm_w) then imm_type := IMM_I;
    else imm_type := IMM_NONE;
    end if;

    -- decode and sign-extend the immediate_out value
    case imm_type is

      when IMM_I =>
          for i in 63 downto 11 loop
              internal_immediate(i) <= internal_instruction(31);
          end loop;
          internal_immediate(10 downto 0) <= internal_instruction(30 downto 20);

      when IMM_S =>
          for i in 63 downto 11 loop
              internal_immediate(i) <= instruction_in(31);
          end loop;  -- i
          internal_immediate(10 downto 5) <= internal_instruction(30 downto 25);
          internal_immediate(4 downto 0)  <= internal_instruction(11 downto 7);

      when IMM_SB =>
          for i in 63 downto 12 loop
              internal_immediate(i) <= internal_instruction(31);
          end loop;  -- i
          internal_immediate(11)          <= internal_instruction(7);
          internal_immediate(10 downto 5) <= internal_instruction(30 downto 25);
          internal_immediate(4 downto 1)  <= internal_instruction(11 downto 8);
          internal_immediate(0)           <= '0';

      when IMM_U =>
          for i in 63 downto 31 loop
            internal_immediate(i) <= internal_instruction(31);
          end loop;  -- i
          internal_immediate(30 downto 12) <= internal_instruction(30 downto 12);
          internal_immediate(11 downto 0)  <= (others => '0');

      when IMM_UJ =>
          for i in 63 downto 20 loop
            internal_immediate(i) <= internal_instruction(31);
          end loop;  -- i
          internal_immediate(19 downto 12) <= internal_instruction(19 downto 12);
          internal_immediate(11)           <= internal_instruction(20);
          internal_immediate(10 downto 1)  <= internal_instruction(30 downto 21);
          internal_immediate(0)            <= '0';

      when IMM_I_shamt =>
          for i in 63 downto 5 loop
              internal_immediate(i) <= '0';
          end loop; -- i
          internal_immediate(4 downto 0) <= internal_instruction(24 downto 20);
      
      when IMM_I_64shamt =>
          for i in 63 downto 6 loop
              internal_immediate(i) <= '0';
          end loop; -- i
          internal_immediate(5 downto 0) <= internal_instruction(25 downto 20);
          
      when IMM_NONE => internal_immediate <= (others => '-');
      when others   => internal_immediate <= (others => '0');

    end case;

  end process decode_proc;

  -- Wiring input

  internal_instruction <= instruction_in;

  -- Wiring output

  immediate_out   <= internal_immediate;

end architecture Behavioral;
