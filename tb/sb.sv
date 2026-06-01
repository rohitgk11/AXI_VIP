class sb extends uvm_scoreboard;
	`uvm_component_utils(sb)
	uvm_tlm_analysis_fifo#(transaction) fifo1;
	uvm_tlm_analysis_fifo#(transaction) fifo2;
	transaction wtx, rtx;
	transaction tx1, tx2;

	bit [31:0]write_data;
	bit [3:0]write_strb;
	bit [31:0]read_data;
	bit [1:0]read_resp;

	covergroup master_covergroup;
		option.per_instance = 1;

		AWADDR : coverpoint tx1.awaddr {
						bins low_awaddr = {[32'h0000_0000:32'h3fff_ffff]};
						bins high_awaddr = {[32'h4000_0000:32'hffff_ffff]};
						} 

		AWSIZE : coverpoint tx1.awsize { bins awsize = {0,1,2};}

		AWLEN : coverpoint tx1.awlen {
						bins low_awlen = {[0:7]};
						bins high_awlen = {[8:15]};
						} 

		AWBURST : coverpoint tx1.awburst { bins awburst = {0,1,2};}
	
		WDATA : coverpoint write_data {
						bins wdata_low = {[32'h0000_0000:32'h00ff_ffff]};
						bins wdata_medium = {[32'h0100_0000:32'h01ff_ffff]};
						bins wdata_high = {[32'h0200_0000:32'h02ff_ffff]};
						bins wdata_full = {[32'h0300_0000:32'h03ff_ffff]};
						}

		/*WDATA : coverpoint write_data {
						bins wdata_low = {[8'h0000_0000:8'h00ff_ffff]};
						bins wdata_medium = {[8'h0100_0000:8'h01ff_ffff]};
						bins wdata_high = {[8'h0200_0000:8'h02ff_ffff]};
						bins wdata_full = {[8'h0300_0000:8'h03ff_ffff]};
						}*/

		WSTRB : coverpoint write_strb {
						bins read_resp = {1,2,4,8,3,12,15};
						}
	endgroup


	covergroup slave_covergroup;
		option.per_instance = 1;

		ARADDR : coverpoint tx2.araddr {
						bins low_araddr = {[32'h0000_0000:32'h3fff_ffff]};
						bins high_araddr = {[32'h4000_0000:32'hffff_ffff]};
						} 

		ARSIZE : coverpoint tx2.arsize { bins arsize = {0,1,2};}

		ARLEN : coverpoint tx2.arlen {
						bins low_arlen = {[0:7]};
						bins high_arlen = {[8:15]};
						} 

		ARBURST : coverpoint tx2.arburst { bins arburst = {0,1,2};}

		RRESP : coverpoint read_resp { bins read_resp = {0};}
	
		RDATA : coverpoint read_data {
						bins rdata_low = {[32'h0000_0000:32'h00ff_ffff]};
						bins rdata_medium = {[32'h0100_0000:32'h01ff_ffff]};
						bins rdata_high = {[32'h0200_0000:32'h02ff_ffff]};
						bins rdata_full = {[32'h0300_0000:32'h03ff_ffff]};
						}

		/*RDATA : coverpoint read_data {
						bins rdata_low = {[8'h0000_0000:8'h00ff_ffff]};
						bins rdata_medium = {[8'h0100_0000:8'h01ff_ffff]};
						bins rdata_high = {[8'h0200_0000:8'h02ff_ffff]};
						bins rdata_full = {[8'h0300_0000:8'h03ff_ffff]};
						}*/
	endgroup

	function new(string name="sb", uvm_component parent);
		super.new(name, parent);
		fifo1=new("fifo1",this);
		fifo2=new("fifo2",this);
		master_covergroup=new();
		slave_covergroup=new();
	endfunction

	task run_phase(uvm_phase phase);
	super.run_phase(phase);
		forever
			begin
				fifo1.get(wtx);
				fifo2.get(rtx);

				//$display("Write Scoreborad");
				//wtx.print();
	
				//$display("Read Scoreborad");
				//rtx.print();

				tx1 =new wtx;
				tx2 =new rtx;

				foreach(wtx.wdata[i])
				begin
					write_data=tx1.wdata[i];
					write_strb=tx1.wstrb[i];
					master_covergroup.sample();
				end

				foreach(wtx.rdata[i])
				begin
					read_resp=tx2.rresp[i];
					read_data=tx2.wdata[i];
					slave_covergroup.sample();
				end

				if(!wtx.compare(rtx))
					`uvm_fatal("In SCOREBOARD","Compare fail!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")	
				else
					$display("*******************Compare PASS*******************");
			end
	
	endtask

endclass
