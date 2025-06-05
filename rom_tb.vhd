library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity rom_tb is
end entity rom_tb;

architecture func of rom_tb is

    -- Componente da ROM (com saída de 18 bits)
    component rom is
        port(
            clk      : in  std_logic;
            endereco : in  unsigned(6 downto 0); -- Mesmo tamanho de endereço
            dado     : out unsigned(17 downto 0) -- Tamanho  ROM
        );
    end component rom;

    -- Sinais do Testbench
    signal s_clk     : std_logic := '0';
    signal s_address : unsigned(6 downto 0) := (others => '0');
    signal s_data_out: unsigned(17 downto 0); -- Para conectar à saída da ROM
    constant period_time : time      := 100 ns; -- Mantido do seu exemplo
    signal finished  : std_logic := '0';    -- Sinal para controlar o fim da simulação

    -- Conteúdo esperado da ROM para verificação (adapte aos seus valores)
    -- Apenas alguns exemplos para demonstração das asserções
    constant ROM_ADDR_0_EXPECTED : unsigned(17 downto 0) := "010001000110000101"; -- LD R3, #5
    constant ROM_ADDR_1_EXPECTED : unsigned(17 downto 0) := "010001001000001000"; -- LD R4, #8
    constant ROM_ADDR_6_EXPECTED : unsigned(17 downto 0) := "111100001010000000"; -- JMP 20
    constant ROM_ADDR_8_EXPECTED : unsigned(17 downto 0) := "000000000000000000"; -- NOP

begin
    -- Instanciação da Unidade Sob Teste (UUT - ROM)
    uut: rom
        port map(
            clk      => s_clk,
            endereco => s_address,
            dado     => s_data_out
        );

    -- Processo para controlar o tempo total da simulação
    sim_time_process: process
    begin
        wait for 2 us; -- Tempo total de simulação
        finished <= '1';
        report "SIM_TIME_PROCESS: Tempo de simulação esgotado. Finalizando...";
        wait;
    end process sim_time_process;

    -- Processo de geração de Clock
    clk_proc: process
    begin
        while finished /= '1' loop
            s_clk <= '0';
            wait for period_time / 2;
            s_clk <= '1';
            wait for period_time / 2;
        end loop;
        report "CLK_PROC: Sinal 'finished' recebido. Parando clock.";
        wait;
    end process clk_proc;

    -- Processo de estímulo e verificação
    stimulus_proc: process
        -- Variável para log, se necessário (requer textio)
        -- variable L: LINE;
    begin
        report "STIMULUS_PROC: Iniciando teste de verificação da ROM...";

        -- Aguarda o primeiro ciclo de clock para estabilização
        wait for period_time;

        -- Teste para Endereço 0
        s_address <= to_unsigned(0, s_address'length); -- Endereço 0
        wait for period_time; -- Aguarda o dado ser lido após a próxima borda de clock
        -- write(L, string'("TB: Endereco=0, Lido=")); write(L, s_data_out); writeline(output, L);
        report "TB: Endereco=0, Lido=" & to_string(s_data_out);
        assert s_data_out = ROM_ADDR_0_EXPECTED
            report "Falha no Endereco 0! Lido: " & to_string(s_data_out) & " Esperado: " & to_string(ROM_ADDR_0_EXPECTED)
            severity error;

        -- Teste para Endereço 1
        s_address <= to_unsigned(1, s_address'length); -- Endereço 1
        wait for period_time;
        report "TB: Endereco=1, Lido=" & to_string(s_data_out);
        assert s_data_out = ROM_ADDR_1_EXPECTED
            report "Falha no Endereco 1! Lido: " & to_string(s_data_out) & " Esperado: " & to_string(ROM_ADDR_1_EXPECTED)
            severity error;

        -- Teste para Endereço 6
        s_address <= to_unsigned(6, s_address'length); -- Endereço 6
        wait for period_time;
        report "TB: Endereco=6, Lido=" & to_string(s_data_out);
        assert s_data_out = ROM_ADDR_6_EXPECTED
            report "Falha no Endereco 6! Lido: " & to_string(s_data_out) & " Esperado: " & to_string(ROM_ADDR_6_EXPECTED)
            severity error;

        -- Teste para Endereço 8 (NOP)
        s_address <= to_unsigned(8, s_address'length); -- Endereço 8
        wait for period_time;
        report "TB: Endereco=8, Lido=" & to_string(s_data_out);
        assert s_data_out = ROM_ADDR_8_EXPECTED
            report "Falha no Endereco 8! Lido: " & to_string(s_data_out) & " Esperado: " & to_string(ROM_ADDR_8_EXPECTED)
            severity error;

        -- pois tentará acessar conteudo_rom(23) que está fora dos limites do array.
       -- report "TB: Testando endereco fora do range (23)...";
       -- s_address <= to_unsigned(23, s_address'length);
       -- wait for period_time;
      --  report "TB: Endereco=23, Lido=" & to_string(s_data_out) & " (Esperado erro de runtime na UUT ou valor indefinido)";

        report "STIMULUS_PROC: Testes principais concluídos. Aguardando fim da simulação...";
        wait until finished = '1'; -- Aguarda o sinal de 'finished' do sim_time_process
        report "STIMULUS_PROC: Sinal 'finished' recebido. Encerrando processo de estímulo.";
        wait; -- Mantém o processo parado até o fim da simulação
    end process stimulus_proc;

end architecture func;