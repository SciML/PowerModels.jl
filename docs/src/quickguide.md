# Quick Start Guide

Once PowerModels is installed, Ipopt is installed, and a network data file (e.g. `"case3.m"` or `"case3.raw"`) has been acquired, an AC Optimal Power Flow can be executed with,

```julia
using PowerModels
using Ipopt

solve_ac_opf("matpower/case3.m", Ipopt.Optimizer)
```

Similarly, a DC Optimal Power Flow can be executed with

```julia
solve_dc_opf("matpower/case3.m", Ipopt.Optimizer)
```

PTI `.raw` files in the PSS(R)E v33 specification can be run similarly, e.g. in the case of an AC Optimal Power Flow

```julia
solve_ac_opf("case3.raw", Ipopt.Optimizer)
```

## Getting Results

The run commands in PowerModels return detailed results data in the form of a dictionary. Results dictionaries from either Matpower `.m` or PTI `.raw` files will be identical in format. This dictionary can be saved for further processing as follows,

```julia
result = solve_ac_opf("matpower/case3.m", Ipopt.Optimizer)
```

For example, the algorithm's runtime and final objective value can be accessed with,

```
result["solve_time"]
result["objective"]
```

The `"solution"` field contains detailed information about the solution produced by the run method.
For example, the following dictionary comprehension can be used to inspect the bus voltage angles in the solution,

```
Dict(name => data["va"] for (name, data) in result["solution"]["bus"])
```

The `print_summary(result["solution"])` function can be used show an table-like overview of the solution data.  For more information about PowerModels result data see the [PowerModels Result Data Format](@ref) section.

## Accessing Different Formulations

The function `solve_ac_opf` and `solve_dc_opf` are shorthands for a more general formulation-independent OPF execution, `solve_opf`.
For example, `solve_ac_opf` is equivalent to,

```julia
solve_opf("matpower/case3.m", ACPPowerModel, Ipopt.Optimizer)
```

where "ACPPowerModel" indicates an AC formulation in polar coordinates.  This more generic `solve_opf()` allows one to solve an OPF problem with any power network formulation implemented in PowerModels.  For example, an SOC Optimal Power Flow can be run with,

```julia
solve_opf("matpower/case3.m", SOCWRPowerModel, Ipopt.Optimizer)
```

[Formulation Details](@ref) provides a list of available formulations.

## Modifying Network Data

The following example demonstrates one way to perform multiple PowerModels solves while modifing the network data in Julia,

```julia
network_data = PowerModels.parse_file("matpower/case3.m")

solve_opf(network_data, ACPPowerModel, Ipopt.Optimizer)

network_data["load"]["3"]["pd"] = 0.0
network_data["load"]["3"]["qd"] = 0.0

solve_opf(network_data, ACPPowerModel, Ipopt.Optimizer)
```

Network data parsed from PTI `.raw` files supports data extensions, i.e. data fields that are within the PSS(R)E specification, but not used by PowerModels for calculation. This can be achieved by

```julia
network_data = PowerModels.parse_file("pti/case3.raw"; import_all = true)
```

This network data can be modified in the same way as the previous Matpower `.m` file example. For additional details about the network data, see the [PowerModels Network Data Format](@ref) section.

## Inspecting AC and DC branch flow results

The flow AC and DC branch results are written to the result by default. The following can be used to inspect the flow results:

```julia
result = solve_opf("matpower/case3_dc.m", ACPPowerModel, Ipopt.Optimizer)
result["solution"]["dcline"]["1"]
result["solution"]["branch"]["2"]
```

The losses of an AC or DC branch can be derived:

```julia
loss_ac = Dict(name => data["pt"]+data["pf"]
for (name, data) in result["solution"]["branch"])
loss_dc = Dict(name => data["pt"]+data["pf"]
for (name, data) in result["solution"]["dcline"])
```

## Building PowerModels from Network Data Dictionaries

The following example demonstrates how to break a `solve_opf` call into separate model building and solving steps.  This allows inspection of the JuMP model created by PowerModels for the AC-OPF problem,

```julia
pm = instantiate_model("matpower/case3.m", ACPPowerModel, PowerModels.build_opf)

print(pm.model)

result = optimize_model!(pm, optimizer = Ipopt.Optimizer)
```

Alternatively, you can further break it up by parsing a file into a network data dictionary, before passing it on to `instantiate_model()` like so,

```julia
network_data = PowerModels.parse_file("matpower/case3.m")

pm = instantiate_model(network_data, ACPPowerModel, PowerModels.build_opf)

print(pm.model)

result = optimize_model!(pm, optimizer = Ipopt.Optimizer)
```
