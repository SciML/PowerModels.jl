
TESTLOG = Memento.getlogger(PowerModels)

@testset "test ptdf-based dc opf" begin
    @testset "5-bus case, LP solver" begin
        data = PowerModels.parse_file("../test/data/matpower/case5.m")
        result_va = PowerModels.run_opf(data, DCPPowerModel, milp_solver)
        result_pg = PowerModels.run_opf_ptdf(data, DCPPowerModel, milp_solver)

        @test result_va["termination_status"] == OPTIMAL
        @test result_pg["termination_status"] == OPTIMAL
        @test isapprox(result_va["objective"], result_pg["objective"])
        for (i, gen) in data["gen"]
            @test isapprox(result_va["solution"]["gen"][i]["pg"],
                result_pg["solution"]["gen"][i]["pg"]; atol = 1e-8)
        end
    end
    @testset "5-bus gap case" begin
        data = PowerModels.parse_file("../test/data/matpower/case5_gap.m")
        result_va = PowerModels.run_opf(data, DCPPowerModel, nlp_solver)
        result_pg = PowerModels.run_opf_ptdf(data, DCPPowerModel, nlp_solver)

        @test result_va["termination_status"] == LOCALLY_SOLVED
        @test result_pg["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result_va["objective"], result_pg["objective"])
        for (i, gen) in data["gen"]
            @test isapprox(result_va["solution"]["gen"][i]["pg"],
                result_pg["solution"]["gen"][i]["pg"]; atol = 1e-8)
        end
    end
    @testset "5-bus with pwl costs" begin
        data = PowerModels.parse_file("../test/data/matpower/case5_pwlc.m")
        data["dcline"] = Dict()
        result_va = PowerModels.run_opf(data, DCPPowerModel, nlp_solver)
        result_pg = PowerModels.run_opf_ptdf(data, DCPPowerModel, nlp_solver)

        @test result_va["termination_status"] == LOCALLY_SOLVED
        @test result_pg["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result_va["objective"], result_pg["objective"])
        for (i, gen) in data["gen"]
            @test isapprox(result_va["solution"]["gen"][i]["pg"],
                result_pg["solution"]["gen"][i]["pg"]; atol = 1e-8)
        end
    end
    @testset "14-bus case" begin
        data = PowerModels.parse_file("../test/data/matpower/case14.m")
        result_va = PowerModels.run_opf(data, DCPPowerModel, nlp_solver)
        result_pg = PowerModels.run_opf_ptdf(data, DCPPowerModel, nlp_solver)

        @test result_va["termination_status"] == LOCALLY_SOLVED
        @test result_pg["termination_status"] == LOCALLY_SOLVED
        @test isapprox(result_va["objective"], result_pg["objective"])
        for (i, gen) in data["gen"]
            @test isapprox(result_va["solution"]["gen"][i]["pg"],
                result_pg["solution"]["gen"][i]["pg"]; atol = 1e-8)
        end
    end

    @testset "no support for zero reference buses" begin
        data = PowerModels.parse_file("../test/data/matpower/case5.m")
        data["bus"]["4"]["bus_type"] = 2
        @test_throws(TESTLOG, ErrorException,
            PowerModels.run_opf_ptdf(data, DCPPowerModel, nlp_solver))
    end

    @testset "no support for multiple connected components" begin
        @test_throws(TESTLOG, ErrorException,
            PowerModels.run_opf_ptdf("../test/data/matpower/case6.m", DCPPowerModel, nlp_solver))
    end

    @testset "no support for dclines" begin
        @test_throws(TESTLOG, ErrorException,
            PowerModels.run_opf_ptdf("../test/data/matpower/case3.m", DCPPowerModel, nlp_solver))
    end

    @testset "no support for switches" begin
        @test_throws(TESTLOG, ErrorException,
            PowerModels.run_opf_ptdf("../test/data/matpower/case5_sw.m", DCPPowerModel, nlp_solver))
    end
end
