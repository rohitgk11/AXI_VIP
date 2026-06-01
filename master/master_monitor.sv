class master_monitor extends uvm_monitor;
	`uvm_component_utils(master_monitor)
	master_config cfg;
	virtual intf.MMON vif;
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

	function new(string name="master_monitor", uvm_component parent);
		super.new(name,parent);
		ap=new("ap",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			if(!uvm_config_db#(master_config)::get(this,"","cfg",cfg))
				`uvm_fatal("IN MASTER DRIVER","Error to get cfg")
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
		//$display("Master Monitor");
		//tx.print();
	endtask

	task write_addr();
		wait(vif.mmon.awvalid && vif.mmon.awready)
		tx.awid=vif.mmon.awid;
		tx.awaddr=vif.mmon.awaddr;
		tx.awsize=vif.mmon.awsize;
		tx.awlen=vif.mmon.awlen;
		tx.awburst=vif.mmon.awburst;
		tx.awvalid=vif.mmon.awvalid;
		tx.awready=vif.mmon.awready;
		//tx.print();

		q1.push_back(tx);
		ap.write(tx);
		@(vif.mmon);
	endtask


	task write_data(transaction tx);
			tx.wdata = new[tx.awlen + 1];
			tx.wstrb = new[tx.awlen + 1];
		//foreach(vif.mmon.wdata[i])
		for(int i=0; i<=tx.awlen; i++)
			begin
				wait(vif.mmon.wvalid && vif.mmon.wready)
				tx.wid=vif.mmon.wid;
				tx.wlast=vif.mmon.wlast;
				tx.wvalid=vif.mmon.wvalid;
				tx.wready=vif.mmon.wready;
				tx.wstrb[i]=vif.mmon.wstrb;
				if(tx.wstrb[i] == 4'b0001)
					tx.wdata[i]=vif.mmon.wdata[7:0];

				else if(tx.wstrb[i] == 4'b0010)
					tx.wdata[i]=vif.mmon.wdata[15:8];

				else if(tx.wstrb[i] == 4'b0100)
					tx.wdata[i]=vif.mmon.wdata[23:16];

				else if(tx.wstrb[i] == 4'b1000)
					tx.wdata[i]=vif.mmon.wdata[31:24];

				else if(tx.wstrb[i] == 4'b0011)
					tx.wdata[i]=vif.mmon.wdata[15:0];

				else if(tx.wstrb[i] == 4'b1100)
					tx.wdata[i]=vif.mmon.wdata[31:24];

				else if(tx.wstrb[i] == 4'b1111)
					tx.wdata[i]=vif.mmon.wdata[31:0];
				else
					tx.wdata[i]=0;

				q2.push_back(tx);
				ap.write(tx);
				@(vif.mmon);	
			end

			
	endtask


	task write_res(transaction tx);
		wait(vif.mmon.bvalid && vif.mmon.bready)
		tx.bid=vif.mmon.bid;
		tx.bresp=vif.mmon.bresp;
		tx.bvalid=vif.mmon.bvalid;
		tx.bready=vif.mmon.bready;

		ap.write(tx);
		@(vif.mmon);
	endtask


	task read_addr();
		wait(vif.mmon.arvalid && vif.mmon.arready)
		tx.arid=vif.mmon.arid;
		tx.araddr=vif.mmon.araddr;
		tx.arsize=vif.mmon.arsize;
		tx.arlen=vif.mmon.arlen;
		tx.arburst=vif.mmon.arburst;
		tx.arvalid=vif.mmon.arvalid;
		tx.arready=vif.mmon.arready;

		q3.push_back(tx);
		ap.write(tx);
		@(vif.mmon);
	endtask


	task read_data(transaction tx);
		tx.rdata = new[tx.arlen+1];
		tx.rresp = new[tx.arlen+1];
		for(int i=0; i<=(tx.arlen); i++)
			begin
				wait(vif.mmon.rvalid && vif.mmon.rready)
				tx.rid=vif.mmon.rid;
				tx.rdata[i]=vif.mmon.rdata;
				tx.rresp[i]=vif.mmon.rresp;
				tx.rlast=vif.mmon.rlast;
				tx.rvalid=vif.mmon.rvalid;
				tx.rready=vif.mmon.rready;

				ap.write(tx);
				@(vif.mmon);
			end
	endtask

endclass 
