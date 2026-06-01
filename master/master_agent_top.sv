class master_agent_top extends uvm_component;
	`uvm_component_utils(master_agent_top)
	
	master_agent m_agt[];
	env_config cfg;

	function new(string name="master_agent_top", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(env_config)::get(this, "", "cfg", cfg))
			`uvm_fatal("IN MASTER AGENT TOP","Error to get cfg")

		m_agt=new[cfg.no_of_master];
		foreach(m_agt[i])
			m_agt[i]=master_agent::type_id::create($sformatf("m_agt[%0d]",i), this);	
	endfunction 
endclass
