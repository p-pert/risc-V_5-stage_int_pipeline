library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.common.all;

entity datapath is
  port(
    clock, reset : in std_logic;
    debug_regbank_array : out t_regbank_array
);
end entity datapath;

architecture structural of datapath is

  signal debug_misaligned : std_logic := '0';
  signal debug_regbank_array_internal : t_regbank_array;

  signal new_PC, PC, PC4 : std_logic_vector(63 downto 0) := (others => '0');
  signal PCSrc : std_logic := '0';
  signal IF_Flush : std_logic := '0';
  signal ins_mem_output : std_logic_vector(31 downto 0) := (others => '0');
  signal IF_ins_mem_output : std_logic_vector(31 downto 0) := (others => '0');
  

  signal IF_ID_PC : std_logic_vector(63 downto 0) := (others => '0');
  signal IF_ID_instruction : std_logic_vector(31 downto 0) := (others => '0');


  signal BranchCmp : std_logic := '1';
  signal Jump : std_logic := '0';
  signal Stall : std_logic := '0';
  signal Stall_Hzd : std_logic := '0';
  signal Stall_ALU : std_logic := '0';
  signal branch_address, jalr_address, jump_target_address : std_logic_vector(63 downto 0) := (others => '0');
  signal immediate : std_logic_vector(63 downto 0) := (others => '0');
  signal shifted_imm : std_logic_vector(63 downto 0) := (others => '0');
  signal ALUOp : std_logic_vector(1 downto 0) := (others => '0');
  signal ALUSrc1, ALUSrc2 : std_logic_vector(1 downto 0) := (others => '0');
  signal MemtoReg, RegWrite, MemRead, MemWrite, IsBranch, IsJalr : std_logic := '0';
  signal ID_Flush : std_logic := '1';
  signal register_file_output_1, register_file_output_2 : std_logic_vector(63 downto 0) := (others => '0');
  signal sel_fwd_branch_1, sel_fwd_branch_2 : std_logic := '0';
  signal ID_EX_Flush : std_logic := '0';
  signal ID_ALUOp : std_logic_vector(1 downto 0) := (others => '0');
  signal ID_ALUSrc1, ID_ALUSrc2 : std_logic_vector(1 downto 0) := (others => '0');
  signal ID_MemtoReg, ID_RegWrite, ID_MemRead, ID_MemWrite : std_logic := '0';

  signal ID_EX_PC, ID_EX_immediate : std_logic_vector(63 downto 0) := (others => '0');
  signal ID_EX_register_rs2, ID_EX_register_rs1, ID_EX_register_rd : std_logic_vector(4 downto 0) := (others => '0');
  signal ID_EX_ALUOp : std_logic_vector(1 downto 0) := (others => '0');
  signal ID_EX_ALUSrc1, ID_EX_ALUSrc2 : std_logic_vector(1 downto 0) := (others => '0');
  signal ID_EX_MemtoReg, ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite : std_logic := '0';
  signal ID_EX_insn_bit30, ID_EX_insn_bit25, ID_EX_insn_bit5, ID_EX_insn_bit3: std_logic := '0';
  signal ID_EX_funct3 : std_logic_vector(2 downto 0) := (others => '0');
  signal ID_EX_register_file_output_1, ID_EX_register_file_output_2 : std_logic_vector(63 downto 0) := (others => '0');


  signal sel_fwd_1, sel_fwd_2 : std_logic_vector(1 downto 0) := (others => '0');
  signal mux_fwd_1_out, mux_fwd_2_out : std_logic_vector(63 downto 0) := (others => '0');
  signal ALU_operand_1, ALU_operand_2 : std_logic_vector(63 downto 0) := (others => '0');
  signal ALU_func : std_logic_vector(4 downto 0) := (others => '0');
  signal ALU_output : std_logic_vector(63 downto 0) := (others => '0');
  signal exc_type : exc_type_t := EXC_NONE;
  signal EX_MEM_Flush : std_logic := '0';
  signal EX_MemtoReg, EX_RegWrite, EX_MemRead, EX_MemWrite : std_logic := '0';

  signal EX_MEM_ALU_output : std_logic_vector(63 downto 0) := (others => '0');
  signal EX_MEM_mux_fwd_2_out : std_logic_vector(63 downto 0) := (others => '0');
  signal EX_MEM_MemRead, EX_MEM_RegWrite, EX_MEM_MemtoReg, EX_MEM_MemWrite : std_logic := '0';
  signal EX_MEM_funct3 : std_logic_vector(2 downto 0) := (others => '0');
  signal EX_MEM_register_rd : std_logic_vector(4 downto 0) := (others => '0');


  signal datamem_output : std_logic_vector(63 downto 0) := (others => '0');
  

  signal MEM_WB_datamem_output, MEM_WB_ALU_output : std_logic_vector(63 downto 0) := (others => '0');
  signal MEM_WB_register_rd : std_logic_vector(4 downto 0) := (others => '0'); 
  signal MEM_WB_MemToReg, MEM_WB_RegWrite : std_logic := '0';


  signal mux_WB_output : std_logic_vector(63 downto 0) := (others => '0');


