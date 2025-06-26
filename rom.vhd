
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

    -- Opcodes
    constant NOP_OP        : unsigned(3 downto 0) := "0000";
    constant LW_OP         : unsigned(3 downto 0) := "0001"; -- Load Word: Rd <= Mem[Rs]
    constant ADD_ACC_OP    : unsigned(3 downto 0) := "0010";
    constant SUB_ACC_OP    : unsigned(3 downto 0) := "0011";
    constant LD_OP         : unsigned(3 downto 0) := "0100";
    constant MOV_RD_ACC_OP : unsigned(3 downto 0) := "0101";
    constant SW_OP         : unsigned(3 downto 0) := "0110"; -- Store Word: Mem[Rs] <= ACC
    constant MOV_ACC_RS_OP : unsigned(3 downto 0) := "0111";
    constant CMP_OP        : unsigned(3 downto 0) := "1000"; -- Compare Rs with ACC
    constant CMPI_OP       : unsigned(3 downto 0) := "1001"; -- Compare Imm with ACC
    constant BNE_OP        : unsigned(3 downto 0) := "1101"; -- Branch if Not Equal
    constant BCS_OP        : unsigned(3 downto 0) := "1110"; -- Branch if Carry Set
    constant JMP_OP        : unsigned(3 downto 0) := "1111";

    -- Registradores
    constant R0 : unsigned(2 downto 0) := "000";
    constant R1 : unsigned(2 downto 0) := "001";
    constant R2 : unsigned(2 downto 0) := "010";
    constant R3 : unsigned(2 downto 0) := "011";
    constant R4 : unsigned(2 downto 0) := "100";
    constant R5 : unsigned(2 downto 0) := "101";

    constant conteudo_rom : mem := (
        -- Seção 1: Loop de preenchimento da RAM (endereços 0-7)
        0  => "0100"&"0"&"000"&"0000000000",  -- LD R0, 0
        1  => "0110"&"00000000000"&"000",     -- SW (R0), ACC
        2  => "0100"&"1"&"000"&"0000000001",  -- LD ACC, 1
        3  => "0010"&"00000000000"&"000",     -- ADD R0
        4  => "0101"&"0"&"000"&"0000000000",  -- MOV R0, ACC
        5  => "1001"&"0000"&"0000100001",     -- CMPI 33
        6  => "1101"&"00"&"0000000001"&"00",  -- BNE 1
        7  => "000000000000000000",            -- NOP

        -- Seção 2: Crivo de Eratóstenes com loop automático
        -- R2 = primo atual (começa com 2)
        -- R3 = limite para primos (13)
        -- R1 = múltiplo atual
        -- R4 = limite geral (33)
        -- R5 = primo atual (para visualização)
        
        -- Inicialização
        8  => "0100"&"0"&"010"&"0000000010",  -- LD R2, 2           ; R2 = 2 (primeiro primo)
        9  => "0100"&"0"&"011"&"0000001110",  -- LD R3, 14          ; R3 = 14 (limite para primos)
        10 => "0100"&"0"&"100"&"0000100001",  -- LD R4, 33          ; R4 = 33 (limite geral)

        -- Loop principal: procura próximo primo não marcado
        11 => "0001"&"0"&"000"&"0000000"&"010", -- LW R0, (R2)        ; R0 = mem[R2]
        12 => "0111"&"00000000000"&"000",     -- MOV ACC, R0        ; ACC = R0
        13 => "1001"&"0000"&"0000000000",     -- CMPI 0             ; ACC == 0?
        14 => "1101"&"00"&"0000010110"&"00",  -- BNE 22             ; Se mem[R2] != 0, encontrou primo não marcado

        -- Primo foi marcado, avança para próximo candidato
        15 => "0100"&"1"&"000"&"0000000001",  -- LD ACC, 1
        16 => "0010"&"00000000000"&"010",     -- ADD R2             ; ACC = R2 + 1
        17 => "0101"&"0"&"010"&"0000000000",  -- MOV R2, ACC        ; R2++

        -- Verifica se já passou do limite de primos
        18 => "0111"&"00000000000"&"010",     -- MOV ACC, R2        ; ACC = R2
        19 => "1000"&"00000000000"&"011",     -- CMP R3             ; Compara R2 com R3 (13)
        20 => "1110"&"01"&"0000100010"&"00",  -- BCS 34             ; Se R2 > 13, termina
        21 => "1111"&"00"&"0000001011"&"00",  -- JMP 11             ; Volta para testar próximo primo

        -- Se chegou aqui, R2 é um primo não marcado
        22 => "0111"&"00000000000"&"010",     -- MOV ACC, R2        ; ACC = R2 (primo atual)
        23 => "0101"&"0"&"101"&"0000000000",  -- MOV R5, ACC        ; R5 = primo atual (PARA VISUALIZAÇÃO!)

        -- Encontrou primo não marcado, elimina seus múltiplos
        24 => "0111"&"00000000000"&"010",     -- MOV ACC, R2        ; ACC = R2 (primo atual)
        25 => "0010"&"00000000000"&"010",     -- ADD R2             ; ACC = R2 + R2 (primeiro múltiplo)
        26 => "0101"&"0"&"001"&"0000000000",  -- MOV R1, ACC        ; R1 = primeiro múltiplo

        -- Loop interno: marca múltiplos
        27 => "0111"&"00000000000"&"001",     -- MOV ACC, R1        ; ACC = R1
        28 => "1000"&"00000000000"&"100",     -- CMP R4             ; Compara R1 com 33
        29 => "1110"&"01"&"0000001111"&"00",  -- BCS 15             ; Se R1 >= 33, vai para próximo primo

        30 => "0100"&"1"&"000"&"0000000000",  -- LD ACC, 0          ; ACC = 0
        31 => "0110"&"00000000000"&"001",     -- SW (R1), ACC       ; mem[R1] = 0 (marca como não primo)

        32 => "0111"&"00000000000"&"001",     -- MOV ACC, R1        ; ACC = R1
        33 => "0010"&"00000000000"&"010",     -- ADD R2             ; ACC = R1 + R2 (próximo múltiplo)
        34 => "0101"&"0"&"001"&"0000000000",  -- MOV R1, ACC        ; R1 = próximo múltiplo
        35 => "1111"&"00"&"0000011011"&"00",  -- JMP 27             ; Volta para marcar próximo múltiplo

        -- Preenche o resto com NOPs
        others => "000000000000000000"  -- NOP
    );
begin
    dado <= conteudo_rom(to_integer(endereco));
end architecture a_rom;
