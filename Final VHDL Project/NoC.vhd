library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity NoC is
PORT(
clk, reset: IN std_logic;
--in_north_5, in_south_5, in_west_5, in_local_5: IN std_logic_vector(11 DOWNTO 0); 
--in_north_6, in_south_6, in_east_6, in_local_6: IN std_logic_vector(11 DOWNTO 0);

w_en_north_in_5, w_en_south_in_5, w_en_west_in_5, w_en_local_in_5: IN std_logic;
w_en_north_in_6, w_en_south_in_6, w_en_east_in_6, w_en_local_in_6: IN std_logic;

fifo_in_north_in_5, fifo_in_south_in_5, fifo_in_west_in_5, fifo_in_local_in_5: IN std_logic_vector(11 DOWNTO 0); --vase 5 4 ta vurudi darim 
fifo_in_north_in_6, fifo_in_south_in_6, fifo_in_east_in_6, fifo_in_local_in_6: IN std_logic_vector(11 DOWNTO 0) --vurudie fifo hAye vurudie node 


-- buffere vurudi tarif mikonam signal e wr va data ro mizaram inja tu signal vurudi (be jaye balaie hA)	
);
END NoC;

ARCHITECTURE connection OF NoC IS
	COMPONENT FIFO_NODE PORT(
	clk, reset: IN std_logic;
	w_en_north, w_en_south, w_en_east, w_en_west, w_en_local: IN std_logic;
	fifo_in_north, fifo_in_south, fifo_in_east, fifo_in_west, fifo_in_local: IN std_logic_vector(11 DOWNTO 0);
	r_en_north, r_en_south, r_en_east, r_en_west, r_en_local: IN std_logic;
	full_north, full_south, full_east, full_west, full_local : OUT std_logic;
	empty_north, empty_south, empty_east, empty_west, empty_local : OUT std_logic;
	fifo_out_north, fifo_out_south, fifo_out_east, fifo_out_west, fifo_out_local: OUT std_logic_vector(11 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT router_to_arbiter
	PORT(
	clk, reset: IN std_logic;
	current : IN INTEGER; 
	fifo_in_local, fifo_in_west, fifo_in_east, fifo_in_north, fifo_in_south : IN std_logic_vector(11 DOWNTO 0); 
	w_en_north, w_en_south, w_en_east, w_en_west, w_en_local: OUT std_logic;
	credit_out_north, credit_out_south, credit_out_east, credit_out_west, credit_out_local: IN std_logic;
	empty_in_north, empty_in_south, empty_in_east, empty_in_west, empty_in_local: IN std_logic;
	fifo_out_north, fifo_out_south, fifo_out_east, fifo_out_west, fifo_out_local: OUT std_logic_vector(11 DOWNTO 0);
	r_en_north_in, r_en_south_in, r_en_east_in, r_en_west_in, r_en_local_in: OUT std_logic
	);
	END COMPONENT router_to_arbiter;

	COMPONENT FIFO_BUFFER PORT(
		clk,reset,wr,rd :in std_logic;
		w_data : in std_logic_vector(11 downto 0);
		full, empty : out std_logic;
		r_data : out std_logic_vector(11 downto 0)
	);
	END COMPONENT;
	
	SIGNAL signal_in_local_5, signal_in_west_5, signal_in_north_5, signal_in_south_5, signal_in_east_5: std_logic_vector(11 DOWNTO 0); --khurujie fifo hAye vurudie node
	SIGNAL signal_in_local_6, signal_in_west_6, signal_in_north_6, signal_in_south_6, signal_in_east_6: std_logic_vector(11 DOWNTO 0);
	
	SIGNAL w_en_north_5, w_en_south_5, w_en_east_5, w_en_west_5, w_en_local_5: std_logic;
	SIGNAL w_en_north_6, w_en_south_6, w_en_east_6, w_en_west_6, w_en_local_6: std_logic;
	
	SIGNAL signal_out_local_5, signal_out_west_5, signal_out_north_5, signal_out_south_5, signal_out_east_5: std_logic_vector(11 DOWNTO 0);
	SIGNAL signal_out_local_6, signal_out_west_6, signal_out_north_6, signal_out_south_6, signal_out_east_6: std_logic_vector(11 DOWNTO 0);
	
	SIGNAL empty_east_5: std_logic; -- age niaz shod full ro ham ezafe kon vase write kardan
	SIGNAL empty_west_6: std_logic;
	
	SIGNAL full_north_5, full_south_5, full_east_5, full_west_5, full_local_5: std_logic;
	SIGNAL full_north_6, full_south_6, full_east_6, full_west_6, full_local_6: std_logic;
	
	--SIGNAL full_north_in_5, full_south_in_5, full_east_in_5, full_west_in_5, full_local_in_5: std_logic;
	--SIGNAL full_north_in_6, full_south_in_6, full_east_in_6, full_west_in_6, full_local_in_6: std_logic;
	
	SIGNAL r_en_north_5, r_en_south_5, r_en_east_5, r_en_west_5, r_en_local_5: std_logic;
	SIGNAL r_en_north_6, r_en_south_6, r_en_east_6, r_en_west_6, r_en_local_6: std_logic;
	
	SIGNAL empty_in_north_5, empty_in_south_5, empty_in_east_5, empty_in_west_5, empty_in_local_5: std_logic;
	SIGNAL empty_in_north_6, empty_in_south_6, empty_in_east_6, empty_in_west_6, empty_in_local_6: std_logic;
	
	--SIGNAL r_en_north_out_5, r_en_south_out_5, r_en_east_out_5, r_en_west_out_5, r_en_local_out_5: std_logic;
	--SIGNAL r_en_north_out_6, r_en_south_out_6, r_en_east_out_6, r_en_west_out_6, r_en_local_out_6: std_logic;
	
begin
	
	------------------
	-- router 5
	------------------	
	
	router_5: router_to_arbiter PORT MAP(
	clk => clk, reset => reset,
	current => 5 ,
	fifo_in_local => signal_in_local_5, fifo_in_west => signal_in_west_5, fifo_in_east => signal_in_east_5,
	fifo_in_north => signal_in_north_5, fifo_in_south => signal_in_south_5,
	w_en_north => w_en_north_5, w_en_south => w_en_south_5, w_en_east => w_en_east_5, w_en_west => w_en_west_5, w_en_local => w_en_local_5,
	credit_out_north => full_north_5, credit_out_south => full_south_5, credit_out_east => full_east_5, credit_out_west => full_west_5, credit_out_local => full_local_5,
	empty_in_north => empty_in_north_5, empty_in_south => empty_in_south_5, empty_in_east => empty_in_east_5, empty_in_west => empty_in_west_5, empty_in_local => empty_in_local_5,
	r_en_north_in => r_en_north_5, r_en_south_in => r_en_south_5, r_en_east_in => r_en_east_5, r_en_west_in => r_en_west_5, r_en_local_in => r_en_local_5,
	--r_en_north_out => r_en_north_out_5, r_en_south_out => r_en_south_out_5, r_en_east_out => r_en_east_out_5, r_en_west_out => r_en_west_out_5, r_en_local_out => r_en_local_out_5,
	fifo_out_north => signal_out_north_5, fifo_out_south => signal_out_south_5, fifo_out_east => signal_out_east_5, fifo_out_west => signal_out_west_5, fifo_out_local => signal_out_local_5 --khurujie node ke mire be vurudie fifo haye khuruji
	);
	
	
	fifo_buffer_router_5: FIFO_NODE PORT MAP( --r_en_east => r_en_west_6 
	clk => clk, reset => reset,
	w_en_north => w_en_north_5, w_en_south => w_en_south_5, w_en_east => w_en_east_5, w_en_west => w_en_west_5, w_en_local => w_en_local_5,
	fifo_in_north => signal_out_north_5, fifo_in_south => signal_out_south_5, fifo_in_east => signal_out_east_5, fifo_in_west => signal_out_west_5, fifo_in_local => signal_out_local_5,
	r_en_north => '0', r_en_south => '0', r_en_east => r_en_west_6, r_en_west => '0', r_en_local => '0', --read en fifo khurujie east 5 ro tavasote router e 6 tolid mishe ke vurudie west hast 
	full_north => full_north_5, full_south => full_south_5, full_east => full_east_5, full_west => full_west_5, full_local => full_local_5,
	empty_north => open, empty_south => open, empty_east => empty_in_west_6, empty_west => open, empty_local => open,
	fifo_out_north => open, fifo_out_south => open, fifo_out_east => signal_in_west_6, fifo_out_west => open, fifo_out_local => open
	);
	
	buffer_north_in_5: FIFO_BUFFER PORT MAP( -- node 1
		clk => clk, reset => reset,
		wr => w_en_north_in_5, -- bayad tu test bench faal konam
		rd => r_en_north_5, -- az router_to_arbiter miad (vaghti arbitere jahatAye s,e,w,l be north_in grant midan bayad rd 1 beshe)
		w_data => fifo_in_north_in_5, -- bayad tu test bench meghdar bedam
		full => open,
		empty => empty_in_north_5,
		r_data => signal_in_north_5 -- mire be vurudie north e router_5
	);
	 
	buffer_south_in_5: FIFO_BUFFER PORT MAP( --node 9
		clk => clk, reset => reset,
		wr => w_en_south_in_5, -- bayad tu test bench faal konam
		rd => r_en_south_5, -- az router_to_arbiter miad 
		w_data => fifo_in_south_in_5, -- bayad tu test bench meghdar bedam
		full => open,
		empty => empty_in_south_5,
		r_data => signal_in_south_5 -- mire be vurudie north e router_5
	);
	
	buffer_west_in_5: FIFO_BUFFER PORT MAP( --node 4
		clk => clk, reset => reset,
		wr => w_en_west_in_5, -- bayad tu test bench faal konam
		rd => r_en_west_5, -- az router_to_arbiter miad
		w_data => fifo_in_west_in_5, -- bayad tu test bench meghdar bedam
		full => open,
		empty => empty_in_west_5,
		r_data => signal_in_west_5 -- mire be vurudie north e router_5
	);
	
	buffer_local_in_5: FIFO_BUFFER PORT MAP( --node 5
		clk => clk, reset => reset,
		wr => w_en_local_in_5, -- bayad tu test bench faal konam
		rd => r_en_local_5, -- az router_to_arbiter miad
		w_data => fifo_in_local_in_5, -- bayad tu test bench meghdar bedam
		full => open,
		empty => empty_in_local_5,
		r_data => signal_in_local_5 -- mire be vurudie north e router_5
	);
	
	------------------
	-- router 6 
	------------------
	
	router_6: router_to_arbiter PORT MAP(
	clk => clk, reset => reset,
	current => 6,
	fifo_in_local => signal_in_local_6, fifo_in_west => signal_in_west_6, fifo_in_east => signal_in_east_6,-- ino badan radif kon ba buffere badi
	fifo_in_north => signal_in_north_6, fifo_in_south => signal_in_south_6,
	w_en_north => w_en_north_6, w_en_south => w_en_south_6, w_en_east => w_en_east_6, w_en_west => w_en_west_6, w_en_local => w_en_local_6,
	credit_out_north => full_north_6, credit_out_south => full_south_6, credit_out_east => full_east_6, credit_out_west => full_west_6, credit_out_local => full_local_6,
	empty_in_north  =>empty_in_north_6 , empty_in_south =>empty_in_south_6 , empty_in_east => empty_in_east_6, empty_in_west => empty_in_west_6, empty_in_local => empty_in_local_6 ,
	r_en_north_in => r_en_north_6, r_en_south_in => r_en_south_6, r_en_east_in => r_en_east_6, r_en_west_in => r_en_west_6, r_en_local_in => r_en_local_6,
	fifo_out_north => signal_out_north_6, fifo_out_south => signal_out_south_6, fifo_out_east => signal_out_east_6, fifo_out_west => signal_out_west_6, fifo_out_local => signal_out_local_6
	);
	

	buffer_north_in_6: FIFO_BUFFER PORT MAP(
		clk => clk, reset => reset,
		wr => w_en_north_in_6, -- bayad tu test bench faal konam
		rd => r_en_north_6, -- az router_to_arbiter miad (vaghti arbitere jahatAye s,e,w,l be north_in grant midan bayad rd 1 beshe)
		w_data => fifo_in_north_in_6, -- bayad tu test bench meghdar bedam
		full => open,
		empty => empty_in_north_6,
		r_data => signal_in_north_6 -- mire be vurudie north e router_6
	);
	
	buffer_south_in_6: FIFO_BUFFER PORT MAP(
		clk => clk, reset => reset,
		wr => w_en_south_in_6, -- bayad tu test bench faal konam
		rd => r_en_south_6, -- az router_to_arbiter miad 
		w_data => fifo_in_south_in_6, -- bayad tu test bench meghdar bedam
		full => open,
		empty => empty_in_south_6,
		r_data => signal_in_south_6 -- mire be vurudie north e router_6
	);
	
	buffer_east_in_6: FIFO_BUFFER PORT MAP(
		clk => clk, reset => reset,
		wr => w_en_east_in_6, -- bayad tu test bench faal konam
		rd => r_en_east_6, -- az router_to_arbiter miad
		w_data => fifo_in_east_in_6, -- bayad tu test bench meghdar bedam
		full => open,
		empty => empty_in_east_6,
		r_data => signal_in_east_6 -- mire be vurudie north e router_6
	);
	
	buffer_local_in_6: FIFO_BUFFER PORT MAP(
		clk => clk, reset => reset,
		wr => w_en_local_in_6, -- bayad tu test bench faal konam
		rd => r_en_local_6, -- az router_to_arbiter miad
		w_data => fifo_in_local_in_6, -- bayad tu test bench meghdar bedam
		full => open,
		empty => empty_in_local_6,
		r_data => signal_in_local_6 -- mire be vurudie north e router_6
	);
	

	fifo_buffer_router_6: FIFO_NODE PORT MAP(
	clk => clk, reset => reset,
	w_en_north => w_en_north_6, w_en_south => w_en_south_6, w_en_east => w_en_east_6, w_en_west => w_en_west_6, w_en_local => w_en_local_6,
	fifo_in_north => signal_out_north_6, fifo_in_south => signal_out_south_6, fifo_in_east => signal_out_east_6, fifo_in_west => signal_out_west_6, fifo_in_local => signal_out_local_6,
	r_en_north => '0', r_en_south => '0', r_en_east => '0', r_en_west => r_en_east_5, r_en_local => '0',
	full_north => full_north_6, full_south => full_south_6, full_east => full_east_6, full_west => full_west_6, full_local => full_local_6,
	empty_north => open, empty_south => open, empty_east => open, empty_west => empty_in_east_5, empty_local => open,
	fifo_out_north => open, fifo_out_south => open, fifo_out_east => open, fifo_out_west => signal_in_east_5, fifo_out_local => open
	);
	--empty_west_6
END connection;