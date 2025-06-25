library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unidade_controle is
    port(
        clk             : in  std_logic;
        rst             : in  std_logic;
        fsm_estado_in   : in  unsigned(1 downto 0); -- "00" Fetch, "01" Decode, "10" Execute
        ir_instr_in     : in  unsigned(17 downto 0); -- Instrução do IR

        -- Flags da ULA
        ula_zero_in     : in  std_logic;
        ula_carry_in    : in  std_logic;

        -- Sinais de controle para PC_ROM
        pc_inc_en_out   : out std_logic;
        pc_jump_en_out  : out std_logic;
        pc_jump_addr_out: out unsigned(6 downto 0);
        pc_wr_en_out    : out std_logic; -- Sinal de escrita no PC

        -- Sinais de controle para IR
        ir_wr_en_out    : out std_logic;

        -- Sinais de controle para Datapath_Core
        debug_reg_wr_en_out  : out std_logic;
        debug_reg_read_addr_out: out unsigned(2 downto 0);
        debug_reg_write_addr_out: out unsigned(2 downto 0);
        mux_ula_ram_data : out std_logic; -- Seleção de dados para o banco de registradores (0: ULA, 1: RAM)
        debug_acc_wr_en_out  : out std_logic;
        debug_alu_sel_out    : out unsigned(1 downto 0);
        debug_bank_in_sel_out: out std_logic;             -- '0': ULA_result, '1': Immediate
        debug_imm_data_out   : out unsigned(15 downto 0);  -- Dado imediato para o datapath

        -- RAM
        ram_wr_en_out       : out std_logic
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
    constant NOP_OP        : unsigned(3 downto 0) := "0000"; -- No Operation
    constant LW_OP         : unsigned(3 downto 0) := "0001"; -- Load Word
    constant SW_OP         : unsigned(3 downto 0) := "0110"; -- Store Word (mesmo opcode do LW, mas com diferente controle na UC)
    constant ADD_ACC_OP    : unsigned(3 downto 0) := "0010"; -- ACC <=  Rs + ACC
    constant SUB_ACC_OP    : unsigned(3 downto 0) := "0011"; -- ACC <= Rs - ACC
    constant LD_OP         : unsigned(3 downto 0) := "0100"; -- Rd <= Imm
    constant MOV_RD_ACC_OP : unsigned(3 downto 0) := "0101"; -- Rd <= ACC
    constant MOV_ACC_RS_OP : unsigned(3 downto 0) := "0111"; -- ACC <= Rs
    constant CMP           : unsigned(3 downto 0) := "1000"; -- Comparação
    constant CMPI          : unsigned(3 downto 0) := "1001"; -- Comparação Imediato
    constant BNE_OP        : unsigned(3 downto 0) := "1101"; -- BNE (Branch if Not Equal)
    constant BCS_OP        : unsigned(3 downto 0) := "1110"; -- BCS (Branch if Carry Set)
    constant JMP_OP        : unsigned(3 downto 0) := "1111"; -- JMP

begin
    -- Decodificadores de campos da instrução
    opcode     <= ir_instr_in(17 downto 14);
    rd_field   <= ir_instr_in(12 downto 10);
    rs_field   <= ir_instr_in(2 downto 0); -- Para MOV_R_R, ADD_ACC, SUB_ACC, MOV_ACC_RS
    imm10_field <= ir_instr_in(9 downto 0); -- Para LD (10 bits)
    jmp_addr_field <= ir_instr_in(8 downto 2); -- Para JMP
    to_acc <= ir_instr_in(13); -- Para Load no ACC

    -- Lógica de Controle Principal
    process(fsm_estado_in, opcode, rd_field, rs_field, imm10_field, jmp_addr_field,rst)
    begin
        -- Valores padrão (desliga a maioria dos controles)
        pc_inc_en_out    <= '0';
        pc_jump_en_out   <= '0';
        pc_jump_addr_out <= (others => '0');
        ir_wr_en_out     <= '0';
        pc_wr_en_out     <= '0'; -- Sinal de escrita no PC
        ram_wr_en_out    <= '0'; -- Desliga escrita na RAM
        debug_reg_wr_en_out   <= '0';
        debug_reg_read_addr_out  <= (others => '0');
        debug_reg_write_addr_out <= (others => '0'); -- Padrão para o novo port
        debug_acc_wr_en_out   <= '0';
        debug_alu_sel_out     <= ALU_PASS_A;      -- ULA em modo inócuo
        debug_bank_in_sel_out <= '0';             -- Padrão: ULA_result para entrada do banco
        debug_imm_data_out    <= (others => '0');
        mux_ula_ram_data      <= '0';

        case fsm_estado_in is

            when "00" => -- FETCH
                ir_wr_en_out  <= '1'; -- Carrega a instrução no IR
                pc_inc_en_out <= '1'; -- Incrementa PC para a próxima instrução
                pc_wr_en_out  <= '1'; -- Permite escrita no PC


            when "01" => -- DECODE
                -- Para operações que usam Rs, já podemos setar debug_reg_addr_out.

                case opcode is
                    when LW_OP | SW_OP | ADD_ACC_OP | SUB_ACC_OP | MOV_ACC_RS_OP | CMP | BNE_OP =>
                        debug_reg_read_addr_out <= rs_field;
                    when others =>
                        debug_reg_read_addr_out <= (others => '0');
                end case;

            when "10" => -- EXECUTE
                case opcode is

                    when NOP_OP =>
                        null; -- Nenhuma ação

                    when LD_OP => -- Rd <= Immediate
                        case to_acc is
                            when '0' => -- Load no registrador
                                debug_reg_wr_en_out   <= '1';
                                mux_ula_ram_data <= '0'; -- Seleciona ULA_result
                                debug_reg_write_addr_out <= rd_field; -- Destino Rd
                                debug_bank_in_sel_out <= '1';
                                debug_alu_sel_out     <= ALU_PASS_B;  -- ULA passa o imediato
                                -- Estende sinal do imediato de 7 bits para 16 bits
                                debug_imm_data_out <= "000000" & imm10_field;
                                debug_acc_wr_en_out   <= '0';

                            when '1' => -- Load no ACC
                                debug_acc_wr_en_out   <= '1';
                                debug_bank_in_sel_out <= '1';
                                debug_imm_data_out <= "000000" & imm10_field;
                                debug_alu_sel_out     <= ALU_PASS_B;  -- ULA passa o imediato
                                debug_reg_wr_en_out   <= '0';
                                mux_ula_ram_data <= '0';

                            when others => null; -- Não faz nada
                        end case;
                    when LW_OP =>
                        debug_reg_read_addr_out  <= rs_field;  -- Endereço de LEITURA para obter o endereço da RAM
                        debug_reg_write_addr_out <= rd_field;  -- Endereço de ESCRITA para salvar o dado da RAM
                        debug_reg_wr_en_out   <= '1';        -- Habilita escrita no registrador de destino
                        mux_ula_ram_data      <= '1';        -- Seleciona o dado vindo da RAM para ser escrito

                    -- ALTERADO: Lógica para SW - Mem[Rs] <= ACC
                    when SW_OP =>
                        debug_reg_read_addr_out <= rs_field;  -- Seleciona o registrador que contém o endereço da RAM
                        ram_wr_en_out         <= '1';        -- Habilita a escrita na RAM (o dado vem do acumulador, já conectado no top-level)

                    when ADD_ACC_OP => -- ACC <= ACC + Rs
                        debug_reg_read_addr_out <= rs_field;
                        debug_alu_sel_out     <= ALU_ADD;
                        debug_acc_wr_en_out   <= '1';
                        debug_bank_in_sel_out <= '0';

                    when SUB_ACC_OP => -- ACC <= Rs - ACC
                        debug_reg_read_addr_out <= rs_field;
                        debug_alu_sel_out     <= ALU_SUB;
                        debug_acc_wr_en_out   <= '1';
                        debug_bank_in_sel_out <= '0';

                    when MOV_RD_ACC_OP => -- Rd <= ACC
                        debug_alu_sel_out     <= ALU_PASS_A;  -- ULA passa ACC
                        debug_reg_wr_en_out   <= '1';
                        debug_reg_write_addr_out <= rd_field;
                        debug_bank_in_sel_out <= '1';         -- Seleciona ULA_result (que é ACC)
                        mux_ula_ram_data <= '0';

                    when MOV_ACC_RS_OP => -- ACC <= Rs
                        debug_reg_read_addr_out <= rs_field; -- Rs para ACC
                        debug_alu_sel_out     <= ALU_PASS_B;  -- ULA passa Rs
                        mux_ula_ram_data <= '0';
                        debug_acc_wr_en_out   <= '1'; -- Escreve no ACC
                        debug_bank_in_sel_out <= '0'; -- Usa Rs do banco

                    when BNE_OP =>
                        case ula_zero_in is
                            when '1' => -- Se Zero for 1, não salta
                                pc_jump_en_out   <= '0';
                                pc_jump_addr_out <= (others => '0'); -- Não salta
                                pc_inc_en_out    <= '1'; -- Incrementa PC em BNE
                                pc_wr_en_out     <= '1'; -- Permite escrita no PC
                            when '0' => -- Se Zero for 0, salta
                                pc_jump_en_out   <= '1';
                                pc_jump_addr_out <= jmp_addr_field; -- Endereço de salto
                                pc_inc_en_out    <= '0'; -- Não incrementa PC em BNE
                                pc_wr_en_out     <= '1'; -- Permite escrita no PC
                            when others => -- Se Zero for outro valor, não faz nada
                                null;
                        end case;

                    when BCS_OP =>
                        case ula_carry_in is
                            when '0' => -- Se Carry for 0, salta
                                pc_jump_en_out   <= '1';
                                pc_jump_addr_out <= jmp_addr_field; -- Endereço de salto
                                pc_inc_en_out    <= '0'; -- Não incrementa PC em BCS
                                pc_wr_en_out     <= '1'; -- Permite escrita no PC
                            when '1' => -- Se Carry for 1, não salta
                                pc_jump_en_out   <= '0';
                                pc_jump_addr_out <= (others => '0'); -- Não salta
                                pc_inc_en_out    <= '1'; -- Incrementa PC em BCS
                                pc_wr_en_out     <= '1'; -- Permite escrita no PC
                            when others => -- Se Carry for outro valor, não faz nada
                                null;
                        end case;

                    when JMP_OP =>
                        pc_jump_en_out   <= '1';
                        pc_jump_addr_out <= jmp_addr_field;
                        pc_inc_en_out    <= '0'; -- Não incrementa PC em JMP
                        pc_wr_en_out     <= '1'; -- Permite escrita no PC

                    when CMP => -- Comparação Rg com Acc (pode ser usado para saltos condicionais)
                        debug_reg_read_addr_out <= rs_field; -- Rs para comparação
                        debug_alu_sel_out     <= ALU_SUB; -- ULA faz subtração
                        debug_acc_wr_en_out   <= '0'; -- Não escreve no ACC
                        debug_bank_in_sel_out <= '0'; -- Não usa imediato

                    when CMPI =>
                        debug_alu_sel_out     <= ALU_SUB; -- ULA faz subtração
                        debug_acc_wr_en_out   <= '0'; -- Não escreve no ACC
                        debug_bank_in_sel_out <= '1'; -- Usa imediato
                        debug_imm_data_out    <= "000000" & imm10_field; -- Imediato de 10 bits

                    when others => -- Instruções não implementadas
                        null;
                end case;
            when others => null;
        end case;
    end process;

end architecture a_unidade_controle;