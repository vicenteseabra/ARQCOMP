library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unidade_controle_tb is
end entity unidade_controle_tb;

architecture behavioral of unidade_controle_tb is

    -- Componente unidade_controle a ser testado
    component unidade_controle is
        port(
            clk            : in  std_logic;
            rst            : in  std_logic;
            estado         : out std_logic;
            pc_out         : out unsigned(6 downto 0);
            instr_out      : out unsigned(17 downto 0);
            bank_wr_en     : out std_logic;
            reg_code_wr    : out unsigned(2 downto 0);
            bank_data_in   : out unsigned(15 downto 0);
            reg_code_rd    : out unsigned(2 downto 0);
            bank_read_data : in  unsigned(15 downto 0);
            acc_wr_en      : out std_logic;
            alu_sel        : out unsigned(1 downto 0);
            jump           : out std_logic;
            jump_addr      : out unsigned(6 downto 0)
        );
    end component;

    -- Sinais para conectar à unidade_controle
    signal s_clk            : std_logic := '0';
    signal s_rst            : std_logic;
    signal s_estado         : std_logic;
    signal s_pc_out         : unsigned(6 downto 0);
    signal s_instr_out      : unsigned(17 downto 0);
    signal s_bank_wr_en     : std_logic;
    signal s_reg_code_wr    : unsigned(2 downto 0);
    signal s_bank_data_in   : unsigned(15 downto 0);
    signal s_reg_code_rd    : unsigned(2 downto 0);
    signal s_bank_read_data : unsigned(15 downto 0) := (others => '0'); -- Mocked input
    signal s_acc_wr_en      : std_logic;
    signal s_alu_sel        : unsigned(1 downto 0);
    signal s_jump           : std_logic;
    signal s_jump_addr      : unsigned(6 downto 0);

    -- Constantes de simulação
    constant CLK_PERIOD : time := 10 ns;

    -- Para simular o conteúdo dos registradores para a instrução MOV
    -- Estes valores seriam escritos por instruções LD anteriores.
    constant R3_VALUE_FROM_LD : unsigned(15 downto 0) := to_unsigned(5, 16);
    constant R4_VALUE_FROM_LD : unsigned(15 downto 0) := to_unsigned(8, 16);

