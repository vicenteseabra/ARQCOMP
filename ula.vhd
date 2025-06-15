library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula is
    port (
        entrada_A : in  unsigned(15 downto 0); -- Do Acumulador
        entrada_B : in  unsigned(15 downto 0); -- Do Banco de Registradores ou imediato
        selec_op  : in  unsigned(1 downto 0);  -- "00": ADD, "01": SUB, "10": Passa B, "11": Passa A
        resultado : out unsigned(15 downto 0);
        flag_zero : out std_logic;
        flag_carry: out std_logic
    );
end entity ula;

architecture a_ULA of ula is

    -- Sinal para o resultado principal de 17 bits
    signal ext_a,ext_b,s_res_sum,s_res_sub : unsigned(16 downto 0);

    --    signal resultAnd, resultXor: unsigned(15 downto 0);

    -- Sinal para o flag de carry/borrow
    signal s_carry_temp     : std_logic := '0';
    signal flag_zero_temp : std_logic := '0';

    -- Será do tipo unsigned, pois a lógica de carry/borrow é mais direta com unsigned.
    signal s_resultado_temp : unsigned(15 downto 0);

begin

    --===== CONCATENATING ====--
    ext_a <= '0' & entrada_A; -- Extensão de sinal para 17 bits
    ext_b <= '0' & entrada_B; -- Extensão de sinal para 17 bits

    --===== SUM OPERATION ====--
    s_res_sum <= ext_b + ext_a ; -- Soma de 17 bits

     --===== SUB OPERATION ====--
    s_res_sub <= ext_b - ext_a  ; -- Subtração de 17 bits

    s_resultado_temp <= s_res_sum(15 downto 0) when selec_op = "00" else  -- ADD
                        s_res_sub(15 downto 0) when selec_op = "01" else  -- SUB
                        entrada_B when selec_op = "10" else  -- Passa B
                        entrada_A when selec_op = "11"else -- Passa A (ou NOP ULA)
                        "0000000000000000";

    --===== CARRY FLAG ====--
    s_carry_temp <= s_res_sum(16) when selec_op = "00" else -- Carry na soma
                    s_res_sub(16) when selec_op = "01";

    -- Cálculo dos flag Zero baseado no resultado de 16 bits
    flag_zero_temp  <= '1' when (selec_op ="00" or selec_op="01") and (s_resultado_temp = "0000000000000000") else
                      '0' when (selec_op ="00" or selec_op="01") and (s_resultado_temp /= "0000000000000000");

    flag_zero <= flag_zero_temp;
    flag_carry <= s_carry_temp;

    resultado <= s_resultado_temp; -- Atribuição final do resultado
end architecture a_ULA;