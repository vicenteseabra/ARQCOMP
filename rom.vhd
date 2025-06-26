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
        -- Seção 1: Loop de preenchimento da RAM
        0  => "0100"&"0"&"000"&"0000000000",  -- LD R0, 0
        1  => "0110"&"00000000000"&"000",  -- SW (R0), ACC
        2  => "0100"&"1"&"000"&"0000000001",  -- LD ACC, 1
        3  => "0010"&"00000000000"&"000",  -- ADD R0
        4  => "0101"&"0"&"000"&"0000000000",  -- MOV R0, ACC
        5  => "1001"&"0000"&"0000100001",  -- CMPI 33
        6  => "1101"&"00"&"0000000001"&"00",  -- BNE 2
        7  =>  "000000000000000000",  -- NOP

        -- Seção 2: Eliminação dos múltiplos de 2 (endereços 8-17)
        8  => "0100"&"0"&"000"&"0000000010",  -- LD R0, 2           ; R0 = 2 (primeiro primo)
        9  => "0100"&"0"&"001"&"0000000000",  -- LD R1, 0           ; R1 = 0 (múltiplo atual)
        10 => "0100"&"1"&"000"&"0000000010",  -- LD ACC, 2          ; ACC = 0 [INSTRUÇÃO INSERIDA]
        11 => "0010"&"00000000000"&"000",  -- ADD R0             ; ACC += R0 (ACC = R0)
        12 => "0101"&"0"&"001"&"0000000000",  -- MOV R1, ACC        ; R1 = ACC (R1 = múltiplo atual)
        13 => "0100"&"1"&"000"&"0000000000",  -- LD ACC, 0          ; ACC = 0
        14 => "0110"&"00000000000"&"001",  -- SW (R1), ACC       ; mem[R1] = 0 (marca como não primo)
        15 => "0100"&"1"&"000"&"0000000010",  -- LD ACC, 2 
        16 => "0010"&"00000000000"&"001",  -- ADD R1             ; ACC += R1
        17 => "1001"&"0000"&"0000100001",  -- CMPI 33            ; Compara ACC com 33
        18 => "1101"&"01"&"0000001100"&"00",  -- BNE 12             ; Se ACC < 33, volta para endereço 13

        -- Preenche o resto com NOPs
        others => "000000000000000000"  -- NOP
    );
begin
    dado <= conteudo_rom(to_integer(endereco));
end architecture a_rom;