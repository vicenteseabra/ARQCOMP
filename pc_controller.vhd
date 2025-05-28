library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_controller is
   port(
      clk      : in std_logic;
      rst      : in std_logic;
      pc_out   : out unsigned(6 downto 0)
   );
end entity;

architecture a_pc_controller of pc_controller is
   component pc is
      port(
         clk      : in std_logic;
         rst      : in std_logic;
         wr_en    : in std_logic;
         data_in  : in unsigned(6 downto 0);
         data_out : out unsigned(6 downto 0)
      );
   end component;
   
   signal pc_data_in  : unsigned(6 downto 0) := "0000000";
   signal pc_data_out : unsigned(6 downto 0);
   signal pc_wr_en    : std_logic := '1'; -- Sempre habilitado para incrementar a cada ciclo
begin
   -- Instancia o PC
   pc_inst: pc port map(
      clk      => clk,
      rst      => rst,
      wr_en    => pc_wr_en,
      data_in  => pc_data_in,
      data_out => pc_data_out
   );
   
   -- Soma 1 à saída do PC e conecta de volta à entrada
   pc_data_in <= pc_data_out + 1;
   pc_out <= pc_data_out;
end architecture;