begin
  Stall <= Stall_Hzd OR Stall_ALU;
  program_counter: entity work.program_counter port map(clock, reset, Stall, new_PC, PC);


  PC_plus_4_adder: entity work.ADDER_N generic map (N => 64) port map(a => PC, b => X"0000000000000004", c_in => '0', s => PC4, Ovrf => open);

  -- New PC might come from Jump target-address or a taken Branch target-address <-- if PCSrc=1
  -- else it's just PC+4                                                         <-- PCSrc=0
  PCSrc_mux : entity work.mux_2_1_64b port map(selection => PCSrc, input_0 => PC4, input_1 => jump_target_address, output_0 => new_PC);

                      -- For PCSrc: --
  -- Jump = 1 if insn in IF/ID is a jal/jalr or a branch-type.
  -- BranchCmp = 1 if insn in IF/ID is not a branch-type at all - so, Jump plus not-Branch implies PCSrc = '1' - 
  -- or if it is a branch-type and the branch is taken - again PCSrc = '1' - . It is 0 if insn
  -- is a branch-type but the branch is not taken - then PCSrc = '0'.
  PCSrc <= (BranchCmp AND Jump);

  instruction_memory: entity work.instruction_memory port map(PC, ins_mem_output);

  -- Assume branch not taken, then evaluate in the ID stage with branch_comparator unit
  -- If a branch is taken need to flush instruction going into IF/ID.
  -- Also need to flush in any case if the instruction is a jal/jalr
  -- So an IF_Flush signal is equivalent to PCSrc
  IF_Flush <= PCSrc;
  
  
  -- Stall the instruction in IF/ID in case of a stall asserted by the hazard unit or ALU, or flush in case of IF_Flush needed because of a jump/branch taken --
  with IF_Flush select
    IF_ins_mem_output <=
		(others=>'0')  when '1',
    ins_mem_output when others;

  IF_ID_REGS : entity work.IF_ID_DIV port map(clock, reset, Stall, 
                                             PC, IF_ins_mem_output,        -- in
                                             IF_ID_PC, IF_ID_instruction); -- out

  immediate_generator : entity work.imm_generator port map(instruction_in => IF_ID_instruction, immediate_out => immediate);

  control_unit : entity work.control_unit port map(IF_ID_instruction(6 downto 0), -- in
                                                   ALUOp, ALUSrc1, ALUSrc2, MemtoReg, RegWrite, MemRead, MemWrite, IsBranch, Jump, IsJalr, ID_Flush); -- out

  hazard_unit : entity work.hazard_unit port map(IF_ID_instruction(24 downto 20), IF_ID_instruction(19 downto 15), ID_EX_register_rd, EX_MEM_register_rd, ID_EX_MemRead, EX_MEM_MemRead,  -- in
                                                 IsBranch, IsJalr, ID_EX_RegWrite, Stall_Hzd);  -- out
  
  -- Shift left 1 the immediate and add it to IF_ID_PC to obtain branch or jal target address --
  -- The shifting of the immediate is included in the following unit that also does the sum with the PC --
  branch_or_jal_address_unit : entity work.branch_address_unit port map(IF_ID_PC, immediate,  -- in
                                                                        branch_address);      -- out

  -- Add immediate to register_file_output_1 to obtain jalr target address --
  jalr_address_adder : entity work.ADDER_SUBTR generic map(N => 64) port map(addsub => '0', a => immediate, b => register_file_output_1, 
                                                                             s => jalr_address, overflow => open, c_out => open);

  -- Mux to choose jump target address between branch/jal or jalr --
  mux_jump_target : entity work.mux_2_1_64b port map(selection => IsJalr, input_0 => branch_address, input_1 => jalr_address, output_0 => jump_target_address);
  
  -- Use this when not testing register_file content: --
  -- register_file : entity work.register_file port map(mux_WB_output, MEM_WB_register_rd, IF_ID_instruction(19 downto 15), IF_ID_instruction(24 downto 20), MEM_WB_RegWrite, clock, reset, register_file_output_1, register_file_output_2);
  -- Use this when testing register file content: --
  register_file : entity work.register_file port map(write_data => mux_WB_output, write_address => MEM_WB_register_rd, read_address_1 => IF_ID_instruction(19 downto 15), read_address_2 => IF_ID_instruction(24 downto 20), RegWrite => MEM_WB_RegWrite, clock => clock, clear => reset, output_data_1 => register_file_output_1, output_data_2 => register_file_output_2, debug_regbank_array => debug_regbank_array_internal);
  debug_regbank_array <= debug_regbank_array_internal;
  debug_regbank_unit :entity work.debug_regbank port map(debug_regbank_array_internal); -- For visualizing registers content in gtkwave

  forwarding_unit_branch : entity work.forwarding_unit_branch port map(IF_ID_instruction(24 downto 20), IF_ID_instruction(19 downto 15), EX_MEM_register_rd, EX_MEM_RegWrite,  -- in
                                                                       sel_fwd_branch_1, sel_fwd_branch_2); -- out
  branch_cmp : entity work.branch_comparator port map(IsBranch, IF_ID_instruction(14 downto 12), sel_fwd_branch_1, sel_fwd_branch_2, register_file_output_1, register_file_output_2, EX_MEM_ALU_output, -- in
                                                      BranchCmp); -- out
  
  -- Mux for flushing control lines that go in the ID/EX division. Flush when hazard stalling --
  ID_EX_Flush <= ID_Flush OR Stall_Hzd;

  mux_ID_EX_Flush : entity work.mux_ID_EX_Flush port map (ID_EX_Flush, ALUOp(1), ALUOp(0), ALUSrc1(1), ALUSrc1(0), ALUSrc2(1), ALUSrc2(0), MemtoReg, RegWrite, MemRead, MemWrite, ID_ALUOp(1),  -- in
                                                                       ID_ALUOp(0), ID_ALUSrc1(1), ID_ALUSrc1(0), ID_ALUSrc2(1), ID_ALUSrc2(0), ID_MemtoReg, ID_RegWrite, ID_MemRead, ID_MemWrite); -- out

  -- Only stall, don't flush ID/EX, when ALU is stalling for a multiplication/division --
  ID_EX_REGS : entity work.ID_EX_DIV port map(clock, reset, Stall_ALU, 
                                             IF_ID_PC, register_file_output_1, register_file_output_2, immediate, IF_ID_instruction(30), IF_ID_instruction(25), IF_ID_instruction(24 downto 20), IF_ID_instruction(19 downto 15), IF_ID_instruction(14 downto 12), IF_ID_instruction(11 downto 7), IF_ID_instruction(5), IF_ID_instruction(3), ID_ALUOp, ID_ALUSrc1, ID_ALUSrc2, ID_MemtoReg, ID_RegWrite, ID_MemRead, ID_MemWrite, -- in
                                             ID_EX_PC, ID_EX_register_file_output_1, ID_EX_register_file_output_2, ID_EX_immediate, ID_EX_insn_bit30, ID_EX_insn_bit25, ID_EX_register_rs2, ID_EX_register_rs1, ID_EX_funct3, ID_EX_register_rd, ID_EX_insn_bit5, ID_EX_insn_bit3, ID_EX_ALUOp, ID_EX_ALUSrc1, ID_EX_ALUSrc2, ID_EX_MemtoReg, ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite); -- out
  
  forwarding_unit_ALU : entity work.forwarding_unit_ALU port map(ID_EX_register_rs1, ID_EX_register_rs2, EX_MEM_register_rd, MEM_WB_register_rd, EX_MEM_RegWrite, MEM_WB_RegWrite,  -- in
                                                                 sel_fwd_1, sel_fwd_2);  -- out

  -- Forwarding multiplexers EX stage: --
  mux_EX_forwarding_1 : entity work.mux_3_1 port map(selection => sel_fwd_1, input_0 => ID_EX_register_file_output_1, input_1 => mux_WB_output, input_2 => EX_MEM_ALU_output, output_0 => mux_fwd_1_out);
  mux_EX_fowrarding_2 : entity work.mux_3_1 port map(selection => sel_fwd_2, input_0 => ID_EX_register_file_output_2, input_1 => mux_WB_output, input_2 => EX_MEM_ALU_output, output_0 => mux_fwd_2_out);

  -- Mux to choose between mux_fwd_1_out (typically rs1.data), the PC (ID_EX_PC) or 0 --
  mux_EX_ALUSrc1 : entity work.mux_3_1 port map(selection => ID_EX_ALUSrc1, input_0 => mux_fwd_1_out, input_1 => ID_EX_PC, input_2 => X"0000000000000000", output_0 => ALU_operand_1);
  -- Mux to choose between mux_fwd_2_out (tipically rs2.data), the immediate or 4 --
  mux_EX_ALUSrc2 : entity work.mux_3_1 port map(selection => ID_EX_ALUSrc2, input_0 => mux_fwd_2_out, input_1 => ID_EX_immediate, input_2 => X"0000000000000004", output_0 => ALU_operand_2);

  ALU_control_unit : entity work.ALU_control port map(ID_EX_ALUOp, ID_EX_insn_bit30, ID_EX_insn_bit25, ID_EX_funct3, ID_EX_insn_bit5, ID_EX_insn_bit3,  -- in
                                                      ALU_func);  -- out
  
  ALU : entity work.ALU port map(clock, reset, ALU_operand_1, ALU_operand_2, ALU_func,  -- in
                                 ALU_output, Stall_ALU, exc_type);  -- out  
  
  -- Need to send 0s to control lines going to EX/MEM while ALU is doing multiplication/division -- EX_MEM_FLush => Stall_ALU
  mux_EX_MEM_Flush : entity work.mux_EX_MEM_Flush port map(Stall_ALU, ID_EX_MemtoReg, ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite,  -- in
                                                                      EX_MemtoReg, EX_RegWrite, EX_MemRead, EX_MemWrite); -- out
  
  exception_unit : entity work.exception_unit port map(clock, reset, exc_type);

  EX_MEM_REGS : entity work.EX_MEM_DIV port map(clock, reset, 
                                               ALU_output, mux_fwd_2_out, ID_EX_funct3, ID_EX_register_rd, ID_EX_MemtoReg, ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite,  -- in
                                               EX_MEM_ALU_output, EX_MEM_mux_fwd_2_out, EX_MEM_funct3, EX_MEM_register_rd, EX_MEM_MemtoReg, EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite);  -- out
  
  data_memory_interface: entity work.datamem_interface port map(clock => clock, MemWrite => EX_MEM_MemWrite, MemRead => EX_MEM_MemRead, byte_address => EX_MEM_ALU_output, write_data => EX_MEM_mux_fwd_2_out, data_format => EX_MEM_funct3, 
                                                                read_data => datamem_output, debug_misaligned => debug_misaligned);
  
  MEM_WB_REGS : entity work.MEM_WB_DIV port map(clock, reset, 
                                                datamem_output, EX_MEM_ALU_output, EX_MEM_register_rd, EX_MEM_MemToReg, EX_MEM_RegWrite,  -- in
                                                MEM_WB_datamem_output, MEM_WB_ALU_output, MEM_WB_register_rd, MEM_WB_MemToReg, MEM_WB_RegWrite);  -- out
  
  mux_WB : entity work.mux_2_1_64b port map(selection => MEM_WB_MemToReg, input_0 => MEM_WB_ALU_output, input_1 => MEM_WB_datamem_output, output_0 => mux_WB_output);

end architecture structural;
