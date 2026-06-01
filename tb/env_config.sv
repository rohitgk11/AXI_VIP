class env_config extends uvm_object;
	`uvm_object_utils(env_config)
	
	int no_of_master=1;
	int no_of_slave=1;
	//virtual intf vif;

	function new(string name="env_config");
		super.new(name);
	endfunction
endclass
