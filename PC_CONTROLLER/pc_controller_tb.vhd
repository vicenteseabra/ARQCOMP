library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_controller_tb is
end entity;

architecture a_pc_controller_tb of pc_controller_tb is
   component pc_controller is
      port(
         clk      : in std_logic;
         rst      : in std_logic;
         pc_out   : out unsigned(6 downto 0)
      );
   end component;
   
   -- Sinais de teste
   signal clk_in : std_logic := '0';
   signal rst_in : std_logic := '0';
   signal pc_out : unsigned(6 downto 0);
   
   -- Clock
   constant periodo : time := 10 ns;
   
begin
   -- Instancia o PC controller
   uut: pc_controller port map(
      clk    => clk_in,
      rst    => rst_in,
      pc_out => pc_out
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
      assert pc_out = "0000000" report "Erro no reset do PC" severity error;
      
      -- Remove o reset e verifica contagem
      rst_in <= '0';
      wait for periodo;
      assert pc_out = "0000001" report "Erro na contagem do PC" severity error;
      
      wait for periodo;
      assert pc_out = "0000010" report "Erro na contagem do PC" severity error;
      
      wait for periodo;
      assert pc_out = "0000011" report "Erro na contagem do PC" severity error;
      
      -- Aplica reset novamente
      rst_in <= '1';
      wait for periodo;
      assert pc_out = "0000000" report "Erro no reset durante contagem" severity error;
      
      wait;
   end process;
end architecture;