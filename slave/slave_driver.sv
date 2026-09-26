class slave_driver extends uvm_driver#(transaction);
	`uvm_component_utils(slave_driver)
	slave_config cfg;
	virtual intf.SDRV vif;

	semaphore s1=new(1);
	semaphore s2=new(1);
	semaphore s3=new(1);
	semaphore s4=new(1);
	semaphore s5=new(1);
	semaphore s6=new();
	semaphore s7=new();
	semaphore s8=new();

	transaction q1[$], q2[$], q3[$], q4[$], q5[$]; 
	transaction tx, tx1;

	function new(string name="slave_driver", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			if(!uvm_config_db#(slave_config)::get(this,"","cfg",cfg))
				`uvm_fatal("IN SLAVE DRIVER","Error to get cfg")
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
			vif=cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever
			begin
				req=transaction::type_id::create("req");
				
				q1.push_back(req);
				q2.push_back(req);
				q3.push_back(req);
				q4.push_back(req);
				//q5.push_back(req);
				send_to_slave();
				
				//$display("From Slave Driver");
				//req.print();
			end
	endtask

	task send_to_slave();
		fork
			begin
				s1.get(1);
				write_addr(q1.pop_front());
				s1.put(1);
				s6.put(1);
			end

			begin
				s2.get(1);
				s6.get(1);
				write_data(q2.pop_front());
				s7.put(1);
				s2.put(1);
			end

			begin
				s3.get(1);
				s7.get(1);
				write_res(q3.pop_front());
				s3.put(1);
			end

			begin
				s4.get(1);
				read_addr(q4.pop_front());
				s4.put(1);
				s8.put(1);
			end

			begin
				s5.get(1);
				s8.get(1);
				tx1=transaction::type_id::create("tx1");
				assert( tx1.randomize() with {rid==tx.rid; arlen==tx.arlen;});
				q5.push_back(tx1);
				read_data(q5.pop_front());
				s5.put(1);
			end
		join_any
		//$display("From Slave Driver");
		//req.print();
	endtask


	task write_addr(transaction req);
		vif.sdrv.awready<=1'b1;
		@(vif.sdrv);
		wait(vif.sdrv.awvalid)
		vif.sdrv.awready<=1'b0;
		req.awlen=vif.sdrv.awlen;
		//req.awlen=vif.mdrv.awlen;
		//wait(!vif.sdrv.awvalid);
		//vif.sdrv.awready<=1'b1;

		repeat($urandom_range(1,5))
			@(vif.sdrv);
	endtask


	task write_data(transaction req);
		for(int i=0; i<=(req.awlen); i++)
			begin
				vif.sdrv.wready<=1'b1;
				@(vif.sdrv);
				wait(vif.sdrv.wvalid)
				vif.sdrv.wready<=1'b0;
				//wait(!vif.sdrv.awvalid)
				//vif.sdrv.awready<=1'b0;	
				repeat($urandom_range(1,5))
					@(vif.sdrv);		
			end
	endtask


	task write_res(transaction req);
		//for(int i=0; i<=(req.arlen); i++)
			//begin
				vif.sdrv.bid<=req.bid;
				vif.sdrv.bvalid<=1'b1;
				vif.sdrv.bresp<=2'b00;
				@(vif.sdrv);
				wait(vif.sdrv.bready)
				vif.sdrv.bvalid<=1'b0;

				repeat($urandom_range(1,5))
					@(vif.sdrv);						
	endtask


	task read_addr(transaction req);
		vif.sdrv.arready<=1'b1;
		@(vif.sdrv);
		wait(vif.sdrv.arvalid)
		vif.sdrv.arready<=1'b0;
		//wait(!vif.sdrv.arvalid)
		//vif.sdrv.arready<=1'b1;
		tx=transaction::type_id::create("tx");
		tx.arlen = vif.sdrv.arlen;
		tx.rid = vif.sdrv.rid;
		repeat($urandom_range(1,5))
			@(vif.sdrv);
	endtask


	task read_data(transaction req);
		for(int i=0; i<=(req.arlen); i++)
			begin
				vif.sdrv.rvalid<=1;
				vif.sdrv.rid<=req.rid;
				vif.sdrv.rdata<=req.rdata[i];
				//$display("RDATA[%0d]=%h",i,req.rdata[i]);
				vif.sdrv.rresp<=2'b00;
				if(i==req.arlen)
					vif.sdrv.rlast<=1'b1;
				else
					vif.sdrv.rlast<=1'b0;
				@(vif.sdrv);
				wait(vif.sdrv.rready)
				vif.sdrv.rvalid<=1'b0;
				//vif.sdrv.rlast<=1'b0;

				repeat($urandom_range(1,5))
					@(vif.sdrv);
			end
	endtask


endclass
