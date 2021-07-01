library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity tb_factorial is
end tb_factorial;

architecture Behavioral of tb_factorial is
component factorial is
    port(
        clk,rst,start : in std_logic;
        n : in std_logic_vector(2 downto 0);
        data_out: out std_logic_vector(12 downto 0);
        ready : out std_logic
    );
end component;

signal clk_s,rst_s,start_s : std_logic;
signal        n_s : std_logic_vector(2 downto 0);
signal        data_out_s: std_logic_vector(12 downto 0);
signal        ready_s : std_logic;

for dut: factorial use entity work.factorial(FSMD);
begin

dut: factorial port map (clk=>clk_s,rst=>rst_s,start=>start_s,n=>n_s,data_out=>data_out_s,ready=>ready_s);

    process
    begin
        clk_s<='0';
        wait for 10 ns;
        clk_s<='1';
        wait for 10 ns;
    end process;
    
    process
    begin
        rst_s<='1';
        wait for 5 ns;
        rst_s<='0'; n_s<="100"; start_s<='1';
        wait for 20 ns;
        wait for 20 ns;
        start_s<='0';
        wait for 120 ns;
        rst_s<='0'; n_s<="111"; start_s<='1';
        wait for 20 ns;
        wait for 20 ns;
        start_s<='0';
        wait for 120 ns;
        rst_s<='0'; n_s<="000"; start_s<='1';
        wait for 20 ns;
        wait for 20 ns;
        start_s<='0';
        wait for 120 ns;
        wait;
    end process;



end Behavioral;
