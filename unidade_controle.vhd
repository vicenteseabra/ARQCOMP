library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unidade_controle is
    port(
        clk             : in  std_logic;
        rst             : in  std_logic;
        fsm_estado_in   : in  unsigned(1 downto 0); -- "00" Fetch, "01" Decode, "10" Execute
        ir_instr_in     : in  unsigned(17 downto 0); -- Instrução do IR

        -- Flags da ULA (para futuras instruções condicionais)
        -- ula_zero_in     : in  std_logic;
        -- ula_carry_in    : in  std_logic;
        -- ula_neg_in      : in  std_logic;

        -- Sinais de controle para PC_ROM_Interface
        pc_inc_en_out   : out std_logic;
        pc_jump_en_out  : out std_logic;
        pc_jump_addr_out: out unsigned(6 downto 0);

        -- Sinais de controle para IR
        ir_wr_en_out    : out std_logic;

        -- Sinais de controle para Datapath_Core
        debug_reg_wr_en_out  : out std_logic;
        debug_reg_addr_out: out unsigned(2 downto 0);
        debug_acc_wr_en_out  : out std_logic;
        debug_alu_sel_out    : out unsigned(1 downto 0);
        debug_bank_in_sel_out: out std_logic;             -- '0': ULA_result, '1': Immediate
        debug_imm_data_out   : out unsigned(15 downto 0)  -- Dado imediato para o datapath
    );
end entity unidade_controle;

architecture a_unidade_controle of unidade_controle is

    -- Decodificação da Instrução
    signal opcode    : unsigned(3 downto 0);
    signal rd_field  : unsigned(2 downto 0); -- Campo Rd de 5 bits da instrução
    signal rs_field  : unsigned(2 downto 0); -- Campo Rs de 5 bits da instrução
    signal imm10_field: unsigned(9 downto 0); -- Campo imediato de 10 bits (com sinal)
    signal jmp_addr_field: unsigned(6 downto 0); -- Campo de endereço de JMP
    signal to_acc : std_logic; -- Sinal para indicar se o imediato vai para o ACC ou registrador

    -- Constantes para ALU_SEL
    constant ALU_ADD   : unsigned(1 downto 0) := "00";
    constant ALU_SUB   : unsigned(1 downto 0) := "01";
    constant ALU_PASS_B: unsigned(1 downto 0) := "10";
    constant ALU_PASS_A: unsigned(1 downto 0) := "11"; -- Ou NOP ULA

    -- Opcodes definidos na ROM
    constant NOP_OP        : unsigned(3 downto 0) := "0000";
    constant MOV_RR_OP     : unsigned(3 downto 0) := "0001"; -- Rd <= Rs
    constant ADD_ACC_OP    : unsigned(3 downto 0) := "0010"; -- ACC <= ACC + Rs
    constant SUB_ACC_OP    : unsigned(3 downto 0) := "0011"; -- ACC <= ACC - Rs
    constant LD_OP         : unsigned(3 downto 0) := "0100"; -- Rd <= Imm
    constant MOV_RD_ACC_OP : unsigned(3 downto 0) := "0101"; -- Rd <= ACC
    constant JMP_OP        : unsigned(3 downto 0) := "1111";