begin

    -- Instanciação da Unidade de Controle (UUT)
    uut: unidade_controle
        port map(
            clk            => s_clk,
            rst            => s_rst,
            estado         => s_estado,
            pc_out         => s_pc_out,
            instr_out      => s_instr_out,
            bank_wr_en     => s_bank_wr_en,
            reg_code_wr    => s_reg_code_wr,
            bank_data_in   => s_bank_data_in,
            reg_code_rd    => s_reg_code_rd,
            bank_read_data => s_bank_read_data,
            acc_wr_en      => s_acc_wr_en,
            alu_sel        => s_alu_sel,
            jump           => s_jump,
            jump_addr      => s_jump_addr
        );

    -- Processo de geração de Clock
    clk_process : process
    begin
        loop
            s_clk <= '0';
            wait for CLK_PERIOD / 2;
            s_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process clk_process;

    -- Processo para simular o bank_read_data
    -- Responde ao s_reg_code_rd durante o estado de DECODE
    mock_bank_read_process : process(s_clk)
    begin
        if rising_edge(s_clk) then
            if s_estado = '1' then -- Assume que reg_code_rd é válido no estado DECODE
                case s_reg_code_rd is
                    when "011" => -- Código para R3 (assumindo src5_s(2 downto 0))
                        s_bank_read_data <= R3_VALUE_FROM_LD;
                        report "TB: Fornecendo valor de R3 (" & to_string(R3_VALUE_FROM_LD) & ") para bank_read_data.";
                    when "100" => -- Código para R4
                        s_bank_read_data <= R4_VALUE_FROM_LD;
                        report "TB: Fornecendo valor de R4 (" & to_string(R4_VALUE_FROM_LD) & ") para bank_read_data.";
                    when others =>
                        s_bank_read_data <= (others => '0'); -- Valor padrão para outros registradores
                end case;
            end if;
        end if;
    end process mock_bank_read_process;

    -- Processo de Estímulo e Verificação
    stimulus_process : process
    begin
        report "TB_UNIDADE_CONTROLE: Iniciando simulação...";

        -- 1. Aplicar Reset
        s_rst <= '1';
        report "TB: Reset Ativado.";
        wait for CLK_PERIOD * 2;
        s_rst <= '0';
        report "TB: Reset Desativado.";
        wait for CLK_PERIOD / 4; -- Alinhar com borda de clock

        -- A UC agora deve começar a buscar e decodificar instruções da sua ROM interna.
        -- Vamos observar os sinais de saída por alguns ciclos.

        -- Ciclo 1: Fetch PC=0 (LD R3, #5)
        wait until rising_edge(s_clk) and s_estado = '0'; -- Espera estado FETCH
        report "TB: FETCH - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);
        assert s_pc_out = 0 report "Falha: PC inicial não é 0 após reset." severity warning;

        wait until rising_edge(s_clk) and s_estado = '1'; -- Espera estado DECODE
        report "TB: DECODE - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);
        -- Verificar sinais para LD R3, #5 (opcode "0100", dest "011", imm "000101" -> 5)
        -- Instr: "010001000110000101"
        assert s_instr_out = "010001000110000101" report "Falha: Instrução em PC=0 não é LD R3, #5" severity error;
        assert s_bank_wr_en = '1' report "Falha LD: bank_wr_en deveria ser 1" severity error;
        assert s_reg_code_wr = "011" report "Falha LD: reg_code_wr deveria ser R3 (011)" severity error;
        assert s_bank_data_in = to_unsigned(5, 16) report "Falha LD: bank_data_in deveria ser 5" severity error;
        assert s_acc_wr_en = '0' report "Falha LD: acc_wr_en deveria ser 0" severity error;
        assert s_jump = '0' report "Falha LD: jump deveria ser 0" severity error;

        -- Ciclo 2: Fetch PC=1 (LD R4, #8)
        wait until rising_edge(s_clk) and s_estado = '0';
        report "TB: FETCH - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);

        wait until rising_edge(s_clk) and s_estado = '1';
        report "TB: DECODE - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);
        -- Verificar sinais para LD R4, #8 (opcode "0100", dest "100", imm "001000" -> 8)
        -- Instr: "010001001000001000"
        assert s_instr_out = "010001001000001000" report "Falha: Instrução em PC=1 não é LD R4, #8" severity error;
        assert s_bank_wr_en = '1' report "Falha LD: bank_wr_en deveria ser 1" severity error;
        assert s_reg_code_wr = "100" report "Falha LD: reg_code_wr deveria ser R4 (100)" severity error;
        assert s_bank_data_in = to_unsigned(8, 16) report "Falha LD: bank_data_in deveria ser 8" severity error;

        -- Ciclo 3: Fetch PC=2 (MOV R5, R3)
        wait until rising_edge(s_clk) and s_estado = '0';
        report "TB: FETCH - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);

        wait until rising_edge(s_clk) and s_estado = '1';
        report "TB: DECODE - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);
        -- Verificar sinais para MOV R5, R3 (opcode "0001", dest "101", src "011")
        -- Instr: "000100001010001100"
        -- mock_bank_read_process deve ter fornecido R3_VALUE_FROM_LD para s_bank_read_data
        assert s_instr_out = "000100001010001100" report "Falha: Instrução em PC=2 não é MOV R5, R3" severity error;
        assert s_bank_wr_en = '1' report "Falha MOV: bank_wr_en deveria ser 1" severity error;
        assert s_reg_code_wr = "101" report "Falha MOV: reg_code_wr deveria ser R5 (101)" severity error;
        assert s_reg_code_rd = "011" report "Falha MOV: reg_code_rd deveria ser R3 (011)" severity error;
        assert s_bank_data_in = R3_VALUE_FROM_LD report "Falha MOV: bank_data_in deveria ser o valor de R3" severity error;
        assert s_acc_wr_en = '0' report "Falha MOV: acc_wr_en deveria ser 0" severity error;

        -- Ciclo 4: Fetch PC=3 (ADD R5, R4) -> Resultado vai para ACC
        wait until rising_edge(s_clk) and s_estado = '0';
        report "TB: FETCH - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);

        wait until rising_edge(s_clk) and s_estado = '1';
        report "TB: DECODE - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);
        -- Verificar sinais para ADD R5, R4 (opcode "0010", dest "101" (ignorado para escrita no banco), src "100")
        -- Instr: "001000001010010000"
        -- mock_bank_read_process deve ter fornecido R4_VALUE_FROM_LD para s_bank_read_data
        assert s_instr_out = "001000001010010000" report "Falha: Instrução em PC=3 não é ADD R5, R4" severity error;
        assert s_bank_wr_en = '0' report "Falha ADD: bank_wr_en deveria ser 0 (resultado no ACC)" severity error;
        assert s_reg_code_rd = "100" report "Falha ADD: reg_code_rd deveria ser R4 (100)" severity error;
        assert s_acc_wr_en = '1' report "Falha ADD: acc_wr_en deveria ser 1" severity error;
        assert s_alu_sel = "00" report "Falha ADD: alu_sel deveria ser ADD (00)" severity error;


        -- Ciclo com JMP: Supondo que PC agora é 6 (após LD,LD,MOV,ADD,LD,SUB)
        -- Para simplificar, vamos avançar o PC artificialmente ou rodar mais ciclos.
        -- Vamos assumir que a ROM interna fará o PC chegar em 6.
        report "TB: Rodando ciclos até PC=6 para testar JMP...";
        loop
            wait until rising_edge(s_clk) and s_estado = '0'; -- Espera FETCH
            if s_pc_out = 6 then
                exit;
            end if;
            wait until rising_edge(s_clk) and s_estado = '1'; -- Espera DECODE
        end loop;

        report "TB: FETCH - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);
        assert s_pc_out = 6 report "Falha: PC não é 6 para o JMP" severity error;

        wait until rising_edge(s_clk) and s_estado = '1'; -- Espera DECODE
        report "TB: DECODE - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);
        -- Verificar JMP 20 (opcode "1111", abs_addr "0010100" -> 20)
        -- Instr: "111100001010000000"
        assert s_instr_out = "111100001010000000" report "Falha: Instrução em PC=6 não é JMP 20" severity error;
        assert s_jump = '1' report "Falha JMP: jump deveria ser 1" severity error;
        assert s_jump_addr = to_unsigned(20, 7) report "Falha JMP: jump_addr deveria ser 20" severity error;

        -- Verificar se o PC atualiza para o endereço do JUMP no próximo ciclo de FETCH
        wait until rising_edge(s_clk) and s_estado = '0';
        report "TB: FETCH após JMP - PC=" & to_string(s_pc_out) & " Instr=" & to_string(s_instr_out);
        assert s_pc_out = 20 report "Falha JMP: PC não atualizou para 20 após JMP" severity error;


        report "TB_UNIDADE_CONTROLE: Simulação concluída.";
        wait; -- Fim da simulação
    end process stimulus_process;

end architecture behavioral;