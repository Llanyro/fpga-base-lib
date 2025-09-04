library ieee;
library llanylib;

use ieee.std_logic_1164.all;
use llanylib.LlanySettings.all;

-- Stores a logic vector and returns true if the same value has been provided in N clock ticks
entity LogicVectorChecker is
	generic(
		BUS_SIZE			: NAT									:= 1;				--
		NUMBER_OF_TICKS		: NAT									:= 1
	);
	port(
		clk					: in	SL;													-- Clock source
		rst					: in	SL;													-- Module reset
		data				: in	SLV (BUS_SIZE - 1 downto 0);						-- Data to check
		result				: out	SL								:= '0';				-- Result processed
	);
end entity LogicVectorChecker;

architecture LogicVectorCheckerArch of LogicVectorChecker is
	signal counter			: NAT	NAT	range 0 to NUMBER_OF_TICKS	:= 0;				-- Current tick
	signal prev				: SLV	(BUS_SIZE - 1 downto 0)			:= (others => '0');	-- Data stored to check metastability

begin
	process (clk, rst, data, result)
	begin
		if rst = '1' then
			counter			<= 0;
			prev			<= (others => '0');
			result			<= '0';

		elsif rising_edge(clk) then
			if data = prev then
				if counter < NUMBER_OF_TICKS then
					counter	<= counter + 1;
				else result	<= '1';
				end if;

			else
				counter		<= 0;
				prev		<= data_in;
				result		<= '0';

			end if;
		end if;
	end process;
end architecture LogicVectorCheckerArch;