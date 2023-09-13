-- File       : control_unit.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity control_unit is
	port (
    --clock : in std_logic;
    opcode : in std_logic_vector(6 downto 0);
		ALUOp   : out std_logic_vector(1 downto 0);
		ALUSrc1 : out std_logic_vector(1 downto 0);
    ALUSrc2 : out std_logic_vector(1 downto 0);
		MemtoReg : out std_logic;
		RegWrite : out std_logic;
		MemRead  : out std_logic;
		MemWrite : out std_logic;
		IsBranch : out std_logic;
    Jump     : out std_logic;
    IsJalr   : out std_logic;
    ID_Flush : out std_logic
	);
end entity control_unit;

architecture Behavioral of control_unit is

  signal internal_opcode   : std_logic_vector(6 downto 0) := (others => '0');
	signal internal_ALUOp    : std_logic_vector(1 downto 0) := "00";
  signal internal_ALUSrc1  : std_logic_vector(1 downto 0) := "00";
  signal internal_ALUSrc2  : std_logic_vector(1 downto 0) := "00";

	signal internal_MemtoReg : std_logic := '0';
	signal internal_RegWrite : std_logic := '0';
	signal internal_MemRead  : std_logic := '0';
	signal internal_MemWrite : std_logic := '0';
	signal internal_IsBranch : std_logic := '0';
  signal internal_Jump     : std_logic := '0';
  signal internal_IsJalr   : std_logic := '0';
  signal internal_ID_Flush : std_logic := '0';


