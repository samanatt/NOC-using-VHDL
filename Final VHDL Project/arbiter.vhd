library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arbiter is
	port(
	clk: in std_logic; reset: in std_logic; 
	r: in std_logic_vector(3 downto 0);
	g: out std_logic_vector(3 downto 0) -- g= 0000, 0001, 0010, 0100, 1000
	);
	
end arbiter;

architecture fair_arbiter_2flit of arbiter is
	
	type my_type is (waitr0, waitr1, waitr2, waitr3, grant0, grant1, grant2, grant3, extra0, extra1, extra2, extra3);
	signal state_reg, state_next: my_type;
	
begin
	
-- state register
	process(clk,reset)
	begin
		if (reset='1') then
			state_reg <= waitr0; -- by default
		elsif (clk'event and clk='1') then
			state_reg <= state_next;
end if;
end process;

-- next-state and output logic
process(state_reg,r)
begin
	--g <= "0000"; -- default values
	case state_reg is
		when waitr0 =>
			if r(0)='1' then
				state_next <= grant0;
			elsif r(1)='1' then
				state_next <= grant1;
			elsif r(2)='1' then
				state_next <= grant2;
			elsif r(3)='1' then
				state_next <= grant3;
			else
				state_next <= waitr0;
			end if;
			g <= "0000";
			
		when waitr1 =>
			if r(1)='1' then
				state_next <= grant1;
			elsif r(2)='1' then
				state_next <= grant2;
			elsif r(3)='1' then
				state_next <= grant3;
			elsif r(0)='1' then
				state_next <= grant0;
			else
				state_next <= waitr1;
			end if;
			g <= "0000";
			
		when waitr2 => 
			if r(2)='1' then
				state_next <= grant2;
			elsif r(3)='1' then
				state_next <= grant3;
			elsif r(0)='1' then
				state_next <= grant0;
			elsif r(1)='1' then
				state_next <= grant1;
			else
				state_next <= waitr2;
			end if;
			g <= "0000";
			
		when waitr3 =>
			if r(3)='1' then
				state_next <= grant3;
			elsif r(0)='1' then
				state_next <= grant0;
			elsif r(1)='1' then
				state_next <= grant1;
			elsif r(2)='1' then
				state_next <= grant2;
			else
				state_next <= waitr3;
			end if;
			g <= "0000";
			
		when grant0 =>

			state_next <= extra0;

			g <= "0001";
			
		when grant1 =>

			state_next <= extra1;

			g <= "0010";
			
		when grant2 =>

			state_next <= extra2;

			g <= "0100";
				
		when grant3 =>
			
			state_next <= extra3;	
			g <= "1000";
			
		when extra0 =>
			if(r(0)='1')then
				state_next <= grant0;
			else
				state_next <= waitr1;
			end if;
			g <= "0001";
			
		when extra1 =>
			if(r(1)='1')then
				state_next <= grant1;
			else
				state_next <= waitr2;
			end if;
			g <= "0010";
			
		when extra2 =>
			if(r(2)='1')then
				state_next <= grant2;
			else
				state_next <= waitr3;
			end if;
			g <= "0100";
			
		when extra3 =>
			if(r(3)='1')then
				state_next <= grant3;
			else
				state_next <= waitr0;
			end if;
			g <= "1000";
			
			
	end case;
					
end process;
end fair_arbiter_2flit;


	

