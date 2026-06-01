class master_driver extends uvm_driver#(transaction);
	`uvm_component_utils(master_driver)
	master_config cfg;
	virtual intf.MDRV vif;

	semaphore s1=new(1);
	semaphore s2=new(1);
	semaphore s3=new(1);
	semaphore s4=new(1);
	semaphore s5=new(1);
	semaphore s6=new();
	semaphore s7=new();
	semaphore s8=new();

	transaction q1[$], q2[$], q3[$], q4[$], q5[$]; 

	function new(string name="master_driver", uvm_component parent);
		super.new(name,parent);
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
				seq_item_port.get_next_item(req);
				//$display("FROM MASTER DRIVER, AWID=%0d,AWADDR=%0d,AWLEN=%0d,AWSIZE=%0d,AWBURST=%0d",req.awid,req.awaddr,req.awlen,req.awsize,req.awburst);
				//$display("FROM MASTER DRIVER, ARID=%0d,ARADDR=%0d,ARLEN=%0d,ARSIZE=%0d,ARBURST=%0d",req.arid,req.araddr,req.arlen,req.arsize,req.arburst);
				q1.push_back(req);
				q2.push_back(req);
				q3.push_back(req);
				q4.push_back(req);
				q5.push_back(req);
				send_to_slave();
				seq_item_port.item_done();
				//$display("Master Driver");
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
				read_data(q5.pop_front());
				s5.put(1);
			end
		join_any
	endtask


	task write_addr(transaction req);
		//$display("Master:- Write Addr Start");
		vif.mdrv.awvalid<=1'b1;
		vif.mdrv.awid<=req.awid;
		vif.mdrv.awaddr<=req.awaddr;
		vif.mdrv.awsize<=req.awsize;
		vif.mdrv.awlen<=req.awlen;
		vif.mdrv.awburst<=req.awburst;
		@(vif.mdrv);
		wait(vif.mdrv.awready);
			vif.mdrv.awvalid<=1'b0;

		repeat($urandom_range(1,5))
			@(vif.mdrv);
		//$display("Master:- Write Addr End");
	endtask

	task write_data(transaction req);
		//$display("Master:- Write Data Start");
		//@(vif.mdrv);
		//for(int i=0; i<(req.awlen+1); i++)
		foreach(req.wdata[i])
			begin
				vif.mdrv.wvalid<=1'b1;
				vif.mdrv.wid<=req.wid;
				vif.mdrv.wdata<=req.wdata[i];
				vif.mdrv.wstrb<=req.wstrb[i];
				if(i==(req.awlen))
					vif.mdrv.wlast<=1'b1;
				else
					vif.mdrv.wlast<=1'b0;
				@(vif.mdrv);
				wait(vif.mdrv.wready)
					vif.mdrv.wvalid<=1'b0;
				repeat($urandom_range(1,5))
				@(vif.mdrv);
			end
		//$display("Master:- Write Data End");
	endtask

	task write_res(transaction req);
		//$display("Master:- Write Resp Start");
		//foreach(req.wdata[i])
			//begin
				vif.mdrv.bready<=1'b1;
				wait(vif.mdrv.bvalid)
				vif.mdrv.bready<=1'b0;
			//end
			repeat($urandom_range(1,5))
				@(vif.mdrv);
		//$display("Master:- Write Resp End");
	endtask

	task read_addr(transaction req);
		//$display("Master:- Read Addr Start");
		vif.mdrv.arvalid<=1'b1;
		vif.mdrv.arid<=req.arid;
		vif.mdrv.araddr<=req.araddr;
		vif.mdrv.arsize<=req.arsize;
		vif.mdrv.arlen<=req.arlen;
		vif.mdrv.arburst<=req.arburst;
		@(vif.mdrv);
		wait(vif.mdrv.arready);
			vif.mdrv.arvalid<=1'b0;

		repeat($urandom_range(1,5))
			@(vif.mdrv);
		//$display("Master:- Read Addr End");
	endtask

	task read_data(transaction req);
		//$display("Master:- Read Data Start");
		for(int i=0; i<=(req.arlen); i++)
			begin
				vif.mdrv.rready<=1'b1;
				@(vif.mdrv);
				wait(vif.mdrv.rvalid)
					vif.mdrv.rready<=1'b0;
				repeat($urandom_range(1,5))
				@(vif.mdrv);
			end
		//$display("Master:- Read Data End");
	endtask


endclass










