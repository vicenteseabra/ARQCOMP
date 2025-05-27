library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unidade_controle is
   port(
      clk       : in std_logic;
      rst       : in std_logic;
      estado    : out std_logic;
      pc_out    : out unsigned(6 downto 0);
      instr_out : out unsigned(17 downto 0)
   );
end entity;

architecture a_unidade_controle of unidade_controle is
   component maquina_estados is
      port(
         clk    : in std_logic;
         rst    : in std_logic;
         estado : out std_logic
      );
   end component;
   
   component pc is
      port(
         clk      : in std_logic;
         rst      : in std_logic;
         wr_en    : in std_logic;
         data_in  : in unsigned(6 downto 0);
         data_out : out unsigned(6 downto 0)
      );
   end component;
   
   component rom is
      port(
         clk      : in std_logic;
         endereco : in unsigned(6 downto 0);
         dado     : out unsigned(17 downto 0)
      );
   end component;
   
   -- Sinais internos
   signal estado_s   : std_logic;
   signal pc_wr_en   : std_logic := '0';
   signal pc_data_in : unsigned(6 downto 0) := "0000000";
   signal pc_data_out : unsigned(6 downto 0);
   signal instr      : unsigned(17 downto 0);
   signal opcode     : unsigned(3 downto 0);
   signal jump_en    : std_logic;
   signal jump_addr  : unsigned(6 downto 0);
   
begin
   -- Instancia a máquina de estados
   fsm: maquina_estados port map(
      clk    => clk,
      rst    => rst,
      estado => estado_s
   );
   
   -- Instancia o PC
   pc_inst: pc port map(
      clk      => clk,
      rst      => rst,
      wr_en    => pc_wr_en,
      data_in  => pc_data_in,
      data_out => pc_data_out
   );
   
   -- Instancia a ROM
   rom_inst: rom port map(
      clk      => clk,
      endereco => pc_data_out,
      dado     => instr
   );
   
   -- Extrai o opcode (4 bits mais significativos)
   opcode <= instr(17 downto 14);
   
   -- Decodifica o opcode
   jump_en <= '1' when opcode = "1111" else '0';
   
   -- Extrai o endereço de destino do jump
   jump_addr <= instr(6 downto 0);
   
   -- Lógica de controle baseada no estado
   -- Estado 0 (fetch): apenas lê a instrução
   -- Estado 1 (decode/execute): atualiza o PC baseado na instrução
   pc_wr_en <= '1' when estado_s = '1' else '0';
   
   -- Lógica para o próximo endereço do PC
   pc_data_in <= jump_addr when (estado_s = '1' and jump_en = '1') else
                 pc_data_out + 1;
   
   -- Saídas
   estado <= estado_s;
   pc_out <= pc_data_out;
   instr_out <= instr;
end architecture;