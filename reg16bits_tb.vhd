library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg16bits_tb is
end ;

architecture a_reg16bits_tb of reg16bits_tb is
  component reg16bits is
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        wr_en    : in std_logic;
        data_in  : in unsigned(15 downto 0);
        data_out : out unsigned(15 downto 0)
    );
  end component;

  -- Sinais para conectar ao componente
  constant period_time  : time := 100 ns;

  signal    finished,clk_s,rst_s,wr_en_s    :   std_logic := '0';
  signal    data_in_s,data_out_s            :   unsigned(15 downto 0) := "0000000000000000";

  -- Instanciação do componente
begin
  UUT: reg16bits port map (
    clk      => clk_s,
    rst      => rst_s,
    wr_en    => wr_en_s,
    data_in  => data_in_s,
    data_out => data_out_s
  );

  --reseta
  reset_global:process
  begin
    rst_s <= '1';
    wait for period_time*2;
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
      wait for period_time/2;
      clk_s <= '1';
      wait for period_time/2;
    end loop;
    wait;
  end process clk_proc;

  process                      -- sinais dos casos de teste
   begin
    wait for 200 ns;  -- <== TEMPO DE ESPERA ANTES DO INICIO DOS TESTES
      --teste 1: escrita de 16 bits
      wr_en_s <= '1';
      data_in_s <= "0000000000000001";
      wait for 100 ns;

        --teste 2: sobreescrita de 16 bits
      data_in_s <= "0000000000000010";
      wait for 100 ns;


      --teste 3: escrita de 16 bits pra enable 0
      wr_en_s <= '0';
      data_in_s <= "0000000000000011";
      wait for 100 ns;
      wait;
  end process;
end architecture;