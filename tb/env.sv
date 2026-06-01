class env extends uvm_env;
	`uvm_component_utils(env)

	master_agent_top m_top;
	slave_agent_top s_top;
	sb sbh;

	function new(string name="env", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_top=master_agent_top::type_id::create("m_top",this);
		s_top=slave_agent_top::type_id::create("s_top",this);
		sbh=sb::type_id::create("sbh",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		m_top.m_agt[0].mon.ap.connect(sbh.fifo1.analysis_export);
		s_top.s_agt[0].mon.ap.connect(sbh.fifo2.analysis_export);
	endfunction
endclass

