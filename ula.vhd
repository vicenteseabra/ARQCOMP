library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula is
    port (
        entrada_A : in  unsigned(15 downto 0); -- Do Acumulador ou registrador
        entrada_B : in  unsigned(15 downto 0); -- Do Banco de Registradores ou imediato
        selec_op  : in  unsigned(1 downto 0);  -- "00": ADD, "01": SUB, "10": Passa B, "11": Passa A
        resultado : out unsigned(15 downto 0);
        flag_zero : out std_logic;
        flag_neg  : out std_logic;
        flag_carry: out std_logic
    );
end entity ula;

architecture a_ULA of ula is
    -- Sinal para o resultado principal de 16 bits
    signal s_resultado_temp : unsigned(15 downto 0);
    -- Sinal para o flag de carry/borrow
    signal s_carry_temp     : std_logic;

    -- Sinal interno para armazenar o resultado completo da operação (17 bits para incluir carry/borrow)
    -- Será do tipo unsigned, pois a lógica de carry/borrow é mais direta com unsigned.
    signal s_op_full_unsigned_result : unsigned(16 downto 0);

begin
    -- Processo combinacional para calcular a saída da ULA e os flags
    process(entrada_A, entrada_B, selec_op)
        -- Variável intermediária para operações que podem precisar de tratamento signed,
        -- embora aqui estejamos focando em resultados unsigned para s_op_full_unsigned_result.
        -- Se fossem necessárias operações signed complexas, seriam feitas aqui.
    begin
        case selec_op is
            when "00" => -- ADD: A + B
                -- Realiza a soma como unsigned, estendendo os operandos para 17 bits
                -- para capturar o carry out no bit 16.
                s_op_full_unsigned_result <= ('0' & entrada_A) + ('0' & entrada_B);
                s_resultado_temp          <= s_op_full_unsigned_result(15 downto 0);
                s_carry_temp              <= s_op_full_unsigned_result(16);

            when "01" => -- SUB: A - B
                -- Realiza a subtração como unsigned.
                s_op_full_unsigned_result <= ('0' & entrada_A) - ('0' & entrada_B);
                s_resultado_temp          <= s_op_full_unsigned_result(15 downto 0);
                -- O flag de Carry para subtração (A-B) é tipicamente NOT(Borrow).
                -- Um Borrow ocorre se B > A. Nesse caso, s_op_full_unsigned_result(16) será '1'.
                -- Portanto, Carry = NOT(s_op_full_unsigned_result(16)).
                s_carry_temp              <= not s_op_full_unsigned_result(16);

            when "10" => -- Passa B (entrada_B direto para o resultado)
                s_resultado_temp          <= entrada_B;
                s_op_full_unsigned_result <= '0' & entrada_B; -- Para consistência no cálculo de flags
                s_carry_temp              <= '0'; -- Não há carry/borrow nesta operação

            when "11" => -- Passa A (entrada_A direto para o resultado)
                s_resultado_temp          <= entrada_A;
                s_op_full_unsigned_result <= '0' & entrada_A; -- Para consistência no cálculo de flags
                s_carry_temp              <= '0'; -- Não há carry/borrow

            when others => -- Caso padrão, pode ser útil para depuração
                s_resultado_temp          <= (others => 'X');
                s_op_full_unsigned_result <= (others => 'X');
                s_carry_temp              <= 'X';
        end case;
    end process;

    -- Atribuição final às saídas da ULA
    resultado  <= s_resultado_temp;

    -- Cálculo dos flags Zero e Negativo baseado no resultado de 16 bits
    flag_zero  <= '1' when s_resultado_temp = X"0000" else '0';
    flag_neg   <= s_resultado_temp(15); -- MSB do resultado de 16 bits
    flag_carry <= s_carry_temp;

end architecture a_ULA;