library ieee;
library llanylib;

use ieee.std_logic_1164.ALL;
use llanylib.LlanySettings.all;
use llanylib.LlanyUniversalReceiverTransmitterSettings.all;

entity UniversalAsynchonousTransmitter is
	generic(
		MAX_BUS_SIZE			: NAT										:= 8;
		TICKS_PER_BIT			: NAT										:= 115;
	);
	port(
		--sys_clk					: in	SL;									-- Any speed xTimes baud
		baud_clk				: in	SL;									-- 115200 bits second
		rst						: in	SL;									-- Module reset

		data					: in	SLV (MAX_BUS_SIZE - 1 downto 0);	-- Data to send
		data_valid				: in	SL;									-- If data to send is valid and prepared to be sent

		max_data_size			: in	NAT	range 1 to MAX_BUS_SIZE;		-- Number of bits to send (any value between 1 - MAX_BUS_SIZE)
		has_parity_bit			: in	SL;									-- If there is a parity bit
		extra_stop_bit			: in	SL;									-- If there is an extra stop bit

		data_out				: out	SL;
		data_sent				: out	SL;
		active					: out	SL									-- In use, working, sending message
	);
end entity UniversalAsynchonousTransmitter;

architecture UniversalAsynchonousTransmitterArch of UniversalAsynchonousTransmitter is
	constant BUS_SIZE_L			: NAT										:= BUS_SIZE			- 1;
	constant TICKS_PER_BIT_L	: NAT										:= TICKS_PER_BIT	- 1;

	signal index				: NAT range 0 to BUS_SIZE_L					:= 0;						-- Position of bit to get

	signal uart_mode			: URTMode									:= URT_Idle;

begin
	-- Do support to get samples or things that needs more speed
	--	More precision
	suportProcess : process(sys_clk, rst, data, data_valid, max_data_size, has_parity_bit, extra_stop_bit, data_out, data_sent, active)
	begin
		if rst = '1' then
			-- Do nothing, main process will do the job
		elsif rising_edge(clk) then
			case uart_mode is
				when URT_Data =>
					-- Does nothing in Tx
				when others =>
					-- Do nothing
			end case;
		end if;
	end process suportProcess;
	
	mainProcess : process(baud_clk, rst, data, data_valid, max_data_size, has_parity_bit, extra_stop_bit, data_out, data_sent, active)
	begin
		if rst = '1' then
		elsif rising_edge(baud_clk) then
			case uart_mode is
				when URT_Idle =>
					active			<= '0';			-- Emit we are not working
					data_out		<= '1'; 		-- Set high to set idle
					counter			<= 0;			-- Number of ticks is 0
					index			<= 0;			-- First bit to send is 0

					-- If data is prepared to be sent
					if data_valid = '1' then
						mode		<= URT_Start;
					end if;

				when URT_Start =>
					active			<= '1';			-- Emit to all that we are working
					data_out		<= '0';			-- Send 0 to emit an start bit
					mode			<= URT_Data;	-- Update mode to send bits next tick (next baud)

				when URT_Data => 
					data_out		<= data(index);	-- Send bit in index position

					-- Check if we have sent out all bits
					if index < max_data_size then
						index	<= index + 1;
						mode	<= URT_Data;
					else
						index	<= 0;
						mode	<= URT_Stop;
					end if;


				

			end case;
		end if;
	end process mainProcess;
end architecture UniversalAsynchonousTransmitterArch;

architecture UniversalAsynchonousTransmitterArch of UniversalAsynchonousTransmitter is
	constant BUS_SIZE_L			: NAT								:= BUS_SIZE			- 1;
	constant TICKS_PER_BIT_L	: NAT								:= TICKS_PER_BIT	- 1;

	signal active_internal		: SL								:= '0';
	signal counter				: NAT range 0 to TICKS_PER_BIT_L	:= 0;
	signal index				: NAT range 0 to BUS_SIZE_L			:= 0;  -- Position of bit to get

begin
	process (clk)
	begin
		if rst = '1' then
			data_sent				<= '0';
			--active Will be setted at the end of this process
			active_internal			<= '0';
			counter					<= 0;
			index					<= 0;
			mode					<= URT_Idle;

		elsif rising_edge(clk) then
			case mode is
				when URT_Idle =>
					active			<= '0';
					data_out		<= '1'; -- Drive Line High for Idle
					active_internal	<= '0';
					counter			<= 0;
					index			<= 0;

					if data_valid = '1' then
						--r_TX_Data		<= i_TX_Byte;
						mode			<= URT_Start;
					else
						mode			<= URT_Idle;
					end if;

				-- Send out Start Bit. Start bit = 0
				when URT_Start =>
					active			<= '1';
					data_out		<= '0';

					-- Wait TICKS_PER_BIT_L clock cycles for start bit to finish
					if counter < TICKS_PER_BIT_L then
						counter		<= counter + 1;
						mode		<= URT_Start;
					else
						counter		<= 0;
						mode		<= URT_Data;
					end if;

				-- Wait TICKS_PER_BIT_L clock cycles for data bits to finish
				when URT_Data =>
					data_out		<= r_TX_Data(index);

					if counter < TICKS_PER_BIT_L then
						counter		<= counter + 1;
						mode		<= URT_Data;
					else
						counter <= 0;

						-- Check if we have sent out all bits
						if index < max_data_size then
							index	<= index + 1;
							mode	<= URT_Data;
						else
							index	<= 0;
							mode	<= URT_Stop;
						end if;
					end if;

				-- Send out Stop bit. Stop bit = 1 
				when URT_Stop =>
					data_out		<= '1';

					-- Wait TICKS_PER_BIT_L clock cycles for Stop bit to finish
					if counter < TICKS_PER_BIT_L then
						counter		<= counter + 1;
						mode		<= URT_Stop;
					else
						active_internal	<= '1';
						counter		<= 0;
						mode		<= URT_Cleanup;
					end if;

				-- Stay here 1 clock 
				when URT_Cleanup =>
					active			<= '0';
					active_internal	<= '1';
					mode			<= URT_Idle;

				when others =>
					mode			<= URT_Idle;

			end case;
		end if;

		active <= active_internal;

	end process;
end architecture UniversalAsynchonousTransmitterArch;
