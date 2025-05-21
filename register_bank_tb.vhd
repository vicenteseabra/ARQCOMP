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
  signal    finished,clk_s,rst_s,wr_en_s    : std_logic := '0';
  signal    data_in_s,data_out_s : unsigned(15 downto 0) := (others => '0');
  signal    reg_code_s : unsigned(2 downto 0) := (others => '0');

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

    --reseta
  reset_global:process
  begin
    rst_s <= '1';
    wait for 200 ns; -- period_time*2
    rst_s <= '0';
    wait;
  end process;

  sim_time_proc:process
  begin
    wait for 10 us;     -- <== TEMPO TOTAL DA SIMULAÇÃO!!!
    finished <= '1';
    wait;
  end process;

  clk_proc:process
  begin
    while finished /= '1' loop  -- gera clock até que sim_time_proc termine
      clk_s <= '0';
      wait for 50 ns; -- metade do periodo
      clk_s <= '1';
      wait for 50 ns; -- metade do periodo
    end loop;
    wait;
  end process clk_proc;

process
  begin
    -- Teste 1: Escreve nos registradores

    wait for 200 ns; -- espera o reset
    wr_en_s <= '1';

    --reg1: Escreve no registrador 0
    data_in_s <= "0000000000000001";
    reg_code_s <= "000";
    wait for period_time;

    --reg2: Escreve no registrador 1
    data_in_s <= "0000000000000010";
    reg_code_s <= "001";
    wait for period_time;

    --reg3: Escreve no registrador 2
    data_in_s <= "0000000000000011";
    reg_code_s <= "010";
    wait for period_time;

    --reg4: Escreve no registrador 3
    data_in_s <= "0000000000000100";
    reg_code_s <= "011";
    wait for period_time;

    --reg5: Escreve no registrador 4
    data_in_s <= "0000000000000101";
    reg_code_s <= "100";
    wait for period_time;

    --reg6: Escreve no registrador 5
    data_in_s <= "0000000000000110";
    reg_code_s <= "101";
    wait for period_time;


    -- Teste 2: escreve nos registradores com wr_en desligado
    wait for 200 ns; -- espera o reset

     wr_en_s <= '0';

    --reg1: Escreve no registrador 0
    data_in_s <= "0000000000000000";
    reg_code_s <= "000";
    wait for period_time;

    --reg2: Escreve no registrador 1
    data_in_s <= "0000000000000000";
    reg_code_s <= "001";
    wait for period_time;

    --reg3: Escreve no registrador 2
    data_in_s <= "0000000000000000";
    reg_code_s <= "010";
    wait for period_time;

    --reg4: Escreve no registrador 3
    data_in_s <= "0000000000000000";
    reg_code_s <= "011";
    wait for period_time;

    --reg5: Escreve no registrador 4
    data_in_s <= "0000000000000000";
    reg_code_s <= "100";
    wait for period_time;

    --reg6: Escreve no registrador 5
    data_in_s <= "0000000000000000";
    reg_code_s <= "101";
    wait for period_time;
    wait;
  end process;
end architecture;