library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MultVector is
 Port (matrixA0 : in std_logic_vector(31 downto 0); 
        matrixA1 : in std_logic_vector(31 downto 0);
        matrixA2 : in std_logic_vector(31 downto 0); 
        matrixB0 : in std_logic_vector(31 downto 0);
        matrixB1 : in std_logic_vector(31 downto 0); 
        matrixB2 : in std_logic_vector(31 downto 0);
        matrixRes : out std_logic_vector(31 downto 0));
end MultVector;

architecture Behavioral of MultVector is
    signal res1,res2,res3,resint : std_logic_vector(31 downto 0);
    
    component FloatMultiplier
    port (floatInputA, floatInputB : in std_logic_vector;
    result :  out std_logic_vector);
    end component;
    
    component FloatADD
    port (floatInputA, floatInputB : in std_logic_vector;
    result :  out std_logic_vector);
    end component;
    
begin
    MULT1: floatMultiplier port map(matrixA0, matrixB0, res1);
    MULT2: floatMultiplier port map(matrixA1, matrixB1, res2);
    MULT3: floatMultiplier port map(matrixA2, matrixB2, res3);
    
    ADD1: FloatADD port map(res1, res2, resint);
    ADD2: FloatADD port map(resint, res3, matrixRes);


end Behavioral;
