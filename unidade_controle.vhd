library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------
-- ENTITY da UNIDADE DE CONTROLE
--------------------------------------------------------------------
entity unidade_controle is
   port(
      clk        : in  std_logic;
      rst        : in  std_logic;

      -- monitoramento / depuração
      estado     : out std_logic;                          -- 0=FETCH, 1=DECODE
      pc_out     : out unsigned(6 downto 0);
      instr_out  : out unsigned(17 downto 0);

      ----------------------------------------------------------------
      -- sinais de controle para o banco de registradores e ACC+ULA
      ----------------------------------------------------------------

      -- escrita no banco de registradores
      bank_wr_en    : out std_logic;                       -- habilita escrita no banco
      reg_code_wr   : out unsigned(2 downto 0);            -- código de 3 bits de qual R escrever
      bank_data_in  : out unsigned(15 downto 0);           -- dado a entrar no banco

      -- leitura do banco de registradores (versão “reader”)
      reg_code_rd   : out unsigned(2 downto 0);            -- qual registrador ler (fonte)
      bank_read_data: in  unsigned(15 downto 0);           -- valor lido do banco (Rs)

      -- escrita no acumulador (recebe saída da ULA)
      acc_wr_en     : out std_logic;                       -- habilita escrita no ACC

      -- seleção de operação da ULA (00=ADD, 01=SUB, 10=OR/inócuo)
      alu_sel       : out unsigned(1 downto 0);

      ----------------------------------------------------------------
      -- saltos
      ----------------------------------------------------------------

      jump          : out std_logic;                       -- sinal “JMP”
      jump_addr     : out unsigned(6 downto 0)             -- endereço absoluto de destino
   );
end entity unidade_controle;

--------------------------------------------------------------------
-- ARCHITECTURE da UNIDADE DE CONTROLE
--------------------------------------------------------------------
architecture a_unidade_controle of unidade_controle is

   -----------------------------------------------------------------
   -- 1) Componentes internos (FSM, PC, ROM)
   -----------------------------------------------------------------
   component maquina_estados is
      port(
         clk    : in  std_logic;
         rst    : in  std_logic;
         estado : out std_logic
      );
   end component;

   component pc is
      port(
         clk      : in  std_logic;
         rst      : in  std_logic;
         wr_en    : in  std_logic;
         data_in  : in  unsigned(6 downto 0);
         data_out : out unsigned(6 downto 0)
      );
   end component;

   component rom is
      port(
         clk      : in  std_logic;
         endereco : in  unsigned(6 downto 0);
         dado     : out unsigned(17 downto 0)
      );
   end component;


   -----------------------------------------------------------------
   -- 2) Sinais internos
   -----------------------------------------------------------------

   -- FSM (0=FETCH, 1=DECODE)
   signal estado_s    : std_logic;

   -- PC interno
   signal pc_wr_en_s   : std_logic := '0';
   signal pc_data_in_s : unsigned(6 downto 0) := (others => '0');
   signal pc_data_out_s: unsigned(6 downto 0);

   --  Instrução buscada na ROM
   signal instr_s      : unsigned(17 downto 0);

   -- Campos extraídos da instrução
   signal opcode_s     : unsigned(3 downto 0);  -- instr_s(17 downto 14)
   signal dest5_s      : unsigned(4 downto 0);  -- instr_s(11 downto 7)
   signal src5_s       : unsigned(4 downto 0);  -- instr_s(6  downto 2)
   signal imm6_s       : unsigned(5 downto 0);  -- instr_s(5  downto 0)
   signal sign_im_s    : std_logic;             -- instr_s(6) (bit de sinal para LD)

   -- Extração do endereço absoluto para JMP (7 bits)
   signal abs_addr_s   : unsigned(6 downto 0);  -- instr_s(11 downto 5)

   --Detecta se JMP (opcode = "1111")
   signal jump_en_s    : std_logic;

   -----------------------------------------------------------------
   -- 3) Sinais de controle gerados na fase de DECODE (para atribuições concorrentes)
   -----------------------------------------------------------------
   signal bank_wr_en_i    : std_logic;
   signal reg_code_wr_i   : unsigned(2 downto 0);
   signal bank_data_in_i  : unsigned(15 downto 0);
   signal reg_code_rd_i   : unsigned(2 downto 0);
   signal acc_wr_en_i     : std_logic;
   signal alu_sel_i       : unsigned(1 downto 0);
   signal jump_i          : std_logic;
   signal jump_addr_i     : unsigned(6 downto 0);

