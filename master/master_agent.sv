class master_agent extends uvm_agent;
	`uvm_component_utils(master_agent)
	master_driver drv;
	master_monitor mon;
	master_sequencer seqr;
	master_config cfg;
	
	function new(string name="master_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(master_config)::get(this,"","cfg",cfg))
			`uvm_fatal("IN MASTER AGENT","Error to get cfg")

		mon=master_monitor::type_id::create("mon",this);
		if(cfg.is_active)
			begin
			seqr=master_sequencer::type_id::create("seqr",this);
			drv=master_driver::type_id::create("drv",this);
			end
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
			if(cfg.is_active)
				drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction
endclass
