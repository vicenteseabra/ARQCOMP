library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unidade_controle_tb is
end entity;

architecture a_unidade_controle_tb of unidade_controle_tb is
   component unidade_controle is
      port(
         clk       : in std_logic;
         rst       : in std_logic;
         estado    : out std_logic;
         pc_out    : out unsigned(6 downto 0);
         instr_out : out unsigned(17 downto 0)
      );
   end component;

   -- Sinais de teste (sem direção - são apenas sinais locais)
   signal clk_in    : std_logic := '0';
   signal rst_in    : std_logic := '1';  -- Iniciar com reset ativo
   signal estado    : std_logic := '0';
   signal pc_out    : unsigned(6 downto 0) := (others => '0');
   signal instr_out : unsigned(17 downto 0) := (others => '0');

   -- Clock
   constant periodo : time := 10 ns;

begin
   -- Instancia a unidade de controle
   uut: unidade_controle port map(
      clk       => clk_in,
      rst       => rst_in,
      estado    => estado,
      pc_out    => pc_out,
      instr_out => instr_out
   );

   -- Geração de clock
   process
   begin
      clk_in <= '0';
      wait for periodo/2;
      clk_in <= '1';
      wait for periodo/2;
   end process;

   -- Estímulos
   process
   begin
      -- Garantir que o reset esteja ativo por pelo menos um ciclo completo
      rst_in <= '1';
      wait for periodo * 2;

      -- Remove o reset e deixa executar
      rst_in <= '0';

      -- Executa um número adequado de ciclos para ver todo o programa
      wait for 30 * periodo;

      wait;
   end process;
end architecture;