library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity FloatADD is
generic (
        EXPONENT_WIDTH : integer := 8;  -- Largeur de l'exposant en virgule flottante (IEEE 754 simple précision)
        MANTISSA_WIDTH : integer := 23  -- Largeur de la mantisse en virgule flottante (IEEE 754 simple précision)
    );
    port (
        floatInputA : in std_logic_vector(EXPONENT_WIDTH + MANTISSA_WIDTH downto 0);  -- Entrée : nombre Ã  virgule flottante A
        floatInputB : in std_logic_vector(EXPONENT_WIDTH + MANTISSA_WIDTH downto 0);  -- Entrée : nombre Ã  virgule flottante B
        result : out std_logic_vector(EXPONENT_WIDTH + MANTISSA_WIDTH downto 0)  -- Sortie : résultat de la multiplication en virgule flottante
    );
end entity FloatADD;

architecture ADDarch of FloatADD is

begin
    process(floatInputA,floatInputB)
    variable mantissaA, mantissaB : std_logic_vector(MANTISSA_WIDTH+2 downto 0);
    variable mantissa1, mantissa2 : std_logic_vector(MANTISSA_WIDTH downto 0);
    variable mantissaResult : unsigned(MANTISSA_WIDTH-1  downto 0);
    variable sum : unsigned(MANTISSA_WIDTH+2 downto 0);  -- Largeur suffisamment grande pour contenir le résultat de la multiplication
    variable sign1, sign2, signResult : std_logic;
    variable exponent1, exponent2  : unsigned (EXPONENT_WIDTH-1 downto 0);
    variable exponentResult : unsigned (EXPONENT_WIDTH-1 downto 0);
    variable exponentDifference : signed(EXPONENT_WIDTH-1 downto 0);
    variable expdiffInt,indic,i,k : integer:=0;
    variable zeros : unsigned(4 downto 0);
    
    procedure sub (mantissa1 : std_logic_vector;exposant1 : unsigned; mantissa2 : std_logic_vector; exposant2 : unsigned) is
        begin 
        -- vérification des exposants :
           exponentDifference := signed(exposant1 - exposant2);

          
            if exponentDifference < 23 then
                if exponentDifference > 0 then --exposant1 > exposant2
                        
                    mantissaA :=  std_logic_vector(to_unsigned(0, 2)) & mantissa1(23 downto 0);
                    mantissaB :=  std_logic_vector(to_unsigned(0, 2)) &  std_logic_vector(shift_right(unsigned(mantissa2),to_integer(exponentDifference)));
                    exponentResult:=exposant1;
                    
                else --exposant1 =< exposant2
                    mantissaB :=  std_logic_vector(to_unsigned(0, 2)) & mantissa2(23 downto 0);
                    mantissaA :=  std_logic_vector(to_unsigned(0, 2)) &  std_logic_vector(shift_right(unsigned(mantissa1),to_integer(-exponentDifference)));
                    exponentResult:=exposant2;
                     
                end if;
                
                sum := unsigned(mantissaA) - unsigned(mantissaB);
                
                
                
                if sum(MANTISSA_WIDTH+2) = '1' then -- le résultat est négatif
                    signResult := '1';
                    sum := not(sum)+1;
                    
                else
                    signResult := '0'; -- le résultat est positif
                end if;
                
                
             
                
--                normalisation                
                if sum /= 0 then
                indic := 0;
                
--                    while sum(MANTISSA_WIDTH+2)/='1' loop
--                        sum := shift_left(unsigned(sum),1);
--                        exponentResult := exponentResult-indic;
--                        indic := 1;
--                    end loop;
                    
                    zeros := "00000";
                    i := 0;
                    
                    for i in 24 downto 0 loop
                    
                        if sum(i)='1' then
                          sum := shift_left(unsigned(sum), to_integer(zeros)+1);
                          exponentResult := exponentResult - zeros;
                          indic :=1;
                          exit;
                        end if;
                        
                        zeros := zeros + 1;
                        
                    end loop;


