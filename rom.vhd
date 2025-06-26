-- rom.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port(
        clk      : in  std_logic;
        endereco : in  unsigned(6 downto 0);
        dado     : out unsigned(17 downto 0)
    );
end entity rom;

architecture a_rom of rom is
    type mem is array (0 to 127) of unsigned(17 downto 0);

    -- Opcodes e Registradores são omitidos por brevidade, mas continuam os mesmos.

    constant conteudo_rom : mem := (
        -- Seção 1: Loop de preenchimento da RAM (da sua 1ª solicitação)
        0  => "010000000000000000",  -- LD R0, 0
        1  => "011000000000000000",  -- SW (R0), ACC
        2  => "010010000000000001",  -- LD ACC, 1
        3  => "001000000000000000",  -- ADD R0
        4  => "010100000000000000",  -- MOV R0, ACC
        5  => "100100000000100001",  -- CMPI 33
        6  => "110100000000000100",  -- BNE 2

        -- Seção 2: Lógica Principal
        7  => "010000100000000011",  -- LD R2, 3
        8  => "010000100000000011",  -- LD R2, 3

        9  => "010000000000000001",  -- LD R0, 1

        -- Início do Loop Principal (Endereço 9)
        -- Bloco "Se R0 ja é R2"
        10  => "011100000000000000",  -- MOV ACC, R0
        11 => "100000000000000010",  -- CMP R2
        12 => "110100000000111000",  -- BNE 14 (Pula a próxima instrução)
        13 => "111100000001101101",  -- JMP 28 (Pula 14 linhas para o bloco de incremento de R2)

        -- Bloco "soma 1 no R0"
        14 => "010010000000000001",  -- LD ACC, 1
        15 => "001000000000000000",  -- ADD R0
        16 => "010100000000000000",  -- MOV R0, ACC

        -- Bloco "verifica se esta zerado o valor da ram"
        17 => "000100010000000000",  -- LW R1, (R0)
        18 => "011100000000000001",  -- MOV ACC, R1
        19 => "100000000000000000",  -- CMP R0
        20 => "111000000000101000",  -- BCC 10 (Volta 10 instruções)

        -- Bloco de cálculo e armazenamento
        21 => "011100000000000000",  -- MOV ACC, R0
        22 => "001000000000000001",  -- ADD R1
        23 => "010100000000000000",  -- MOV R0, ACC
        24 => "011000000000000000",  -- SW (R0), ACC (Interpretação de SW R3 (R0))

        -- Loop de verificação
        25 => "100100000000100000",  -- CMPI 32
        26 => "110100000001010000",  -- BNE 19 (Volta 6 instruções)

        -- Bloco de incremento de R2 (destino do JMP)
        27 => "010010000000000001",  -- LD ACC, 1
        28 => "001000000000000010",  -- ADD R2
        29 => "010100100000000000",  -- MOV R2, ACC

        -- Loop final
        30 => "100100000000001101",  -- CMPI 13
        31 => "110100000000110000",  -- BNE 12 (Volta 19 instruções)

        -- Preenche o resto com NOPs
        others => "000000000000000000"  -- NOP
    );
begin
    dado <= conteudo_rom(to_integer(endereco));
end architecture a_rom;