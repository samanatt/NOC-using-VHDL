library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY NoC_tb IS
END NoC_tb;

ARCHITECTURE test_NoC OF NoC_tb IS

	COMPONENT NoC PORT(clk, reset: IN std_logic;

	w_en_north_in_5, w_en_south_in_5, w_en_west_in_5, w_en_local_in_5: IN std_logic;
	w_en_north_in_6, w_en_south_in_6, w_en_east_in_6, w_en_local_in_6: IN std_logic;

	fifo_in_north_in_5, fifo_in_south_in_5, fifo_in_west_in_5, fifo_in_local_in_5: IN std_logic_vector(11 DOWNTO 0); --vase 5 4 ta vurudi darim 
	fifo_in_north_in_6, fifo_in_south_in_6, fifo_in_east_in_6, fifo_in_local_in_6: IN std_logic_vector(11 DOWNTO 0));
	END COMPONENT;
	
	signal clk, reset: std_logic;
	signal fifo_in_north_in_5, fifo_in_south_in_5, fifo_in_west_in_5, fifo_in_local_in_5: std_logic_vector(11 DOWNTO 0):="000000000000";
	signal fifo_in_north_in_6, fifo_in_south_in_6, fifo_in_east_in_6, fifo_in_local_in_6: std_logic_vector(11 DOWNTO 0):="000000000000";
	
	signal w_en_north_in_5, w_en_south_in_5, w_en_west_in_5, w_en_local_in_5: std_logic:='0';
	signal w_en_north_in_6, w_en_south_in_6, w_en_east_in_6, w_en_local_in_6: std_logic:='0';
	
begin
--Unit Under Test
	uut: NoC PORT MAP(
	clk => clk, reset => reset, 
	fifo_in_north_in_5 => fifo_in_north_in_5, fifo_in_south_in_5 => fifo_in_south_in_5, fifo_in_west_in_5 => fifo_in_west_in_5, fifo_in_local_in_5 => fifo_in_local_in_5,
	fifo_in_north_in_6 => fifo_in_north_in_6, fifo_in_south_in_6 => fifo_in_south_in_6, fifo_in_east_in_6 => fifo_in_east_in_6, fifo_in_local_in_6 => fifo_in_local_in_6,
	w_en_north_in_5 => w_en_north_in_5, w_en_south_in_5 => w_en_south_in_5, w_en_west_in_5 => w_en_west_in_5, w_en_local_in_5 => w_en_local_in_5,
	w_en_north_in_6 => w_en_north_in_6, w_en_south_in_6 => w_en_south_in_6, w_en_east_in_6 => w_en_east_in_6, w_en_local_in_6 => w_en_local_in_6
	);

	process
	begin
	LOOP
		clk <= '0';
		wait for 100 ns;
		clk <= '1';
		wait for 100 ns;
		if (now >= 1000000ns)then
			wait;
		end if;
	END LOOP;
	end process;
	
	reset <= '1', '0' after 200 ns;
	
	-------------------------------------------
	-- teste ostad vase 2 flit (arbiter2) (x,y)
	-------------------------------------------
	fifo_in_west_in_5<= "00"&"0100"&"0010"&"00", "10"&"0100"&"0000"&"00" after 500 ns; --(4->2)x2flit
	w_en_west_in_5 <= '1'after 300 ns, '0' after 700 ns;
	
	fifo_in_east_in_6<= "00"&"0111"&"1001"&"00", "10"&"0111"&"0000"&"00" after 500 ns; --(7->9)x2flit
	w_en_east_in_6<= '1'after 300 ns, '0' after 700 ns;
	
	fifo_in_local_in_6<= "00"&"0110"&"0001"&"00", "10"&"0110"&"0000"&"00" after 500 ns; --(6->1)x2flit
	w_en_local_in_6<= '1'after 300 ns, '0' after 700 ns;
	
	fifo_in_north_in_5<= "00"&"0001"&"0101"&"00", "10"&"0001"&"0000"&"00" after 500 ns; --(1->5)x2flit
	w_en_north_in_5<= '1'after 300 ns, '0' after 700 ns;

	fifo_in_south_in_6<= "00"&"1010"&"0100"&"00", "10"&"1010"&"0000"&"00" after 500 ns; --(10->4)x2flit
	w_en_south_in_6<= '1'after 300 ns, '0' after 700 ns;
	

END test_NoC;