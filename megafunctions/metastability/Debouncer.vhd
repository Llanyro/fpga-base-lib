library ieee;
library llanylib;

use ieee.std_logic_1164.all;
use llanylib.LlanySettings.all;

entity Debouncer is
	generic (
		NUMBER_OF_TICKS : NAT 								:= 500000
	);
	port (
		clk				: in  SL;
		rst				: in  SL;
		data			: in  SL;
		result			: out SL							:= '0'
	);
end entity Debouncer;

architecture DebouncerArch of Debouncer is
	signal counter		: NAT range 0 to NUMBER_OF_TICKS	:= 0;
	signal reg			: SL								:= '0';
	signal output_reg	: SL								:= '0';

begin
	double_register	: llanylib.DoubleRegister
		port map(
			clk		=> clk,
			rst		=> rst,
			data	=> data,
			result	=> reg
		);

	process (clk, rst, data, result)
	begin
		if rst = '1' then
			reg					<= '0';
			counter				<= 0;
			output_reg			<= '0';

		elsif rising_edge(clk) then
			if reg /= output_reg then
				counter			<= 0;
			else
				if counter < NUMBER_OF_TICKS then
					counter		<= counter + 1;
				else
					output_reg	<= reg;
				end if;
			end if;
		end if;
	end process;

	result <= output_reg;
end architecture DebouncerArch;