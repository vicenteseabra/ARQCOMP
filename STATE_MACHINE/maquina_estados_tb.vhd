library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maquina_estados_tb is
end entity;

architecture a_maquina_estados_tb of maquina_estados_tb is
   component maquina_estados is
      port(
         clk    : in std_logic;
         rst    : in std_logic;
         estado : out std_logic
      );
   end component;
   
   -- Sinais de teste
   signal clk_in : std_logic := '0';
   signal rst_in : std_logic := '0';
   signal estado_out : std_logic;
   
   -- Clock
   constant periodo : time := 10 ns;
   
begin
   -- Instancia a máquina de estados
   uut: maquina_estados port map(
      clk => clk_in,
      rst => rst_in,
      estado => estado_out
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
      -- Reset inicial
      rst_in <= '1';
      wait for periodo;
      assert estado_out = '0' report "Erro no reset" severity error;
      
      rst_in <= '0';
      wait for periodo;
      assert estado_out = '1' report "Erro na alternância de estado" severity error;
      
      wait for periodo;
      assert estado_out = '0' report "Erro na alternância de estado" severity error;
      
      wait for periodo;
      assert estado_out = '1' report "Erro na alternância de estado" severity error;
      
      -- Testa reset durante a operação
      rst_in <= '1';
      wait for periodo;
      assert estado_out = '0' report "Erro no reset durante operação" severity error;
      
      wait;
   end process;
end architecture;