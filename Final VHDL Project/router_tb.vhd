library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- dar yek clock cycle packet haro befrest
-- 2 ta packet instantiate bokon bede be port haye vurudie 

ENTITY router_tb IS
END router_tb;

ARCHITECTURE tb OF router_tb IS


	SIGNAL local_in_5, west_in_5, east_in_5, north_in_5, south_in_5 : std_logic_vector(11 DOWNTO 0);
	SIGNAL local_out_5, west_out_5, east_out_5, north_out_5, south_out_5 : std_logic_vector(11 DOWNTO 0);
	SIGNAL clk, reset: std_logic;

	
	COMPONENT router_to_arbiter
	PORT(
	clk, reset: IN std_logic;
	x_node, y_node : IN INTEGER; -- hamun x , y source vase routing hastan
	
	local_in : IN std_logic_vector(11 DOWNTO 0); --input ha az buffer mian
	west_in : IN std_logic_vector(11 DOWNTO 0);
	east_in : IN std_logic_vector(11 DOWNTO 0);
	north_in : IN std_logic_vector(11 DOWNTO 0);
	south_in : IN std_logic_vector(11 DOWNTO 0)
	);
	END COMPONENT router_to_arbiter;
	
	
BEGIN

	process
	begin
	LOOP
		clk <= '0';
		wait for 100 ns;
		clk <= '1';
		wait for 100 ns;
	END LOOP;
	end process;
	
	reset <= '1', '0' after 100 ns;
	
	uut: router_to_arbiter
				 PORT MAP(
				 clk => clk, reset => reset,
				 x_node => 1, y_node => 1,
				 local_in => local_in_5, west_in => west_in_5, east_in => east_in_5, north_in => north_in_5, south_in => south_in_5);
				 --local_out => local_out_5, west_out => west_out_5, east_out => east_out_5, north_out => north_out_5, south_out => south_out_5);
					
	west_in_5 <= "10"&"0001"&"1000"&"00"; --(4->2)
	north_in_5 <= "10"&"0100"&"1001"&"00", "000000000000" after 400 ns; --(1->6)
	east_in_5 <= "10"&"1101"&"0110"&"00"; --(7->9)
	
END tb;