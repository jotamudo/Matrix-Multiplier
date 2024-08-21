library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FloatMultiplier is
    generic (
        EXPONENT_WIDTH : integer := 8;  -- Largeur de l'exposant en virgule flottante (IEEE 754 simple précision)
        MANTISSA_WIDTH : integer := 23  -- Largeur de la mantisse en virgule flottante (IEEE 754 simple précision)
    );
    port (
        floatInputA : in std_logic_vector(EXPONENT_WIDTH + MANTISSA_WIDTH downto 0);  -- Entrée : nombre Ã  virgule flottante A
        floatInputB : in std_logic_vector(EXPONENT_WIDTH + MANTISSA_WIDTH downto 0);  -- Entrée : nombre Ã  virgule flottante B
        result : out std_logic_vector(EXPONENT_WIDTH + MANTISSA_WIDTH downto 0)  -- Sortie : résultat de la multiplication en virgule flottante
    );
end entity FloatMultiplier;

architecture Behavioral of FloatMultiplier is
   
    
begin
    process(floatInputA,floatInputA)
    variable mantissaA, mantissaB : unsigned(MANTISSA_WIDTH downto 0);
    variable mantissaResult : unsigned(MANTISSA_WIDTH-1 downto 0);
    variable product : unsigned((MANTISSA_WIDTH*2 + 1) downto 0);  -- Largeur suffisamment grande pour contenir le résultat de la multiplication
    variable signA, signB, signResult : std_logic;
    variable exponentA, exponentB, exponentResult : integer;
        begin
        -- cas particuliers
        if floatInputA(30 downto 0) ="0000000000000000000000000000000"  then
            result <=floatInputA;
        elsif  floatInputB(30 downto 0) ="0000000000000000000000000000000" then
            result <=floatInputB;
        else
        
            -- Extraire les composants du nombre  virgule flottante 
            signA := floatInputA(EXPONENT_WIDTH + MANTISSA_WIDTH);
            exponentA := to_integer(unsigned(floatInputA(EXPONENT_WIDTH + MANTISSA_WIDTH - 1 downto MANTISSA_WIDTH)));
            mantissaA := "1" & unsigned(floatInputA(MANTISSA_WIDTH - 1 downto 0));
        
            -- Extraire les composants du nombre  virgule flottante
            signB := floatInputB(EXPONENT_WIDTH + MANTISSA_WIDTH);
            exponentB := to_integer(unsigned(floatInputB(EXPONENT_WIDTH + MANTISSA_WIDTH - 1 downto MANTISSA_WIDTH)));
            mantissaB := "1" & unsigned(floatInputB(MANTISSA_WIDTH - 1 downto 0));
        
            -- Calculer le signe du résultat
            signResult := signA xor signB;
        
            -- Effectuer la multiplication des mantisses
            product := ('1' & mantissaA(MANTISSA_WIDTH - 1 downto 0)) * ('1' & mantissaB(MANTISSA_WIDTH - 1 downto 0));
            
            -- Calculer l'exposant du résultat
            exponentResult := exponentA + exponentB - 127;  -- Soustraire le décalage de l'exposant IEEE 754 simple précision
        
             --Normaliser le résultat (décaler la mantisse si nécessaire)
            if product(MANTISSA_WIDTH*2 + 1) = '1' then
                mantissaResult := product(MANTISSA_WIDTH*2 downto MANTISSA_WIDTH+1);
                exponentResult := exponentResult + 1;
            else
                mantissaResult := product(MANTISSA_WIDTH*2-1  downto MANTISSA_WIDTH);
            end if;
        
            -- Construire le résultat en virgule flottante
            result <= std_logic_vector(signResult & std_logic_vector(to_unsigned(exponentResult, EXPONENT_WIDTH)) & std_logic_vector(mantissaResult));
        end if;
            
       
     end process;
end architecture Behavioral;