library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_tb is
end entity;

architecture a_rom_tb of rom_tb is
   component rom is
      port(
         clk      : in std_logic;
         endereco : in unsigned(6 downto 0);
         dado     : out unsigned(17 downto 0)
      );
   end component;
   
   -- Sinais de teste
   signal clk_in : std_logic := '0';
   signal endereco_in : unsigned(6 downto 0) := "0000000";
   signal dado_out : unsigned(17 downto 0);
   
   -- Clock
   constant periodo : time := 10 ns;
   
begin
   -- Instancia a ROM
   uut: rom port map(
      clk => clk_in,
      endereco => endereco_in,
      dado => dado_out
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
      -- Testa alguns endereços
      wait for periodo; -- Aguarda primeiro ciclo completo
      
      endereco_in <= "0000000"; -- Endereço 0 (NOP)
      wait for periodo;
      assert dado_out = "000000000000000000" report "Erro na leitura do endereço 0" severity error;
      
      endereco_in <= "0000010"; -- Endereço 2 (JUMP para 5)
      wait for periodo;
      assert dado_out = "111100000000000101" report "Erro na leitura do endereço 2" severity error;
      
      endereco_in <= "0000101"; -- Endereço 5 (NOP)
      wait for periodo;
      assert dado_out = "000000000000000000" report "Erro na leitura do endereço 5" severity error;
      
      wait;
   end process;
end architecture;