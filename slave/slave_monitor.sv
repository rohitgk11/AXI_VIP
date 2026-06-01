class slave_monitor extends uvm_monitor;
	`uvm_component_utils(slave_monitor)
	slave_config cfg;
	virtual intf.SMON vif;
	uvm_analysis_port#(transaction) ap;

	semaphore s1=new(1);
	semaphore s2=new(1);
	semaphore s3=new(1);
	semaphore s4=new(1);
	semaphore s5=new(1);
	semaphore s6=new();
	semaphore s7=new();
	semaphore s8=new();

	transaction q1[$], q2[$], q3[$], q4[$], q5[$];
	transaction tx;

	function new(string name="slave_monitor", uvm_component parent);
		super.new(name,parent);
		ap=new("ap",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			if(!uvm_config_db#(slave_config)::get(this,"","cfg",cfg))
				`uvm_fatal("IN SLAVE MONITOR","Error to get cfg")
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
			vif=cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever
			begin
				tx=transaction::type_id::create("tx");
				send_to_slave();
			end
	endtask

	task send_to_slave();
		fork
			begin
				s1.get(1);
				write_addr();
				s1.put(1);
				s6.put(1);
			end

			begin
				s2.get(1);
				s6.get(1);
				write_data(q1.pop_front());
				s7.put(1);
				s2.put(1);
			end

			begin
				s3.get(1);
				s7.get(1);
				write_res(q2.pop_front());
				s3.put(1);
			end

			begin
				s4.get(1);
				read_addr();
				s4.put(1);
				s8.put(1);
			end

			begin
				s5.get(1);
				s8.get(1);
				read_data(q3.pop_front());
				s5.put(1);
			end
		join_any
		//$display("Slave Monitor");
		//tx.print();
	endtask

	task write_addr();
		wait(vif.smon.awvalid && vif.smon.awready)
		tx.awid=vif.smon.awid;
		tx.awaddr=vif.smon.awaddr;
		tx.awsize=vif.smon.awsize;
		tx.awlen=vif.smon.awlen;
		tx.awburst=vif.smon.awburst;
		tx.awvalid=vif.smon.awvalid;
		tx.awready=vif.smon.awready;
		//tx.print();

		q1.push_back(tx);
		ap.write(tx);
		@(vif.smon);
	endtask


	task write_data(transaction tx);
			tx.wdata = new[tx.awlen + 1];
			tx.wstrb = new[tx.awlen + 1];
		//foreach(vif.smon.wdata[i])
		for(int i=0; i<=tx.awlen; i++)
			begin
				wait(vif.smon.wvalid && vif.smon.wready)
				tx.wid=vif.smon.wid;
				tx.wlast=vif.smon.wlast;
				tx.wvalid=vif.smon.wvalid;
				tx.wready=vif.smon.wready;
				tx.wstrb[i]=vif.smon.wstrb;
				if(tx.wstrb[i] == 4'b0001)
					tx.wdata[i]=vif.smon.wdata[7:0];

				else if(tx.wstrb[i] == 4'b0010)
					tx.wdata[i]=vif.smon.wdata[15:8];

				else if(tx.wstrb[i] == 4'b0100)
					tx.wdata[i]=vif.smon.wdata[23:16];

				else if(tx.wstrb[i] == 4'b1000)
					tx.wdata[i]=vif.smon.wdata[31:24];

				else if(tx.wstrb[i] == 4'b0011)
					tx.wdata[i]=vif.smon.wdata[15:0];

				else if(tx.wstrb[i] == 4'b1100)
					tx.wdata[i]=vif.smon.wdata[31:24];

				else if(tx.wstrb[i] == 4'b1111)
					tx.wdata[i]=vif.smon.wdata[31:0];
				else
					tx.wdata[i]=0;

				q2.push_back(tx);
				ap.write(tx);
				@(vif.smon);	
			end
	endtask


	task write_res(transaction tx);
		wait(vif.smon.bvalid && vif.smon.bready)
		tx.bid=vif.smon.bid;
		tx.bresp=vif.smon.bresp;
		tx.bvalid=vif.smon.bvalid;
		tx.bready=vif.smon.bready;
	
		ap.write(tx);
		@(vif.smon);
	endtask


	task read_addr();
		wait(vif.smon.arvalid && vif.smon.arready)
		tx.arid=vif.smon.arid;
		tx.araddr=vif.smon.araddr;
		tx.arsize=vif.smon.arsize;
		tx.arlen=vif.smon.arlen;
		tx.arburst=vif.smon.arburst;
		tx.arvalid=vif.smon.arvalid;
		tx.arready=vif.smon.arready;

		q3.push_back(tx);
		ap.write(tx);
		@(vif.smon);
	endtask


	task read_data(transaction tx);
		tx.rdata = new[tx.arlen+1];
		tx.rresp = new[tx.arlen+1];
		for(int i=0; i<=(tx.arlen); i++)
			begin
				wait(vif.smon.rvalid && vif.smon.rready)
				tx.rid=vif.smon.rid;
				tx.rdata[i]=vif.smon.rdata;
				tx.rresp[i]=vif.smon.rresp;
				tx.rlast=vif.smon.rlast;
				tx.rvalid=vif.smon.rvalid;
				tx.rready=vif.smon.rready;
				
				ap.write(tx);
				@(vif.smon);
			end
	endtask

endclass 

