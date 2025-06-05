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
        dp_reg_wr_en_out  : out std_logic;
        dp_reg_wr_addr_out: out unsigned(2 downto 0);
        dp_reg_rd_addr_out: out unsigned(2 downto 0);
        dp_acc_wr_en_out  : out std_logic;
        dp_alu_sel_out    : out unsigned(1 downto 0);
        dp_bank_in_sel_out: out std_logic;             -- '0': ULA_result, '1': Immediate
        dp_imm_data_out   : out unsigned(15 downto 0)  -- Dado imediato para o datapath
    );
end entity unidade_controle;

architecture a_unidade_controle of unidade_controle is
    -- Decodificação da Instrução
    signal opcode    : unsigned(3 downto 0);
    signal rd_field  : unsigned(4 downto 0); -- Campo Rd de 5 bits da instrução
    signal rs_field  : unsigned(4 downto 0); -- Campo Rs de 5 bits da instrução
    signal imm7_field: unsigned(6 downto 0); -- Campo imediato de 7 bits (com sinal)
    signal jmp_addr_field: unsigned(6 downto 0); -- Campo de endereço de JMP

    -- Sinais de registrador (3 LSBs dos campos de 5 bits)
    signal rd_reg_addr : unsigned(2 downto 0);
    signal rs_reg_addr : unsigned(2 downto 0);

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
    constant MOV_ACC_RS_OP : unsigned(3 downto 0) := "0101"; -- ACC <= Rs
    constant MOV_RD_ACC_OP : unsigned(3 downto 0) := "0110"; -- Rd <= ACC
    constant JMP_OP        : unsigned(3 downto 0) := "1111";

begin
    -- Decodificadores de campos da instrução
    opcode     <= ir_instr_in(17 downto 14);
    rd_field   <= ir_instr_in(11 downto 7);
    rs_field   <= ir_instr_in(6 downto 2); -- Para MOV_R_R, ADD_ACC, SUB_ACC, MOV_ACC_RS
    imm7_field <= ir_instr_in(6 downto 0); -- Para LD (7 bits com sinal)
    jmp_addr_field <= ir_instr_in(8 downto 2); -- Para JMP

    -- Usar os 3 LSBs para endereçar os 6 registradores
    rd_reg_addr <= rd_field(2 downto 0);
    rs_reg_addr <= rs_field(2 downto 0);

    -- Lógica de Controle Principal
    process(fsm_estado_in, opcode, rd_reg_addr, rs_reg_addr, imm7_field, jmp_addr_field)
    begin
        -- Valores padrão (desliga a maioria dos controles)
        pc_inc_en_out    <= '0';
        pc_jump_en_out   <= '0';
        pc_jump_addr_out <= (others => '0');
        ir_wr_en_out     <= '0';

        dp_reg_wr_en_out   <= '0';
        dp_reg_wr_addr_out <= (others => '0');
        dp_reg_rd_addr_out <= (others => '0'); -- Padrão pode ser R0 ou não importa se não lê
        dp_acc_wr_en_out   <= '0';
        dp_alu_sel_out     <= ALU_PASS_A;      -- ULA em modo inócuo
        dp_bank_in_sel_out <= '0';             -- Padrão: ULA_result para entrada do banco
        dp_imm_data_out    <= (others => '0');

        case fsm_estado_in is
            when "00" => -- FETCH
                pc_inc_en_out <= '1'; -- Incrementa PC para a próxima instrução
                ir_wr_en_out  <= '1'; -- Carrega a instrução no IR

            when "01" => -- DECODE
                -- Nesta fase, podemos pré-configurar endereços de leitura se necessário,
                -- mas a maioria da lógica de controle é ativada no EXECUTE.
                -- Para operações que usam Rs, já podemos setar dp_reg_rd_addr_out.
                case opcode is
                    when MOV_RR_OP | ADD_ACC_OP | SUB_ACC_OP | MOV_ACC_RS_OP =>
                        dp_reg_rd_addr_out <= rs_reg_addr;
                    when others =>
                        dp_reg_rd_addr_out <= (others => '0'); -- Ou um registrador padrão
                end case;

            when "10" => -- EXECUTE
                case opcode is
                    when NOP_OP =>
                        null; -- Nenhuma ação

                    when LD_OP => -- Rd <= Immediate
                        dp_reg_wr_en_out   <= '1';
                        dp_reg_wr_addr_out <= rd_reg_addr;
                        dp_bank_in_sel_out <= '1'; -- Seleciona imediato para entrada do banco
                        -- Estende sinal do imediato de 7 bits para 16 bits
                        if imm7_field(6) = '1' then -- Negativo
                            dp_imm_data_out <= "111111111" & imm7_field;
                        else -- Positivo
                            dp_imm_data_out <= "000000000" & imm7_field;
                        end if;

                    when MOV_RR_OP => -- Rd <= Rs
                        dp_reg_rd_addr_out <= rs_reg_addr; -- Fonte Rs
                        dp_alu_sel_out     <= ALU_PASS_B;  -- ULA passa Rs
                        dp_bank_in_sel_out <= '0';         -- Seleciona ULA_result para entrada do banco
                        dp_reg_wr_en_out   <= '1';
                        dp_reg_wr_addr_out <= rd_reg_addr; -- Destino Rd

                    when ADD_ACC_OP => -- ACC <= ACC + Rs
                        dp_reg_rd_addr_out <= rs_reg_addr;
                        dp_alu_sel_out     <= ALU_ADD;
                        dp_acc_wr_en_out   <= '1';

                    when SUB_ACC_OP => -- ACC <= ACC - Rs
                        dp_reg_rd_addr_out <= rs_reg_addr;
                        dp_alu_sel_out     <= ALU_SUB;
                        dp_acc_wr_en_out   <= '1';

                    when MOV_ACC_RS_OP => -- ACC <= Rs
                        dp_reg_rd_addr_out <= rs_reg_addr;
                        dp_alu_sel_out     <= ALU_PASS_B;
                        dp_acc_wr_en_out   <= '1';

                    when MOV_RD_ACC_OP => -- Rd <= ACC
                        dp_alu_sel_out     <= ALU_PASS_A;  -- ULA passa ACC
                        dp_bank_in_sel_out <= '0';         -- Seleciona ULA_result (que é ACC)
                        dp_reg_wr_en_out   <= '1';
                        dp_reg_wr_addr_out <= rd_reg_addr;

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