#### General Assumptions of these TNEP Models ####
#
#

"""
"""
function solve_tnep(file, model_type::Type, optimizer; kwargs...)
    return solve_model(file, model_type, optimizer, build_tnep;
        ref_extensions = [ref_add_on_off_va_bounds!, ref_add_ne_branch!], kwargs...)
end

"""
the general form of the tnep optimization model
"""
function build_tnep(pm::AbstractPowerModel)
    variable_bus_voltage(pm)
    variable_gen_power(pm)
    variable_branch_power(pm)
    variable_dcline_power(pm)

    variable_ne_branch_indicator(pm)
    variable_ne_branch_power(pm)
    variable_ne_branch_voltage(pm)

    objective_tnep_cost(pm)

    constraint_model_voltage(pm)
    constraint_ne_model_voltage(pm)

    for i in ids(pm, :ref_buses)
        constraint_theta_ref(pm, i)
    end

    for i in ids(pm, :bus)
        constraint_ne_power_balance(pm, i)
    end

    for i in ids(pm, :branch)
        constraint_ohms_yt_from(pm, i)
        constraint_ohms_yt_to(pm, i)

        constraint_voltage_angle_difference(pm, i)

        constraint_thermal_limit_from(pm, i)
        constraint_thermal_limit_to(pm, i)
    end

    for i in ids(pm, :ne_branch)
        constraint_ne_ohms_yt_from(pm, i)
        constraint_ne_ohms_yt_to(pm, i)

        constraint_ne_voltage_angle_difference(pm, i)

        constraint_ne_thermal_limit_from(pm, i)
        constraint_ne_thermal_limit_to(pm, i)
    end

    for i in ids(pm, :dcline)
        constraint_dcline_power_losses(pm, i)
    end
end

"""
Cost of building branches
"""
function objective_tnep_cost(pm::AbstractPowerModel)
    return JuMP.@objective(pm.model, Min,
        sum(
            sum(branch["construction_cost"]*var(pm, n, :branch_ne, i)
            for (i, branch) in nw_ref[:ne_branch])
        for (n, nw_ref) in nws(pm)))
end

"""
"""
function ref_add_ne_branch!(ref::Dict{Symbol, <:Any}, data::Dict{String, <:Any})
    apply_pm!(_ref_add_ne_branch!, ref, data)
end

"""
"""
function _ref_add_ne_branch!(ref::Dict{Symbol, <:Any}, data::Dict{String, <:Any})
    if !haskey(ref, :ne_branch)
        error(_LOGGER, "required ne_branch data not found")
    end

    ref[:ne_branch] = Dict(x
    for x in ref[:ne_branch]
    if (x.second["br_status"] == 1 && x.second["f_bus"] in keys(ref[:bus]) &&
        x.second["t_bus"] in keys(ref[:bus])))

    ref[:ne_arcs_from] = [(i, branch["f_bus"], branch["t_bus"])
                          for (i, branch) in ref[:ne_branch]]
    ref[:ne_arcs_to] = [(i, branch["t_bus"], branch["f_bus"])
                        for (i, branch) in ref[:ne_branch]]
    ref[:ne_arcs] = [ref[:ne_arcs_from]; ref[:ne_arcs_to]]

    ne_bus_arcs = Dict((i, []) for (i, bus) in ref[:bus])
    for (l, i, j) in ref[:ne_arcs]
        push!(ne_bus_arcs[i], (l, i, j))
    end
    ref[:ne_bus_arcs] = ne_bus_arcs

    if !haskey(ref, :ne_buspairs)
        ismc = haskey(ref, :conductors)
        cid = ref[:conductor_ids]
        ref[:ne_buspairs] = calc_buspair_parameters(ref[:bus], ref[:ne_branch], cid, ismc)
    end
end
