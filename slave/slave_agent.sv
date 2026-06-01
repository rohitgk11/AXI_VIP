class slave_agent extends uvm_agent;
	`uvm_component_utils(slave_agent)
	slave_driver drv;
	slave_monitor mon;
	slave_sequencer seqr;
	slave_config cfg;
	
	function new(string name="slave_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(slave_config)::get(this,"","cfg",cfg))
			`uvm_fatal("IN SLAVE AGENT","Error to get cfg")

		mon=slave_monitor::type_id::create("mon",this);
		if(cfg.is_active)
			begin
			seqr=slave_sequencer::type_id::create("seqr",this);
			drv=slave_driver::type_id::create("drv",this);
			end
	endfunction

	function void connect_phase(uvm_phase phase);
		if(cfg.is_active)
			drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction
endclass
