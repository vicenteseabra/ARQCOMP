library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula is
    port (
        entrada_A : in unsigned(15 downto 0);
        entrada_B : in unsigned(15 downto 0);
        selec_op : in unsigned(1 downto 0);
        resultado : out unsigned(15 downto 0);
        flag_zero : out std_logic;
        flag_neg : out std_logic;
        flag_carry : out std_logic
    );
end entity ula;

architecture a_ULA of ula is
    signal resultado_temp : unsigned(15 downto 0) := (others => '0');
    signal carry_temp : std_logic := '0';
    signal soma_temp : unsigned(16 downto 0);  -- Um bit extra para o carry
begin
    -- Cálculo da operação com possível carry
    soma_temp <= ('0' & entrada_A) + ('0' & entrada_B) when selec_op = "00" else
                 ('0' & entrada_A) - ('0' & entrada_B) when selec_op = "01" else
                 ('0' & (entrada_A or entrada_B)) when selec_op = "10" else  -- Operação OR
                 (others => '0');

    -- Atribuição do resultado
    resultado_temp <= soma_temp(15 downto 0);

    -- Flag de carry (bit 16 da soma/subtração)
    carry_temp <= soma_temp(16) when selec_op = "00" else  -- Carry para soma
                  not soma_temp(16) when selec_op = "01" else  -- Carry para subtração (invertido)
                  '0';  -- Outras operações não geram carry

    -- Sinais de saída
    resultado <= resultado_temp;
    flag_zero <= '1' when resultado_temp = "000000000000000" else '0';
    flag_neg <= resultado_temp(15);
    flag_carry <= carry_temp;
end architecture a_ULA;