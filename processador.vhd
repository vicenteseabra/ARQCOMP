library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------
-- ENTITY do PROCESSADOR (top‐level)
--------------------------------------------------------------------
entity processador is
   port(
      clk           : in  std_logic;
      rst           : in  std_logic;

      ----------------------------------------------------------------
      -- (Opcional) Sinais de monitoramento / depuração
      ----------------------------------------------------------------
      estado_fsm    : out std_logic;                 -- 0=FETCH, 1=DECODE
      pc_atual      : out unsigned(6 downto 0);      -- valor corrente do PC
      instr_atual   : out unsigned(17 downto 0);     -- instrução lida da ROM

      -- Flags da ULA (apenas para observar; não usadas internamente)
      flag_zero     : out std_logic;
      flag_neg      : out std_logic;
      flag_carry    : out std_logic
   );
end entity processador;


--------------------------------------------------------------------
-- ARCHITECTURE do PROCESSADOR
--------------------------------------------------------------------
architecture a_processador of processador is

   -----------------------------------------------------------------
   -- 1) Sinais de interconexão entre UC e Datapath
   -----------------------------------------------------------------
   signal sig_estado_fsm   : std_logic;
   signal sig_pc_atual     : unsigned(6 downto 0);
   signal sig_instr_atual  : unsigned(17 downto 0);

   signal sig_bank_wr_en   : std_logic;
   signal sig_reg_code_wr  : unsigned(2 downto 0);
   signal sig_bank_data_in : unsigned(15 downto 0);

   signal sig_reg_code_rd  : unsigned(2 downto 0);
   signal sig_bank_read    : unsigned(15 downto 0);

   signal sig_acc_wr_en    : std_logic;
   signal sig_alu_sel      : unsigned(1 downto 0);

   signal sig_jump         : std_logic;
   signal sig_jump_addr    : unsigned(6 downto 0);

   -----------------------------------------------------------------
   -- 2) Sinais internos da ULA e ACC
   -----------------------------------------------------------------
   signal sig_acc_out      : unsigned(15 downto 0);
   signal sig_ula_result   : unsigned(15 downto 0);
   signal sig_flag_zero    : std_logic;
   signal sig_flag_neg     : std_logic;
   signal sig_flag_carry   : std_logic;

begin

   -----------------------------------------------------------------
   -- 3) Instanciação da Unidade de Controle (UC)
   -----------------------------------------------------------------
   uc_inst : entity work.unidade_controle
      port map(
         clk            => clk,
         rst            => rst,

         estado         => sig_estado_fsm,
         pc_out         => sig_pc_atual,
         instr_out      => sig_instr_atual,

         bank_wr_en     => sig_bank_wr_en,
         reg_code_wr    => sig_reg_code_wr,
         bank_data_in   => sig_bank_data_in,

         reg_code_rd    => sig_reg_code_rd,
         bank_read_data => sig_bank_read,

         acc_wr_en      => sig_acc_wr_en,
         alu_sel        => sig_alu_sel,

         jump           => sig_jump,
         jump_addr      => sig_jump_addr
      );

   -----------------------------------------------------------------
   -- 4) Banco de Registradores “writer”
   --    (para LD, MOV, ADD, SUB)
   -----------------------------------------------------------------
   bank_writer : entity work.register_bank
      port map(
         data_in   => sig_bank_data_in,
         clk       => clk,
         wr_en     => sig_bank_wr_en,
         reg_code  => sig_reg_code_wr,
         rst       => rst,
         data_out  => open
      );

   -----------------------------------------------------------------
   -- 5) Banco de Registradores “reader”
   --    (sempre wr_en = '0', para fornecer “bank_read_data”)
   -----------------------------------------------------------------
   bank_reader : entity work.register_bank
      port map(
         data_in   => (others => '0'),
         clk       => clk,
         wr_en     => '0',
         reg_code  => sig_reg_code_rd,
         rst       => rst,
         data_out  => sig_bank_read
      );

   -----------------------------------------------------------------
   -- 6) Instanciação do Acumulador
   -----------------------------------------------------------------
   acc_inst : entity work.accumulator
      port map(
         clk      => clk,
         rst      => rst,
         wr_en    => sig_acc_wr_en,
         data_in  => sig_ula_result,
         data_out => sig_acc_out
      );

   -----------------------------------------------------------------
   -- 7) Instanciação da ULA
   -----------------------------------------------------------------
   ula_inst : entity work.ula
      port map(
         entrada_A   => sig_acc_out,
         entrada_B   => sig_bank_read,
         selec_op    => sig_alu_sel,
         resultado   => sig_ula_result,
         flag_zero   => sig_flag_zero,
         flag_neg    => sig_flag_neg,
         flag_carry  => sig_flag_carry
      );

   -----------------------------------------------------------------
   -- 8) Saídas de monitoramento
   -----------------------------------------------------------------
   estado_fsm   <= sig_estado_fsm;
   pc_atual     <= sig_pc_atual;
   instr_atual  <= sig_instr_atual;

   flag_zero    <= sig_flag_zero;
   flag_neg     <= sig_flag_neg;
   flag_carry   <= sig_flag_carry;

end architecture a_processador;