begin

   -----------------------------------------------------------------
   -- 4) Instanciação da máquina de estados
   -----------------------------------------------------------------
   fsm_inst : maquina_estados
      port map(
         clk    => clk,
         rst    => rst,
         estado => estado_s
      );

   -----------------------------------------------------------------
   -- 5) Instanciação do PC
   -----------------------------------------------------------------
   pc_inst : pc
      port map(
         clk      => clk,
         rst      => rst,
         wr_en    => pc_wr_en_s,
         data_in  => pc_data_in_s,
         data_out => pc_data_out_s
      );

   -----------------------------------------------------------------
   -- 6) Instanciação da ROM
   -----------------------------------------------------------------
   rom_inst : rom
      port map(
         clk      => clk,
         endereco => pc_data_out_s,
         dado     => instr_s
      );

   -----------------------------------------------------------------
   -- 7) Extração de campos fixos da instrução
   -----------------------------------------------------------------
   opcode_s   <= instr_s(17 downto 14);
   dest5_s    <= instr_s(11 downto  7);
   src5_s     <= instr_s(6  downto  2);
   imm6_s     <= instr_s(5  downto  0);
   sign_im_s  <= instr_s(6);
   abs_addr_s <= instr_s(11 downto 5);

   -----------------------------------------------------------------
   -- 8) Detecta JMP (opcode = "1111")
   -----------------------------------------------------------------
   jump_en_s <= '1' when opcode_s = "1111" else '0';

   -----------------------------------------------------------------
   -- 9) Lógica do PC (sem processo, atribuições concorrentes)
   --     - estado_s = '0' (FETCH): pc_wr_en_s = '0'
   --     - estado_s = '1' (DECODE): pc_wr_en_s = '1'
   --       * se jump_en_s = '1', pc_data_in_s <= abs_addr_s
   --       * senão, pc_data_in_s <= pc_data_out_s + 1
   -----------------------------------------------------------------
   pc_wr_en_s   <= '1' when (estado_s = '1') else '0';

   pc_data_in_s <= abs_addr_s when (estado_s = '1' and jump_en_s = '1')
                 else (pc_data_out_s + 1) when (estado_s = '1' and jump_en_s = '0')
                 else (others => '0');  -- valor qualquer em FETCH

   -----------------------------------------------------------------
   -- 10) Saídas de monitoramento (FSM, PC, INSTR)
   -----------------------------------------------------------------
   estado    <= estado_s;
   pc_out    <= pc_data_out_s;
   instr_out <= instr_s;

   -----------------------------------------------------------------
   -- 11) Atribuições concorrentes para gerar sinais de controle
   -----------------------------------------------------------------

   -- reg_code_rd_i: passa src5_s(2 downto 0) em DECODE, senão “000”
   reg_code_rd_i <= src5_s(2 downto 0)
                  when (estado_s = '1')
                  else (others => '0');

   --  bank_wr_en_i: ativo em DECODE E opcode em {LD, MOV, ADD, SUB}
   bank_wr_en_i <= '1'
      when (estado_s = '1' and
            (opcode_s = "0100"    -- LD
           or opcode_s = "0001"    -- MOV
           or opcode_s = "0010"    -- ADD
           or opcode_s = "0011"))  -- SUB
      else '0';

   -- reg_code_wr_i: dest5_s(2 downto 0) em DECODE E opcode em {LD, MOV, ADD, SUB}
   reg_code_wr_i <= dest5_s(2 downto 0)
      when (estado_s = '1' and
            (opcode_s = "0100"    -- LD
           or opcode_s = "0001"    -- MOV
           or opcode_s = "0010"    -- ADD
           or opcode_s = "0011"))  -- SUB
      else (others => '0');

   --  bank_data_in_i:
   --       - se LD: zero‐extend imm6_s
   --       - se MOV: passa bank_read_data
   --       - senão: zeros
   bank_data_in_i <= ("0000000000" & imm6_s)
      when (estado_s = '1' and opcode_s = "0100")  -- LD
      else bank_read_data when (estado_s = '1' and opcode_s = "0001")  -- MOV
      else (others => '0');

   -- acc_wr_en_i: ativo em DECODE E opcode em {ADD, SUB}
   acc_wr_en_i <= '1'
      when (estado_s = '1' and
            (opcode_s = "0010"  -- ADD
           or opcode_s = "0011"))-- SUB
      else '0';

   -- alu_sel_i:
   -- "00" se ADD, "01" se SUB, "10" nos demais casos
   alu_sel_i <= "00"
      when (estado_s = '1' and opcode_s = "0010")  -- ADD
      else "01" when (estado_s = '1' and opcode_s = "0011")  -- SUB
      else "10";

   -- jump_i: '1' se DECODE E opcode = "1111" (JMP), senão '0'
   jump_i <= '1'
      when (estado_s = '1' and opcode_s = "1111")  -- JMP
      else '0';

   -- jump_addr_i: abs_addr_s em DECODE E opcode = "1111", senão zeros
   jump_addr_i <= abs_addr_s
      when (estado_s = '1' and opcode_s = "1111")  -- JMP
      else (others => '0');
   -----------------------------------------------------------------
   -- 12) Conexão dos sinais de controle internos para as portas de saída
   -----------------------------------------------------------------
   bank_wr_en    <= bank_wr_en_i;
   reg_code_wr   <= reg_code_wr_i;
   bank_data_in  <= bank_data_in_i;
   reg_code_rd   <= reg_code_rd_i;
   acc_wr_en     <= acc_wr_en_i;
   alu_sel       <= alu_sel_i;
   jump          <= jump_i;
   jump_addr     <= jump_addr_i;

end architecture a_unidade_controle;
