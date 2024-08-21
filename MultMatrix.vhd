library ieee;
use ieee.std_logic_1164.all;

entity MatrixMultiplier is
    port (
        matrixA00 : in std_logic_vector(31 downto 0); 
        matrixA01 : in std_logic_vector(31 downto 0);
        matrixA02 : in std_logic_vector(31 downto 0); 
        matrixA10 : in std_logic_vector(31 downto 0);
        matrixA11 : in std_logic_vector(31 downto 0); 
        matrixA12 : in std_logic_vector(31 downto 0);
        matrixA20 : in std_logic_vector(31 downto 0);
        matrixA21 : in std_logic_vector(31 downto 0); 
        matrixA22 : in std_logic_vector(31 downto 0);
        matrixB00 : in std_logic_vector(31 downto 0); 
        matrixB01 : in std_logic_vector(31 downto 0);
        matrixB02 : in std_logic_vector(31 downto 0); 
        matrixB10 : in std_logic_vector(31 downto 0);
        matrixB11 : in std_logic_vector(31 downto 0); 
        matrixB12 : in std_logic_vector(31 downto 0);
        matrixB20 : in std_logic_vector(31 downto 0);
        matrixB21 : in std_logic_vector(31 downto 0); 
        matrixB22 : in std_logic_vector(31 downto 0);
        matrixRes00 : out std_logic_vector(31 downto 0); 
        matrixRes01 : out std_logic_vector(31 downto 0);
        matrixRes02 : out std_logic_vector(31 downto 0); 
        matrixRes10 : out std_logic_vector(31 downto 0);
        matrixRes11 : out std_logic_vector(31 downto 0); 
        matrixRes12 : out std_logic_vector(31 downto 0);
        matrixRes20 : out std_logic_vector(31 downto 0);
        matrixRes21 : out std_logic_vector(31 downto 0); 
        matrixRes22 : out std_logic_vector(31 downto 0)
    );
end entity MatrixMultiplier;

architecture Behavioral of MatrixMultiplier is
    signal args1, args2, resultMult  : std_logic_vector(31 downto 0);
    
    component MultVector 
    port (matrixA0,matrixA1,matrixA2,matrixB0,matrixB1,matrixB2: in std_logic_vector; matrixRes : out std_logic_vector);
    end component;
    
    
    
    begin
    Mult1 : MultVector port map (matrixA00,matrixA01,matrixA02,matrixB00,matrixB10,matrixB20,matrixRes00);
    Mult2 : MultVector port map (matrixA10,matrixA11,matrixA12,matrixB00,matrixB10,matrixB20,matrixRes10);
    Mult3 : MultVector port map (matrixA20,matrixA21,matrixA22,matrixB00,matrixB10,matrixB20,matrixRes20);
    Mult4 : MultVector port map (matrixA00,matrixA01,matrixA02,matrixB01,matrixB11,matrixB21,matrixRes01);
    Mult5 : MultVector port map (matrixA10,matrixA11,matrixA12,matrixB01,matrixB11,matrixB21,matrixRes11);
    Mult6 : MultVector port map (matrixA20,matrixA21,matrixA22,matrixB01,matrixB11,matrixB21,matrixRes21);
    Mult7 : MultVector port map (matrixA00,matrixA01,matrixA02,matrixB02,matrixB12,matrixB22,matrixRes02);
    Mult8 : MultVector port map (matrixA10,matrixA11,matrixA12,matrixB02,matrixB12,matrixB22,matrixRes12);
    Mult9 : MultVector port map (matrixA20,matrixA21,matrixA22,matrixB02,matrixB12,matrixB22,matrixRes22);
 
        
end architecture Behavioral;
