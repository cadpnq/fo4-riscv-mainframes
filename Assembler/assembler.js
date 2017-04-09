// RVeAs - risk-vee-assembler

// I switched to es6 about half-way through. *So much* of this code could
// be improved with the stuff in es6. When I get around to doing that I will
// also add error handling.

let tokenizer = new RegExp(/;.*\n|"(?:[^\\"]|\\.)*"|[\.'-]?\w+:?/g);


// some values, when present in an instruction, are always in the same place
//                  name, width, start
let inst_fields = [["opcode", 7, 0],
                   ["rsd", 5, 7],
                   ["rs1", 5, 15],
                   ["rs2", 5, 20],
                   ["func3", 3, 12],
                   ["func7", 7, 25]];


// immediate start, instruction start, width
let immediate_fields = {I: [[0, 20, 12]],
                        S: [[0, 7, 5],
                            [5, 25, 7]],
                        B: [[11, 7, 1],
                            [1, 8, 4],
                            [5, 25, 6],
                            [12, 31, 1]],
                        U: [[12, 12, 20]],
                        J: [[12, 12, 8],
                            [11, 20, 1],
                            [1, 21, 10],
                            [20, 31, 1]]};


function default_constants() {
  return combine_objects(register_names("r", 0, 0, 32),
                         register_names("t", 0, 5, 3),
                         register_names("s", 0, 8, 2),
                         register_names("a", 0, 10, 8),
                         register_names("s", 2, 18, 10),
                         register_names("t", 3, 28, 4),
                         {zero: 0,
                          ra: 1,
                          sp: 2,
                          gp: 3,
                          tp: 4,
                          fp: 8});
}

function register_names(character, start, reg_start, number) {
  let ret = {};
  for(let i = 0; i < number; i++) {
    ret[`${character}${start + i}`] = reg_start + i;
  }
  return ret;
}

function number_to_array(val, width = 4) {
  let ret = [];
  for(let i = 0; i < width; i++) {
  
    // this needs pulled apart for readability
    ret.push (((((0xFF << i*8) & val) >> i*8) >>> 0) & 0xFF);
  }
  return ret;
}

function combine_objects() {
  let out = {};
  for(i in arguments) {
    for(key in arguments[i]) {
      out[key] = arguments[i][key];
    }
  }
  return out;
}


function assemble_instruction(args, immediate, immediate_type) {
  let ret;

  for(i in inst_fields) {
    let [name, width, start] = inst_fields[i];
    
    if(args[name]){
      ret |= ((Math.pow(2, width) - 1) & args[name]) << start;
    }
  }
  
  if(immediate) {
    for(i in immediate_fields[immediate_type]) {
      let [immediate_start, instruction_start, width] = immediate_fields[immediate_type][i];
      
      // this also needs to be changed for readability
      ret |= ((((((Math.pow(2, width) - 1) << immediate_start) >>> 0) & immediate) >>> 0) 
                >> immediate_start) << instruction_start;
    }
  }
  
  return ret;
}

function r_type(opcode, func3, func7) {
  return function(rsd, rs1, rs2) {
    return assemble_instruction({opcode, rsd, rs1, rs2, func3, func7});
  }
}

function i_type(opcode, func3) {
  return function(rsd, rs1, imm) {
    return assemble_instruction({opcode, rsd, rs1, func3}, imm, "I");
  }
}

function s_type(opcode, func3) {
  return function(rs1, rs2, imm) {
    return assemble_instruction({opcode, rs1, rs2, func3}, imm, "S");
  }
}

function b_type(opcode, func3) {
  return function(rs1, rs2, imm) {
    return assemble_instruction({opcode, rs1, rs2, func3}, imm, "B");
  }
}

function u_type(opcode) {
  return function(rsd, imm) {
    return assemble_instruction({opcode, rsd}, imm, "U");
  }
}

function j_type(opcode) {
  return function(rsd, imm) {
    return assemble_instruction({opcode, rsd}, imm, "J");
  }
}

class AssemblerObject {
  constructor(location, length, save = true) {
    this.location = location;
    this.save = save;
    this._length = length;
    this.arguments = [];
  }

  get_arguments(tokens) {
    for(let i = 0; i < this.arity(); i++) {
      this.arguments.push(tokens.shift());
    }
    console.log("# " + this.arguments.join(", "));
  }
  
