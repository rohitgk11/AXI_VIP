class test extends uvm_test;
	`uvm_component_utils(test)

	env envh;
	env_config e_cfg;
	master_config m_cfg;
	slave_config s_cfg;
	//master_sequence seq1;
	//slave_sequence seq2;
	virtual intf vif;

	function new(string name="test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		envh=env::type_id::create("envh",this);
		e_cfg=env_config::type_id::create("e_cfg",this);
		m_cfg=master_config::type_id::create("m_cfg",this);
		s_cfg=slave_config::type_id::create("s_cfg",this);
		//seq1=master_sequence::type_id::create("seq1");
		//seq2=slave_sequence::type_id::create("seq2");

		if(!uvm_config_db#(virtual intf)::get(this, " ", "vif", vif))
			`uvm_fatal("In TEST","Error to get intf")
		m_cfg.vif=vif;
		s_cfg.vif=vif;

		uvm_config_db#(env_config)::set(this,"*","cfg",e_cfg);
		uvm_config_db#(master_config)::set(this,"*","cfg",m_cfg);
		uvm_config_db#(slave_config)::set(this,"*","cfg",s_cfg);

	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
			uvm_top.print_topology();
	endfunction

	/*task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		fork
		seq1.start(envh.m_top.m_agt[0].seqr);
		//seq2.start(envh.s_top.s_agt[0].seqr);
		join
            #10000;
		phase.drop_objection(this);
	endtask*/

endclass

class fixed_test extends test;
	`uvm_component_utils(fixed_test)

	fixed_sequence seq;

	function new(string name="fixed_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq=fixed_sequence::type_id::create("seq");
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		seq.start(envh.m_top.m_agt[0].seqr);
            #10000;
		phase.drop_objection(this);
	endtask

endclass

class increment_test extends test;
	`uvm_component_utils(increment_test)

	increment_sequence seq;

	function new(string name="increment_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq=increment_sequence::type_id::create("seq");
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		seq.start(envh.m_top.m_agt[0].seqr);
            #10000;
		phase.drop_objection(this);
	endtask

endclass

class wrap_test extends test;
	`uvm_component_utils(wrap_test)

	wrap_sequence seq;

	function new(string name="wrap_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq=wrap_sequence::type_id::create("seq");
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		seq.start(envh.m_top.m_agt[0].seqr);
            #10000;
		phase.drop_objection(this);
	endtask

endclass
