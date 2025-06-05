library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity microprocessador_tb is
end entity microprocessador_tb;

architecture behavior of microprocessador_tb is
    -- Componente a ser testado (DUT - Device Under Test)
    component microprocessador is
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            debug_fsm_estado  : out unsigned(1 downto 0);
            debug_pc_addr     : out unsigned(6 downto 0);
            debug_ir_instr    : out unsigned(17 downto 0);
            debug_reg_bank_out: out unsigned(15 downto 0);
            debug_acc_out     : out unsigned(15 downto 0);
            debug_ula_out     : out unsigned(15 downto 0)
        );
    end component;

    -- Sinais de entrada para o DUT
    signal tb_clk : std_logic := '0';
    signal tb_rst : std_logic;

    -- Sinais de saída do DUT (para observação)
    signal tb_debug_fsm_estado  : unsigned(1 downto 0);
    signal tb_debug_pc_addr     : unsigned(6 downto 0);
    signal tb_debug_ir_instr    : unsigned(17 downto 0);
    signal tb_debug_reg_bank_out: unsigned(15 downto 0);
    signal tb_debug_acc_out     : unsigned(15 downto 0);
    signal tb_debug_ula_out     : unsigned(15 downto 0);

    -- Constante para o período do clock
    constant CLK_PERIOD : time := 10 ns; -- Clock de 100 MHz

begin
    -- Instanciação do DUT
    dut_inst: microprocessador
        port map (
            clk                => tb_clk,
            rst                => tb_rst,
            debug_fsm_estado   => tb_debug_fsm_estado,
            debug_pc_addr      => tb_debug_pc_addr,
            debug_ir_instr     => tb_debug_ir_instr,
            debug_reg_bank_out => tb_debug_reg_bank_out,
            debug_acc_out      => tb_debug_acc_out,
            debug_ula_out      => tb_debug_ula_out
        );

    -- Processo de geração de Clock
    clk_process: process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD / 2;
        tb_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_process;

    -- Processo de estímulo (Reset e simulação)
    stimulus_process: process
    begin
        -- Aplicar Reset inicial
        report "Iniciando Testbench: Aplicando Reset...";
        tb_rst <= '1';
        wait for CLK_PERIOD * 5; -- Manter o reset por 5 ciclos de clock

        tb_rst <= '0';
        report "Reset liberado. Iniciando execução do programa.";

        -- Deixar a simulação rodar por um tempo suficiente para observar
        -- o programa, incluindo o loop.
        -- O programa tem aproximadamente 9 instruções antes do primeiro JMP para 20,
        -- depois 1 instrução em 20, e um JMP de volta para o endereço 2.
        -- Cada instrução leva 3 ciclos de clock (Fetch, Decode, Execute).
        -- Para ver algumas iterações do loop:
        -- Loop principal: (inst 2, 3, 4, 5, 6, 7, 8, 9) = 8 instruções = 24 ciclos
        -- JMP para 20 (inst 9)
        -- Instrução em 20 (inst 20) = 3 ciclos
        -- JMP para 2 (inst 21) = 3 ciclos
        -- Total de uma iteração do loop grande: ~30 ciclos.
        -- Para algumas iterações e as instruções iniciais:
        wait for CLK_PERIOD * 200; -- Rodar por 200 ciclos (aprox. 60+ instruções)

        report "Simulação concluída. Verifique as formas de onda.";
        wait; -- Pausa a simulação indefinidamente
    end process stimulus_process;

end architecture behavior;