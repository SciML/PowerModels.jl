# Variables

We provide the following methods to provide a compositional approach for defining common variables used in power flow models. These methods should always be defined over "AbstractPowerModel".

```@autodocs
Modules = [PowerModels]
Pages   = ["core/variable.jl"]
Order   = [:type, :function]
Private  = true
```

```@docs
variable_branch_current
variable_bus_voltage
variable_gen_current
```
