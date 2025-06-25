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

    constant conteudo_rom : mem := (        -- LD R0, 1
        -- LD R5, 33
        -- MOV ACC, R0
        -- SW (R0), ACC
        -- LD ACC, 1
        -- ADD ACC, R0
        -- MOV R0, ACC
        -- MOV ACC, R0
        -- CMP R5
        -- BNE 3

        0  => "010000000000000001",  -- LD R0, 1       (0100 0000 0000 0000 01)

        1  => "011100000000000000",  -- MOV ACC, R0    (0111 0000 0000 0000 00)
        2  => "011000000000000000",  -- SW (R0), ACC   (0110 0000 0000 0000 00)
        3  => "010010000000000001",  -- LD ACC, 1      (0100 1000 0000 0000 01)
        4  => "001000000000000000",  -- ADD ACC, R0    (0010 0000 0000 0000 00)
        5  => "010100000000000000",  -- MOV R0, ACC    (0101 0000 0000 0000 00)
        6  => "011100000000000000",  -- MOV ACC, R0    (0111 0000 0000 0000 00)
        7  => "100100000000100001",  -- CMPi 33        (1000 0000 0000 0001 01)
        8  => "110101000000001000",  -- BNE 3          (1101 0100 0000 0011 00)

        -- Preenche o resto com NOPs
        others => "000000000000000000"  -- NOP
        );
begin
    dado <= conteudo_rom(to_integer(endereco));
end architecture a_rom;
