module top;

	import pkg::*;
	import uvm_pkg::*;
	`include "uvm_macros.svh";

	bit clk;
	intf vif(clk);

	always #5 clk=~clk;
	
	initial
		begin
			
			uvm_config_db#(virtual intf)::set(null, "*", "vif", vif);

			`ifdef VCS
         		$fsdbDumpvars(0, top);
        		`endif

			clk=1'b0;
			run_test();

			
		end
endmodule
