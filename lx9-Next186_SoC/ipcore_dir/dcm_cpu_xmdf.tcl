# The package naming convention is <core_name>_xmdf
package provide dcm_cpu_xmdf 1.0

# This includes some utilities that support common XMDF operations
package require utilities_xmdf

# Define a namespace for this package. The name of the name space
# is <core_name>_xmdf
namespace eval ::dcm_cpu_xmdf {
# Use this to define any statics
}

# Function called by client to rebuild the params and port arrays
# Optional when the use context does not require the param or ports
# arrays to be available.
proc ::dcm_cpu_xmdf::xmdfInit { instance } {
# Variable containg name of library into which module is compiled
# Recommendation: <module_name>
# Required
utilities_xmdf::xmdfSetData $instance Module Attributes Name dcm_cpu
}
# ::dcm_cpu_xmdf::xmdfInit

# Function called by client to fill in all the xmdf* data variables
# based on the current settings of the parameters
proc ::dcm_cpu_xmdf::xmdfApplyParams { instance } {

set fcount 0
# Array containing libraries that are assumed to exist
# Examples include unisim and xilinxcorelib
# Optional
# In this example, we assume that the unisim library will
# be magically
# available to the simulation and synthesis tool
utilities_xmdf::xmdfSetData $instance FileSet $fcount type logical_library
utilities_xmdf::xmdfSetData $instance FileSet $fcount logical_library unisim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/clk_wiz_readme.txt
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/doc/clk_wiz_ds709.pdf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/doc/clk_wiz_gsg521.pdf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/implement/implement.bat
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/implement/implement.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/implement/xst.prj
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/implement/xst.scr
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/simulation/dcm_cpu_tb.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/simulation/functional/simcmds.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/simulation/functional/simulate_isim.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/simulation/functional/simulate_mti.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/simulation/functional/simulate_ncsim.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/simulation/functional/simulate_vcs.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/simulation/functional/ucli_commands.key
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/simulation/functional/vcs_session.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/simulation/functional/wave.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu/simulation/functional/wave.sv
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu.asy
utilities_xmdf::xmdfSetData $instance FileSet $fcount type asy
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu.ejp
utilities_xmdf::xmdfSetData $instance FileSet $fcount type AnyView
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ucf
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu.veo
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog_template
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu.xco
utilities_xmdf::xmdfSetData $instance FileSet $fcount type coregen_ip
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path dcm_cpu_xmdf.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type AnyView
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount associated_module dcm_cpu
incr fcount

}

# ::gen_comp_name_xmdf::xmdfApplyParams
