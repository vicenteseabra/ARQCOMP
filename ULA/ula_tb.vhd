library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_tb is
end entity;

architecture a_ula_tb of ula_tb is
    component ula is
        port (
            entrada_A : in unsigned(15 downto 0);
            entrada_B : in unsigned(15 downto 0);
            selec_op  : in unsigned(1 downto 0);
            resultado : out unsigned(15 downto 0);
            flag_zero : out std_logic;
            flag_neg  : out std_logic
        );
    end component;

    -- Sinais para conectar ao componente
    signal entrada_A_tb, entrada_B_tb : unsigned(15 downto 0);
    signal selec_op_tb : unsigned(1 downto 0);
    signal resultado_tb : unsigned(15 downto 0);
    signal flag_zero_tb, flag_neg_tb : std_logic;

begin
    -- Instanciação do componente
    UUT: ula port map (
        entrada_A => entrada_A_tb,
        entrada_B => entrada_B_tb,
        selec_op => selec_op_tb,
        resultado => resultado_tb,
        flag_zero => flag_zero_tb,
        flag_neg => flag_neg_tb
    );

    -- Estímulos
    process
    begin
        -- Inicialização
        entrada_A_tb <= x"0000";
        entrada_B_tb <= x"0000";
        selec_op_tb <= "00";
        wait for 10 ns;

        -- Teste 1: Soma simples (3 + 5)
        entrada_A_tb <= x"0003";
        entrada_B_tb <= x"0005";
        selec_op_tb <= "00"; -- Operação de soma
        wait for 10 ns;


        -- Teste 2: Soma com números maiores (100 + 100)
        entrada_A_tb <= x"0064";
        entrada_B_tb <= x"0064";
        selec_op_tb <= "00"; -- Operação de soma
        wait for 10 ns;


        -- Teste 3: Soma resultando em negativo por overflow (32767 + 10)
        entrada_A_tb <= x"7FFF"; -- 32767 (máximo positivo em 16 bits)
        entrada_B_tb <= x"000A"; -- 10
        selec_op_tb <= "00"; -- Operação de soma
        wait for 10 ns;


        -- Teste 4: Subtração simples (10 - 3)
        entrada_A_tb <= x"000A"; -- 10
        entrada_B_tb <= x"0003"; -- 3
        selec_op_tb <= "01"; -- Operação de subtração
        wait for 10 ns;


        -- Teste 5: Subtração resultando em negativo (3 - 10)
        entrada_A_tb <= x"0003"; -- 3
        entrada_B_tb <= x"000A"; -- 10
        selec_op_tb <= "01"; -- Operação de subtração
        wait for 10 ns;


        -- Teste 6: Subtração resultando em zero (10 - 10)
        entrada_A_tb <= x"000A"; -- 10
        entrada_B_tb <= x"000A"; -- 10
        selec_op_tb <= "01"; -- Operação de subtração
        wait for 10 ns;


        -- Teste 7: Soma com números negativos (-3 + 5)
        entrada_A_tb <= x"FFFD"; -- -3 em complemento de 2
        entrada_B_tb <= x"0005"; -- 5
        selec_op_tb <= "00"; -- Operação de soma
        wait for 10 ns;


        -- Teste 8: Subtração com números negativos (-3 - 5)
        entrada_A_tb <= x"FFFD"; -- -3 em complemento de 2
        entrada_B_tb <= x"0005"; -- 5
        selec_op_tb <= "01"; -- Operação de subtração
        wait for 10 ns;


        -- Teste 9: Soma de dois negativos (-3 + -5)
        entrada_A_tb <= x"FFFD"; -- -3 em complemento de 2
        entrada_B_tb <= x"FFFB"; -- -5 em complemento de 2
        selec_op_tb <= "00"; -- Operação de soma
        wait for 10 ns;


        -- Teste 10: Operação não implementada (10)
        entrada_A_tb <= x"000A"; -- 10
        entrada_B_tb <= x"000B"; -- 11
        selec_op_tb <= "10"; -- Operação futura (não implementada)
        wait for 10 ns;

        wait;
    end process;
end architecture;