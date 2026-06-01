class slave_agent_top extends uvm_component;
	`uvm_component_utils(slave_agent_top)
	
	slave_agent s_agt[];
	env_config cfg;

	function new(string name="slave_agent_top", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(env_config)::get(this, "", "cfg", cfg))
			`uvm_fatal("IN SLAVE AGENT TOP","Error to get cfg")

		s_agt=new[cfg.no_of_slave];
		foreach(s_agt[i])
			s_agt[i]=slave_agent::type_id::create($sformatf("s_agt[%0d]",i), this);	
	endfunction 
endclass
