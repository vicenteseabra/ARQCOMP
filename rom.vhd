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

    -- Opcodes (simplificado para este exemplo)
    constant NOP_OP     : unsigned(3 downto 0) := "0000";
    constant LW_OP      : unsigned(3 downto 0) := "0001"; -- Load Word
    constant SW_OP      : unsigned(3 downto 0) := "0110"; -- Store Word (mesmo opcode do LW, mas com diferente controle na UC)
    constant ADD_ACC_OP : unsigned(3 downto 0) := "0010"; -- ACC <= ACC + Rs
    constant SUB_ACC_OP : unsigned(3 downto 0) := "0011"; -- ACC <= ACC - Rs
    constant LD_OP      : unsigned(3 downto 0) := "0100"; -- Rd <= Imm
    constant MOV_ACC_RS_OP: unsigned(3 downto 0) := "0111"; -- ACC <= Rs
    constant MOV_RD_ACC_OP: unsigned(3 downto 0) := "0101"; -- Rd <= ACC
    constant CMP_OP     : unsigned(3 downto 0) := "1000"; -- Comparação
    constant CMPI_OP    : unsigned(3 downto 0) := "1001"; -- Comparação Imediato
    constant BNE_OP     : unsigned(3 downto 0) := "1101"; -- BNE (Branch if Not Equal)
    constant BCS_OP     : unsigned(3 downto 0) := "1110"; -- BCS (Branch if Carry Set)
    constant JMP_OP     : unsigned(3 downto 0) := "1111"; -- JMP

    constant conteudo_rom : mem := (


    
        0 => LD_OP & "10010000000011", -- LD ACC, 3
        1 => SW_OP & "00000000000001", -- SW MEM1, ACC
        2 => LW_OP & "00010000000001", -- LW R1, 0
        others => NOP_OP & "00000000000000" -- NOP para o resto
    );
begin
    dado <= conteudo_rom(to_integer(endereco));
end architecture a_rom;