--                    while sum(MANTISSA_WIDTH+2)/='1' loop
--                        sum := shift_left(unsigned(sum),1);
--                        exponentResult := exponentResult-indic;
--                        indic := 1;
--                    end loop;
                        
                        
                    
                    
                     exponentResult := exponentResult+indic;
                   
                else
                    exponentResult := "00000000";
                end if;
                
                mantissaResult := sum(MANTISSA_WIDTH+1 downto 2);
                    
           elsif exponentDifference > 0 then --argument1 >>>> argument2
                mantissaResult := unsigned(mantissa1(MANTISSA_WIDTH-1 downto 0));
                signResult := '1'; -- le résultat est negatif
           elsif exponentDifference < 0 then --argument1 >>>> argument2
                mantissaResult := unsigned(mantissa2(MANTISSA_WIDTH-1 downto 0));
                signResult := '0'; -- le résultat est positif
           end if;
    end procedure;
    
    
    procedure add (mantissa1 : std_logic_vector;exposant1 : unsigned; mantissa2 : std_logic_vector; exposant2 : unsigned) is
    begin 
            exponentDifference := signed(exposant1 - exposant2);

          
            if exponentDifference < 23 then
                if exponentDifference > 0 then --exposant1 > exposant2
                        
                    mantissaA :=  std_logic_vector(to_unsigned(0, 2)) & mantissa1(23 downto 0);
                    mantissaB :=  std_logic_vector(to_unsigned(0, 2)) & std_logic_vector(shift_right(unsigned(mantissa2),to_integer(exponentDifference)));
                    exponentResult := exposant1;
                    
                else --exposant1 =< exposant2
                    mantissaB :=  std_logic_vector(to_unsigned(0, 2)) & mantissa2(23 downto 0);
                    
                    mantissaA :=  std_logic_vector(to_unsigned(0, 2)) & std_logic_vector(shift_right(unsigned(mantissa1),to_integer(-exponentDifference)));
                    exponentResult := exposant2;
                     
                end if;

                sum := unsigned(mantissaA) + unsigned(mantissaB);

                -- normalisation (check du carry)
                if sum(MANTISSA_WIDTH+1) = '1' then
                    mantissaResult := sum(MANTISSA_WIDTH downto 1);
                    exponentResult := exponentResult+1;

                else
                    mantissaResult := sum(MANTISSA_WIDTH-1 downto 0);
          
                end if;
           elsif exponentDifference > 0 then --argument11 >>>> argument2
                mantissaResult := unsigned(mantissa1(MANTISSA_WIDTH-1 downto 0));
           elsif exponentDifference < 0 then --argument11 >>>> argument2
                mantissaResult := unsigned(mantissa2(MANTISSA_WIDTH-1 downto 0));
           end if;
    end procedure;
    
        begin
        -- Extraire les composants du nombre  virgule flottante 
        sign1 := floatInputA(EXPONENT_WIDTH + MANTISSA_WIDTH);

        exponent1 := unsigned(floatInputA(EXPONENT_WIDTH + MANTISSA_WIDTH - 1 downto MANTISSA_WIDTH));
        mantissa1 := "1" & std_logic_vector(unsigned(floatInputA(MANTISSA_WIDTH - 1 downto 0)));

        -- Extraire les composants du nombre  virgule flottante
        sign2 := floatInputB(EXPONENT_WIDTH + MANTISSA_WIDTH);
        exponent2 := unsigned(floatInputB(EXPONENT_WIDTH + MANTISSA_WIDTH - 1 downto MANTISSA_WIDTH));
        mantissa2 := "1" & std_logic_vector(unsigned(floatInputB(MANTISSA_WIDTH - 1 downto 0)));

        
        
        
         --cas exceptionnel : floatInputA=0 ou floatInputB=0
        
        if floatInputA(30 downto 0) ="0000000000000000000000000000000"  then
            result <=floatInputB;
        elsif  floatInputB(30 downto 0) ="0000000000000000000000000000000" then
            result <=floatInputA;
        else
        
            --  choix de la bonne opération en fonction des signes de A et B :
            
            if sign1 = '0' and sign2 = '0' then  --positif positif
            
            add(mantissa1,exponent1, mantissa2, exponent2);
            signResult := '0';
            
            elsif sign1 = '0' and sign2 = '1' then --positif negatif
            sub(mantissa1,exponent1, mantissa2, exponent2);
            
            
            elsif sign2 = '0' and sign1 = '1' then --negatif positif
            sub(mantissa2,exponent2, mantissa1, exponent1);
           
            
            else --negatif negatif
            add(mantissa1, exponent1, mantissa2, exponent2);
            signResult := '1';
            end if;
            
            -- construction du vecteur résultat
            result <= std_logic_vector(signResult & std_logic_vector(to_unsigned(to_integer(exponentResult), 8)) & std_logic_vector(mantissaResult));
        end if;
     end process;
end architecture ADDarch;