  process_arguments() {
    //console.log(this.arguments);
    for(let i in this.arguments) {
      let arg = this.arguments[i];
      if(constants[arg] != null) {
        arg = constants[arg];
      } else if (!isNaN(parseInt(arg))) {
        arg = parseInt(arg)
        
      // in some instances we want the address of a label and in others
      // we want the offset from the current address to it. this could be
      // handled better, but for now all labels referenced with a ' before
      // the name are treated as the address and all bare labels are the
      // offset.
      // additionally, multi-byte pseudoinstruction expansions that 
      // contain labels treated as offsets need attention. this is not
      // currently implemented.
      } else if (labels[arg.replace("'","")] != undefined) {
        if (arg.charAt(0) == "'") {
          arg = labels[arg.replace("'","")];
        } else {
          arg = labels[arg] - this.location;
        }
      } else {
        arg = eval(arg);
      }
      this.arguments[i] = arg;
    }
  }
  
  get_bytes() {
    return [];
  }

  length() {
    return this._length;
  }
  
  arity() {
    return 0;
  }
}

function Instruction(encode_function) {
  return class extends AssemblerObject {
    constructor(location) {
      super(location, 4);
    }
    
    get_bytes() {
      return number_to_array(encode_function(...this.arguments));
    }
    
    arity() {
      return encode_function.length;
    }
  }
}

class ByteDirective extends AssemblerObject {
  constructor(location) {
    super(location, 1);
  }
  
  get_bytes() {
    this.process_arguments();
    return [this.arguments[0] & 0xFF];
  }

  arity() {
    return 1;
  }
}

class ConstantDirective extends AssemblerObject {
  constructor(location) {
    super(location, 0);
  }
  
  process_arguments() {
    let name = this.arguments.shift();
    super.process_arguments();
    constants[name] = this.arguments[0];
  }

  arity() {
    return 2;
  }
}

class EphemeralObject extends AssemblerObject{
  constructor(location) {
    super(location, 0, false);
  }
}

