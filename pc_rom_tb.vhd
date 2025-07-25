library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_rom_tb is
end entity;

architecture a_pc_rom_tb of pc_rom_tb is
   component pc_rom is
      port(
         clk       : in std_logic;
         rst       : in std_logic;
         rom_data  : out unsigned(17 downto 0);
         pc_addr   : out unsigned(6 downto 0)
      );
   end component;

   -- Sinais de teste
   signal clk_in    : std_logic := '0';
   signal rst_in    : std_logic := '0';
   signal rom_data  : unsigned(17 downto 0);
   signal pc_addr   : unsigned(6 downto 0);

   -- Clock
   constant periodo : time := 10 ns;

begin
   -- Instancia o PC com ROM
   uut: pc_rom port map(
      clk      => clk_in,
      rst      => rst_in,
      rom_data => rom_data,
      pc_addr  => pc_addr
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

      -- Remove o reset e verifica contagem e dados da ROM
      rst_in <= '0';
      wait for periodo;

      -- Continua observando por alguns ciclos
      wait for 8 * periodo;

      -- Aplica reset novamente
      rst_in <= '1';
      wait for periodo;

      wait;
   end process;
end architecture;