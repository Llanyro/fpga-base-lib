library ieee;
library llanylib;

use ieee.std_logic_1164.ALL;
use llanylib.LlanySettings.all;

package LlanyUniversalReceiverTransmitterSettings is
	
	type URTMode is (URT_Idle, URT_Start, URT_Data, URT_Parity, URT_Stop, URT_Cleanup);
	constant URTMODE_CONSTANT : URTMode := URT_Idle;

	function tern_uart(condition : SL; true_mode : URTMode; false_mode : URTMode) return SL;
	
end package LlanyUniversalReceiverTransmitterSettings;

package body LlanyUniversalReceiverTransmitterSettings is
	function tern_uart(condition : boolean; true_mode : URTMode; false_mode : URTMode) return SL is
	begin
		if condition then	return true_mode;
		else				return false_mode;
		end if;
	end function tern_uart;

end package body LlanyUniversalReceiverTransmitterSettings;
