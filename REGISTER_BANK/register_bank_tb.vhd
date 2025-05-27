library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_bank_tb is
end entity;

architecture a_register_bank_tb of register_bank_tb is
  component register_bank is
    port(
        data_in   : in unsigned(15 downto 0);
        clk       : in std_logic;
        wr_en     : in std_logic;
        reg_code  : in unsigned(2 downto 0);
        rst       : in std_logic;
        data_out  : out unsigned(15 downto 0)
    );
  end component;

  -- Sinais para conectar ao componente
  constant period_time  : time := 100 ns;
  signal    finished,clk_s,wr_en_s    : std_logic := '0';
  signal    rst_s : std_logic := '1'; -- Inicializa reset como ativo
  signal    data_in_s,data_out_s : unsigned(15 downto 0) := (others => '0');
  signal    reg_code_s : unsigned(2 downto 0) := (others => '0');

  -- Sinais para melhor visualização
  signal teste_atual : integer := 0; -- Sinal para identificar fase de teste atual

  -- Instanciação do componente
begin
  UTT: register_bank port map (
    data_in   => data_in_s,
    clk       => clk_s,
    wr_en     => wr_en_s,
    reg_code  => reg_code_s,
    rst       => rst_s,
    data_out  => data_out_s
  );


  -- Tempo total da simulação
  sim_time_proc:process
  begin
    wait for 20 us; -- Tempo suficiente para todos os testes
    finished <= '1';
    wait;
  end process;

  -- Geração de clock
  clk_proc:process
  begin
    while finished /= '1' loop
      clk_s <= '0';
      wait for 50 ns;
      clk_s <= '1';
      wait for 50 ns;
    end loop;
    wait;
  end process clk_proc;

  -- Processo de teste principal
  test_proc: process
  begin

    -- Inicialização
    wr_en_s <= '0';
    data_in_s <= (others => '0');
    reg_code_s <= "000";
    teste_atual <= 0;

     -- Reset inicial
    rst_s <= '1'; -- Reset ativo
    wait for 200 ns;
    rst_s <= '0'; -- Desativa reset

    -- Espera um pouco para garantir
    wait for 100 ns;
    teste_atual <= 1; -- Indicador para GTKWave

    -- Teste 1: Escreve nos registradores
    wr_en_s <= '1';

    -- Escreve 1 no registrador 0
    data_in_s <= x"0001";
    reg_code_s <= "000";
    wait for period_time;

    -- Escreve 2 no registrador 1
    data_in_s <= x"0002";
    reg_code_s <= "001";
    wait for period_time;

    -- Escreve 3 no registrador 2
    data_in_s <= x"0003";
    reg_code_s <= "010";
    wait for period_time;

    -- Escreve 4 no registrador 3
    data_in_s <= x"0004";
    reg_code_s <= "011";
    wait for period_time;

    -- Escreve 5 no registrador 4
    data_in_s <= x"0005";
    reg_code_s <= "100";
    wait for period_time;

    -- Escreve 6 no registrador 5
    data_in_s <= x"0006";
    reg_code_s <= "101";
    wait for period_time;

    teste_atual <= 2; -- Indicador para GTKWave

    -- Teste 2: Lê todos os registradores
    wr_en_s <= '0';

    -- Lê registrador 0, deve mostrar 1
    reg_code_s <= "000";
    wait for period_time;

    -- Lê registrador 1, deve mostrar 2
    reg_code_s <= "001";
    wait for period_time;

    -- Lê registrador 2, deve mostrar 3
    reg_code_s <= "010";
    wait for period_time;

    -- Lê registrador 3, deve mostrar 4
    reg_code_s <= "011";
    wait for period_time;

    -- Lê registrador 4, deve mostrar 5
    reg_code_s <= "100";
    wait for period_time;

    -- Lê registrador 5, deve mostrar 6
    reg_code_s <= "101";
    wait for period_time;

    teste_atual <= 3; -- Indicador para GTKWave

    -- Teste 3: Tenta escrever com wr_en desligado
    data_in_s <= x"FFFF"; -- Valor diferente para confirmar que não vai mudar

    -- Tenta escrever FFFF no registrador 0
    reg_code_s <= "000";
    wait for period_time;

    -- Lê registrador 0 novamente, deve continuar 1
    reg_code_s <= "000";
    wait for period_time;

    teste_atual <= 4; -- Indicador para GTKWave

    -- Teste 4: Escreve com wr_en ligado novamente
    wr_en_s <= '1';

    -- Escreve FF no registrador 2
    data_in_s <= x"00FF";
    reg_code_s <= "010";
    wait for period_time;

    -- Lê registrador 2, deve mostrar FF
    wr_en_s <= '0';
    reg_code_s <= "010";
    wait for period_time;

    -- Lê todos os registradores novamente para confirmar que só o 2 mudou
    reg_code_s <= "000"; -- Deve mostrar 1
    wait for period_time;

    reg_code_s <= "001"; -- Deve mostrar 2
    wait for period_time;

    reg_code_s <= "010"; -- Deve mostrar FF
    wait for period_time;

    reg_code_s <= "011"; -- Deve mostrar 4
    wait for period_time;

    reg_code_s <= "100"; -- Deve mostrar 5
    wait for period_time;

    reg_code_s <= "101"; -- Deve mostrar 6
    wait for period_time;

    teste_atual <= 5; -- Indicador para GTKWave

    -- Teste 5: Verificar comportamento com reset
    rst_s <= '1';
    wait for period_time*2; -- Espera 2 ciclos para garantir que o reset seja aplicado
    rst_s <= '0';
    wait for period_time; -- Espera mais um ciclo após desativar o reset

    -- Lê todos os registradores novamente, devem estar zerados
    reg_code_s <= "000"; -- Deve mostrar 0
    wait for period_time;

    reg_code_s <= "001"; -- Deve mostrar 0
    wait for period_time;

    reg_code_s <= "010"; -- Deve mostrar 0
    wait for period_time;

    reg_code_s <= "011"; -- Deve mostrar 0
    wait for period_time;

    reg_code_s <= "100"; -- Deve mostrar 0
    wait for period_time;

    reg_code_s <= "101"; -- Deve mostrar 0
    wait for period_time;

    teste_atual <= 6; -- Teste adicional

    -- Teste adicional: Reescreve nos registradores após reset
    wr_en_s <= '1';

    -- Escreve 42 no registrador 3
    data_in_s <= x"002A"; -- 42 em hex
    reg_code_s <= "011";
    wait for period_time;

    -- Lê registrador 3
    wr_en_s <= '0';
    wait for period_time;

    teste_atual <= 7; -- Fim dos testes

    wait; -- Finaliza o processo de teste
  end process test_proc;
end architecture;