begin
    -- Decodificadores de campos da instrução
    opcode     <= ir_instr_in(17 downto 14);
    rd_field   <= ir_instr_in(12 downto 10);
    rs_field   <= ir_instr_in(2 downto 0); -- Para MOV_R_R, ADD_ACC, SUB_ACC, MOV_ACC_RS
    imm10_field <= ir_instr_in(9 downto 0); -- Para LD (10 bits)
    jmp_addr_field <= ir_instr_in(8 downto 2); -- Para JMP
    to_acc <= ir_instr_in(13); -- Para Load no ACC

    -- Lógica de Controle Principal
    process(fsm_estado_in, opcode, rd_field, rs_field, imm10_field, jmp_addr_field)
    begin
        -- Valores padrão (desliga a maioria dos controles)
        pc_inc_en_out    <= '0';
        pc_jump_en_out   <= '0';
        pc_jump_addr_out <= (others => '0');
        ir_wr_en_out     <= '0';

        debug_reg_wr_en_out   <= '0';
        debug_reg_addr_out <= (others => '0');
        debug_acc_wr_en_out   <= '0';
        debug_alu_sel_out     <= ALU_PASS_A;      -- ULA em modo inócuo
        debug_bank_in_sel_out <= '0';             -- Padrão: ULA_result para entrada do banco
        debug_imm_data_out    <= (others => '0');

        case fsm_estado_in is
            when "00" => -- FETCH
                pc_inc_en_out <= '1'; -- Incrementa PC para a próxima instrução
                ir_wr_en_out  <= '1'; -- Carrega a instrução no IR

            when "01" => -- DECODE
                -- Nesta fase, podemos pré-configurar endereços de leitura se necessário,
                -- mas a maioria da lógica de controle é ativada no EXECUTE.
                -- Para operações que usam Rs, já podemos setar debug_reg_addr_out.
                case opcode is
                    when MOV_RR_OP | ADD_ACC_OP | SUB_ACC_OP =>
                        debug_reg_addr_out <= rs_field;
                    when others =>
                        debug_reg_addr_out <= (others => '0'); -- Ou um registrador padrão
                end case;

            when "10" => -- EXECUTE
                case opcode is

                    when NOP_OP =>
                        null; -- Nenhuma ação

                    when LD_OP => -- Rd <= Immediate
                        case to_acc is
                            when '0' => -- Load no registrador
                                debug_reg_wr_en_out   <= '1';
                                debug_reg_addr_out <= rd_field; -- Destino Rd
                                debug_bank_in_sel_out <= '1'; -- Seleciona imediato para entrada do banco
                                -- Estende sinal do imediato de 7 bits para 16 bits
                                debug_imm_data_out <= "000000" & imm10_field;

                            when '1' => -- Load no ACC
                                debug_acc_wr_en_out   <= '1';
                                debug_bank_in_sel_out <= '1';
                                debug_imm_data_out <= "000000" & imm10_field;
                                debug_alu_sel_out     <= ALU_PASS_B;  -- ULA passa o imediato
                                debug_reg_wr_en_out   <= '0';


                            when others => null; -- Não faz nada

                        end case;


                    when MOV_RR_OP => -- Rd <= Rs
                        debug_reg_addr_out <= rs_field; -- Fonte Rs
                        debug_alu_sel_out     <= ALU_PASS_B;  -- ULA passa Rs
                        debug_bank_in_sel_out <= '0';         -- Seleciona ULA_result para entrada do banco
                        debug_reg_wr_en_out   <= '1';
                        debug_reg_addr_out <= rd_field; -- Destino Rd

                    when ADD_ACC_OP => -- ACC <= ACC + Rs
                        debug_reg_addr_out <= rs_field;
                        debug_alu_sel_out     <= ALU_ADD;
                        debug_acc_wr_en_out   <= '1';

                    when SUB_ACC_OP => -- ACC <= ACC - Rs
                        debug_reg_addr_out <= rs_field;
                        debug_alu_sel_out     <= ALU_SUB;
                        debug_acc_wr_en_out   <= '1';

                    when MOV_RD_ACC_OP => -- Rd <= ACC
                        debug_alu_sel_out     <= ALU_PASS_A;  -- ULA passa ACC
                        debug_bank_in_sel_out <= '0';         -- Seleciona ULA_result (que é ACC)
                        debug_reg_wr_en_out   <= '1';
                        debug_reg_addr_out <= rd_field;

                    when JMP_OP =>
                        pc_jump_en_out   <= '1';
                        pc_jump_addr_out <= jmp_addr_field;
                        pc_inc_en_out    <= '0'; -- Não incrementa PC em JMP

                    when others => -- Instruções não implementadas
                        null;
                end case;
            when others => null;
        end case;
    end process;

end architecture a_unidade_controle;