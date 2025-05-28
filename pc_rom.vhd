library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_rom is
   port(
      clk       : in std_logic;
      rst       : in std_logic;
      rom_data  : out unsigned(17 downto 0);
      pc_addr   : out unsigned(6 downto 0)
   );
end entity;

architecture a_pc_rom of pc_rom is
   component pc_controller is
      port(
         clk      : in std_logic;
         rst      : in std_logic;
         pc_out   : out unsigned(6 downto 0)
      );
   end component;
   
   component rom is
      port(
         clk      : in std_logic;
         endereco : in unsigned(6 downto 0);
         dado     : out unsigned(17 downto 0)
      );
   end component;
   
   signal pc_out_s : unsigned(6 downto 0);
   
begin
   -- Instancia o PC controller
   pc_ctrl: pc_controller port map(
      clk    => clk,
      rst    => rst,
      pc_out => pc_out_s
   );
   
   -- Instancia a ROM
   rom_inst: rom port map(
      clk      => clk,
      endereco => pc_out_s,
      dado     => rom_data
   );
   
   pc_addr <= pc_out_s;
end architecture;