begin
  
  decode_proc : process (internal_opcode) is

  begin  -- process decode_proc

    case (internal_opcode) is

      -- Branch to target address, if condition is met
      when op_branch => 

        internal_ALUOp    <= "01";
        internal_ALUSrc1  <= "00";
        internal_ALUSrc2  <= "00";
        internal_MemtoReg <= '0'; --actually don't care
        internal_RegWrite <= '0';
        internal_MemRead  <= '0';
        internal_MemWrite <= '0';
        internal_IsBranch <= '1';
        internal_Jump     <= '1';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '0';

      -- JALR
      when op_jalr => 

        internal_ALUOp    <= "00";
        internal_ALUSrc1  <= "01";
        internal_ALUSrc2  <= "10";
        internal_MemtoReg <= '0'; --actually don't care
        internal_RegWrite <= '1';
        internal_MemRead  <= '0';
        internal_MemWrite <= '0';
        internal_IsBranch <= '0';
        internal_Jump     <= '1';
        internal_IsJalr   <= '1';

        internal_ID_Flush <= '0';

      -- JAL
      when op_jal => 

        internal_ALUOp    <= "00";
        internal_ALUSrc1  <= "01";
        internal_ALUSrc2  <= "10";
        internal_MemtoReg <= '0'; --actually don't care
        internal_RegWrite <= '1';
        internal_MemRead  <= '0';
        internal_MemWrite <= '0';
        internal_IsBranch <= '0';
        internal_Jump     <= '1';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '0';

      -- load data from memory
      when op_load =>

        internal_ALUOp    <= "00";
        internal_ALUSrc1  <= "00";
        internal_ALUSrc2  <= "01";
        internal_MemtoReg <= '1'; 
        internal_RegWrite <= '1';
        internal_MemRead  <= '1';
        internal_MemWrite <= '0';
        internal_IsBranch <= '0';
        internal_Jump     <= '0';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '0';

      -- store data to memory
      when op_store =>

        internal_ALUOp    <= "00";
        internal_ALUSrc1  <= "00";
        internal_ALUSrc2  <= "01";
        internal_MemtoReg <= '0'; -- actually don't care
        internal_RegWrite <= '0';
        internal_MemRead  <= '0';
        internal_MemWrite <= '1';
        internal_IsBranch <= '0';
        internal_Jump     <= '0';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '0';

      -- perform computation with immediate value and a register
      when op_imm =>

        internal_ALUOp    <= "10";
        internal_ALUSrc1  <= "00";
        internal_ALUSrc2  <= "01";
        internal_MemtoReg <= '0';
        internal_RegWrite <= '1';
        internal_MemRead  <= '0';
        internal_MemWrite <= '0';
        internal_IsBranch <= '0';
        internal_Jump     <= '0';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '0';
      
      -- perform computation with immediate value and a register
      when op_imm_w =>

        internal_ALUOp    <= "10";
        internal_ALUSrc1  <= "00";
        internal_ALUSrc2  <= "01";
        internal_MemtoReg <= '0';
        internal_RegWrite <= '1';
        internal_MemRead  <= '0';
        internal_MemWrite <= '0';
        internal_IsBranch <= '0';
        internal_Jump     <= '0';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '0';

      -- perform computation with two register values
      when op_Rtype =>

        internal_ALUOp    <= "10";
        internal_ALUSrc1  <= "00";
        internal_ALUSrc2  <= "00";
        internal_MemtoReg <= '0';
        internal_RegWrite <= '1';
        internal_MemRead  <= '0';
        internal_MemWrite <= '0';
        internal_IsBranch <= '0';
        internal_Jump     <= '0';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '0';

      -- perform computation with two register values, but will use 32bit words
      when op_RWtype =>

        internal_ALUOp    <= "10";
        internal_ALUSrc1  <= "00";
        internal_ALUSrc2  <= "00";
        internal_MemtoReg <= '0';
        internal_RegWrite <= '1';
        internal_MemRead  <= '0';
        internal_MemWrite <= '0';
        internal_IsBranch <= '0';
        internal_Jump     <= '0';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '0';

      -- add 20 bit upper immediate with PC
      when op_auipc =>

        internal_ALUOp    <= "00";
        internal_ALUSrc1  <= "01";
        internal_ALUSrc2  <= "01";
        internal_MemtoReg <= '0';
        internal_RegWrite <= '1';
        internal_MemRead  <= '0';
        internal_MemWrite <= '0';
        internal_IsBranch <= '0';
        internal_Jump     <= '0';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '0';

      -- load 20 bit upper immediate
      when op_lui =>

        internal_ALUOp    <= "00";
        internal_ALUSrc1  <= "10";
        internal_ALUSrc2  <= "01";
        internal_MemtoReg <= '0';
        internal_RegWrite <= '1';
        internal_MemRead  <= '0';
        internal_MemWrite <= '0';
        internal_IsBranch <= '0';
        internal_Jump     <= '0';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '0';
      
      -- flush in case of an unaccepted instruction opcode
      when others =>
        --report "WARNING! An instruction with an unsupported opcode was given...interepreting it as a NOP (No OPeration)" severity warning;
        internal_ALUOp    <= "00"; 
        internal_ALUSrc1  <= "00";
        internal_ALUSrc2  <= "00";
        internal_MemtoReg <= '0';
        internal_RegWrite <= '0';
        internal_MemRead  <= '0';
        internal_MemWrite <= '0';
        internal_IsBranch <= '0';
        internal_Jump     <= '0';
        internal_IsJalr   <= '0';

        internal_ID_Flush <= '1'; -- ID_Flush is actually superfluous since every line is set to 0 already but I left it for potential future use

    end case;

  end process decode_proc;

  -- Wiring input

  internal_opcode <= opcode;
  
  -- Wiring output

	ALUOp       <= internal_ALUOp;
	ALUSrc1     <= internal_ALUSrc1;
  ALUSrc2     <= internal_ALUSrc2;
	MemtoReg    <= internal_MemtoReg;
	RegWrite    <= internal_RegWrite;
	MemRead     <= internal_MemRead;
	MemWrite    <= internal_MemWrite;
	IsBranch    <= internal_IsBranch;
  Jump        <= internal_Jump;
  IsJalr      <= internal_IsJalr;
  ID_Flush    <= internal_ID_Flush;

end architecture Behavioral;
