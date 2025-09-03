library ieee;
library llanylib;

use ieee.std_logic_1164.ALL;
use llanylib.LlanySettings.all;

entity UniversalAsynchonousReceiver is
	generic(
		BUS_SIZE		: NAT	:= 8;
		TICKS_PER_BIT	: NAT	:= 115
	);
	port(
		clk				: in	SL;
		rst				: in	SL;
		data_wire		: in	SL;
		valid_data		: out	SL									:= '-';				-- Flag to tell if data received is valid
		data			: out	SLV (BUS_SIZE - 1 downto 0)			:= (others => '-')	-- Data received
	);
end entity UniversalAsynchonousReceiver;

architecture UniversalAsynchonousReceiverArch of UniversalAsynchonousReceiver is
	constant BUS_SIZE_L		: NAT									:= BUS_SIZE		- 1;
	constant TICKS_PER_BIT_L	: NAT								:= TICKS_PER_BIT	- 1;

	signal mode					: URTMode							:= URT_Idle;
	signal internal_data_bit	: SL								:= '1';
	signal counter				: NAT range 0 to TICKS_PER_BIT_L	:= 0;
	signal index				: NAT range 0 to BUS_SIZE_L			:= 0;  -- Position of bit to get
	signal internal_data		: SLV (BUS_SIZE_L downto 0)			:= (others => '0');
	signal internal_valid_data	: SL								:= '0';

begin
	double_register	: llanylib.DoubleRegister
		port map(
			clk		=> clk,
			rst		=> rst,
			data	=> data_wire,
			result	=> internal_data_bit
		);

	-- Purpose: Control RX state machine
	process (clk)
	begin
		if rst = '1' then
			mode								<= URT_Idle;
			internal_data_bit					<= '1';
			counter								<= 0;
			index								<= 0;
			--internal_data						<= (others => '0');	-- No need to clear it (by default this data is invalid)
			valid_data							<= '0';				-- Data is invalid
			internal_valid_data					<= '0';

		elsif rising_edge(clk) then
			case mode is
				when URT_Idle =>
					internal_valid_data			<= '0';
					counter						<= 0;
					index						<= 0;

					-- Start bit detected
					if internal_data_bit = '0' then
						mode					<= URT_Start;
					else
						mode					<= URT_Idle;
					end if;

				-- Check middle of start bit to make sure it's still low
				when URT_Start =>
					if counter = (TICKS_PER_BIT_L / 2) then
						if internal_data_bit = '0' then
							counter				<= 0;			-- rst counter since we found the middle
							mode				<= URT_Data;
						else
							mode				<= URT_Idle;
						end if;
					else
						counter					<= counter + 1;
						mode					<= URT_Start;
					end if;

				-- Wait TICKS_PER_BIT_L clock cycles to sample serial data
				when URT_Data =>
					if counter < TICKS_PER_BIT_L then
						counter					<= counter + 1;
						mode					<= URT_Data;
					else
						counter					<= 0;
						internal_data(index)	<= internal_data_bit;

						-- Check if we have received out all bits
						if index < BUS_SIZE_L then
							index				<= index + 1;
							mode				<= URT_Data;
						else
							index				<= 0;
							mode				<= URT_Stop;
						end if;
					end if;

				-- Receive Stop bit. Stop bit = 1
				when URT_Stop =>
					-- Wait TICKS_PER_BIT_L clock cycles for Stop bit to finish
					if counter < TICKS_PER_BIT_L then
						counter					<= counter + 1;
						mode					<= URT_Stop;
					else
						internal_valid_data				<= '1';
						counter					<= 0;
						mode					<= URT_Cleanup;
					end if;

				-- Delay one more tick
				when URT_Cleanup =>
					mode				<= URT_Idle;

			end case;
		end if;
	end process;

	valid_data		<= internal_valid_data;
	data		<= internal_data;
end architecture UniversalAsynchonousReceiverArch;