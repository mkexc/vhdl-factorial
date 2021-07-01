library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity factorial is
    port(
        clk,rst,start : in std_logic;
        n : in std_logic_vector(2 downto 0);
        data_out: out std_logic_vector(12 downto 0);
        ready : out std_logic
    );
end factorial;

architecture HLSM of factorial is
    
    type stateType is (S_init,S_wait,S_comp,S_end);
    signal currState,nextState : stateType;
    signal currOut,nextOut : std_logic_vector(12 downto 0);
    signal currN,currCnt,nextCnt: std_logic_vector(2 downto 0);
begin
    
    process(clk,rst)
    begin
        if(rst='1') then 
            currState<=S_init;
            currOut<=(others => '0');
            currN<=(others => '0');
            currCnt<=(others => '0');
        elsif (rising_edge(clk)) then
            currState<=nextState;
            currOut<=nextOut;
            if(start='1') then
                currN<=n;
            end if;
            currCnt<=nextCnt;
        end if;
    end process;
    
    data_out<=currOut;
    
    process(currState,start,currOut,currCnt)
    variable temp: integer;
    begin
    ready<='0';
        case currState is
            when S_init=> nextState<=S_wait; nextOut<=(others => '0'); nextCnt<=(others => '0');
            when S_wait=>  if(start='1') then
                                nextState<=S_comp;
                                nextOut<=(12 downto 1 => '0')&"1";
                                nextCnt<=(2 downto 1 => '0')&"1";
                            else
                                nextState<=S_wait;
                                nextOut<=(others => '0');
                                nextCnt<=(others => '0');
                            end if;
            when S_comp=>   if(currCnt>=currN) then
                                nextState<=S_end;
                            else
                                nextState<=S_comp;
                            end if;
                            temp:= to_integer(unsigned(currOut));
                            temp:=temp*to_integer(unsigned(currCnt));
                            nextOut<= std_logic_vector(to_unsigned(temp,nextOut'length)); 
                            nextCnt<=std_logic_vector(unsigned(currCnt)+1);
            when S_end=>    ready<='1';   nextState<=S_wait;  
                            nextOut<=(others => '0');
                            nextCnt<=(others => '0');   
            when others=>   nextState<=S_Init;
                            nextOut<=(others => '0');
                            nextCnt<=(others => '0');   
        end case;
    end process;

end HLSM;

architecture FSMD of factorial is
    
    -- Shared signals
    signal cmp_gt,cnt_sel:std_logic;
    signal out_sel: std_logic_vector(1 downto 0);
    -- DP signals
    signal currOut,nextOut : std_logic_vector(12 downto 0);
    signal currN,currCnt,nextCnt: std_logic_vector(2 downto 0);
    -- FSM signals
    type stateType is (S_init,S_wait,S_comp,S_end);
    signal currState,nextState : stateType;
    
begin
    -- Datapath processes
    DPRegs: process(clk,rst)
    begin
        if(rst='1') then 
            currOut<=(others => '0');
            currN<=(others => '0');
            currCnt<=(others => '0');
        elsif (rising_edge(clk)) then
            currOut<=nextOut;
            if(start='1') then
                currN<=n;
            end if;
            currCnt<=nextCnt;
        end if;
    end process;
    
    data_out<=currOut;
    cmp_gt<= '1' when currCnt>=currN else '0';
    nextCnt<= std_logic_vector(unsigned(currCnt)+1) when cnt_sel='1' else (others=>'0');
    nextOut<= (others=>'0') when out_sel="00" else
              (12 downto 1 => '0')&"1" when out_sel="01" else
              std_logic_vector(to_unsigned(to_integer(unsigned(currCnt))*to_integer(unsigned(currOut)),nextOut'length));
    
    -- Controller processes
    CtlReg:process(clk,rst)
    begin
        if(rst='1') then 
            currState<=S_init;
        elsif (rising_edge(clk)) then
            currState<=nextState;
        end if;
    end process;

    CtlComb:process(currState,start,cmp_gt)
    begin
    ready<='0';
        case currState is
            when S_init=> nextState<=S_wait; out_sel<="00"; cnt_sel<='0';
            when S_wait=>  if(start='1') then
                                nextState<=S_comp;
                                out_sel<="01"; cnt_sel<='1';
                            else
                                nextState<=S_wait;
                                out_sel<="00"; cnt_sel<='0';
                            end if;
            when S_comp=>   if(cmp_gt='1') then
                                nextState<=S_end;
                            else
                                nextState<=S_comp;
                            end if;
                            out_sel<="10";
                            cnt_sel<='1';
            when S_end=>    ready<='1';   nextState<=S_wait;  
                            out_sel<="00"; cnt_sel<='0';
            when others=>   nextState<=S_Init;
                            out_sel<="00"; cnt_sel<='0';  
        end case;
    end process;

end FSMD;