function PseudoInstruction(arity, expansion) {
  return class extends EphemeralObject {
    get_arguments(tokens) {
      super.get_arguments(tokens);
      console.log("#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
      // push our expansion onto the token stream
      for(let i = expansion.length - 1; i >= 0; i--) {
        if(typeof(expansion[i]) == "string") {
          tokens.unshift(expansion[i]);
        } else {
          tokens.unshift(this.arguments[expansion[i]]);
        }
      }
    }
    
    arity() {
      return arity;
    }
  }
}

function PseudoDirective(arity, expansion_function) {
  return class extends EphemeralObject {
    get_arguments(tokens) {
      super.get_arguments(tokens);
      this.process_arguments();
      let expansion = expansion_function(this.arguments);
      for(let i = expansion.length - 1; i >= 0; i--) {
        tokens.unshift(expansion[i]);
      }
    }
    
    arity() {
      return arity;
    }
  }
}

function half_directive(args) {
  let a = args[0];
  return [".byte", a & 0xff,
          ".byte", (a >> 8) & 0xff];
}

function word_directive(args) {
  let a = args[0];
  return [".half", a & 0xffff,
          ".half", (a >> 16) & 0xffff];
}

// clean up later
function stringu_directive(args) {
  return args[0].split('').map(x=>".byte " + x.charCodeAt(0)).join(" ").split(" ");
}

function string_directive(args) {
  return [".stringu", '"' + args[0] + '"', ".byte", "0"];
}

// name, arity, expansion
let pseudoinstruction_table = 
 [//["la", 2,  ["auipc", 0, 1, "addi", 0, 0, 1]],
//  ["lgb", 2, ["auipc", 0, 1, "lb", 0, 1]],
//  ["lgh", 2, ["auipc", 0, 1, "lh", 0, 1]],
//  ["lgw", 2, ["auipc", 0, 1, "lw", 0, 1]],
//  ["sgb", 3, ["auipc", 2, 1, "sb", 0, 2, 1]],
//  ["sgh", 3, ["auipc", 2, 1, "sh", 0, 2, 1]],
//  ["sgw", 3, ["auipc", 2, 1, "sw", 0, 2, 1]],
  ["nop", 0, ["addi", "r0", "r0", "0"]],
  ["li", 2,  ["lui", 0, 1, "ori", 0, 0, 1]],
  ["mv", 2,  ["addi", 0, 1, "0"]],
  ["not", 2, ["xori", 0, 1, "-1"]],
  ["neg", 2, ["sub", 0, "r0", 1]],
  ["seqz", 2, ["sltiu", 0, 1, "1"]],
  ["snez", 2, ["sltu", 0, "r0", 1]],
  ["sltz", 2, ["slt", 0, 1, "r0"]],
  ["sgtz", 2, ["slt", 0, "r0", 1]],
  ["beqz", 2, ["beq", 0, "r0", 1]],
  ["bnez", 2, ["bne", 0, "r0", 1]],
  ["blez", 2, ["bge", "r0", 0, 1]],
  ["bgez", 2, ["bge", 0, "r0", 1]],
  ["bltz", 2, ["blt", 0, "r0", 1]],
  ["bgtz", 2, ["blt", "r0", 0, 1]],
  ["j", 1, ["jal", "r0", 0]],
  ["jr", 1, ["jalr", "r0", 0, "0"]],
  ["ret", 0, ["jalr", "r0", "r1", "0"]]
//  ["call", 1, ["auipc", "r6", 0, "jalr", "r1", "r6", 0]]
];

// name, assemble function
let instruction_table = 
[["lui", u_type(55)],
 ["auipc", u_type(23)],
 ["jal", j_type(111)],
 ["jalr", i_type(103, 0)],
 ["beq", b_type(99, 0)],
 ["bne", b_type(99, 1)],
 ["blt", b_type(99, 4)],
 ["bge", b_type(99, 5)],
 ["bltu", b_type(99, 6)],
 ["bgeu", b_type(99, 7)],
 ["lb", i_type(3, 0)],
 ["lh", i_type(3, 1)],
 ["lw", i_type(3, 2)],
 ["lbu", i_type(3, 4)],
 ["lhu", i_type(3, 5)],
 ["sb", s_type(35, 0)],
 ["sh", s_type(35, 1)],
 ["sw", s_type(35, 2)],
 ["addi", i_type(19, 0)],
 ["slti", i_type(19, 2)],
 ["sltiu", i_type(19, 3)],
 ["xori", i_type(19, 4)],
 ["ori", i_type(19, 6)],
 ["andi", i_type(19, 7)],
// Note that the shift immediate instructions are actually encoded as a special
// I-type instruction where the bottom 5 bits of the immediate are the shift 
// amount and the rest describe the type of shift operation. This lines up with
// an R-type instruction so, for simplicity, I defined them as such.
 ["slli", r_type(19, 1, 0)],
 ["srli", r_type(19, 5, 0)],
 ["srai", r_type(19, 5, 32)],
 ["add", r_type(51, 0, 0)],
 ["sub", r_type(51, 0, 32)],
 ["sll", r_type(51, 1, 0)],
 ["slt", r_type(51, 2, 0)],
 ["sltu", r_type(51, 3, 0)],
 ["xor", r_type(51, 4, 0)],
 ["srl", r_type(51, 5, 0)],
 ["sra", r_type(51, 5, 32)],
 ["or", r_type(51, 6, 0)],
 ["and", r_type(51, 7, 0)]];

// name, arity, expansion_function
let directive_table = 
[[".half", 1, half_directive],
 [".word", 1, word_directive],
 [".stringu", 1, stringu_directive],
 [".string", 1, string_directive]];

function make_pseudoinstructions(l) {
  let out = {};
  for(i in l) {
    let [name, arity, expansion] = l[i];
    out[name] = PseudoInstruction(arity, expansion);
  }
  return out;
}

function make_instructions(l) {
  let out = {};
  for(let i in l) {
    let [name, assemble_function] = l[i];
    out[name] = Instruction(assemble_function);
  }
  return out;
}

function make_directives(l) {
  let out = {".byte": ByteDirective,
             ".constant": ConstantDirective};
  for(let i in l) {
    let [name, arity, expansion_function] = l[i];
    out[name] = PseudoDirective(arity, expansion_function);
  }
  return out;
}

let labels = {};
let constants = default_constants();

let operations = combine_objects(make_pseudoinstructions(pseudoinstruction_table),
                                 make_instructions(instruction_table),
                                 make_directives(directive_table));


//console.log(labels);

function assemble_string_to_bytes(s) {
	let output_objects = [];
	let output_bytes = [];
	
	let tokens = s.match(tokenizer);

	let memory_address = 0;

	while(tokens.length) {
	  let token = tokens.shift();
	  if(token.charAt(0) == ";") continue;
	  if(/\w*:/.test(token)) {
//		console.log("######### " + token);
		labels[token.replace(":", "")] = memory_address;
	  } else {
//		console.log("#" + token);
		let op = new operations[token.toLowerCase()](memory_address);
		op.get_arguments(tokens);
		memory_address += op.length();
		if(op.save) {
		  output_objects.push(op);
		}
	  }
	}
	
	for(let i in output_objects) {
	  let obj = output_objects[i];
	  obj.process_arguments();
//	  console.log("# " + obj.arguments);
	  
	  let bytes = obj.get_bytes()
	  for(let i = 0; i < bytes.length; i++) {
		output_bytes[obj.location + i] = bytes[i];
	  }
	}
	
	return output_bytes;
}