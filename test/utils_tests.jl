
@testset "sample neighbors tests" begin
    @testset "sample_rate = 1. tests" begin
        points = collect(1:10)
        n_neighbors = 4

        # zero neighbors
        idxs = NNDescent.sample_neighbors(length(points), 0)
        @test length(idxs) == 0

        # k < n
        idxs = NNDescent.sample_neighbors(length(points), n_neighbors)
        @test length(idxs) == n_neighbors
        @test issubset(idxs, points)

        # k > n
        idxs = NNDescent.sample_neighbors(length(points), length(points)+5)
        @test length(idxs) == length(points)
    end
    @testset "sample_rate = .5 tests" begin
        points = collect(1:10)
        n_neighbors = 4
        ρ = .5

        # zero neighbors
        idxs = NNDescent.sample_neighbors(length(points), 0, ρ)
        @test length(idxs) == 0

        # k < n
        idxs = NNDescent.sample_neighbors(length(points), n_neighbors, ρ)
        @test ρ*n_neighbors ≥ length(idxs)
        @test issubset(idxs, points)

        # k > n
        idxs = NNDescent.sample_neighbors(length(points), 2*length(points), ρ)
        @test length(idxs) == length(points)
    end
    @testset "exclude set tests" begin
        points = collect(1:10)

        # exclude 1
        idxs = NNDescent.sample_neighbors(length(points),
                                          length(points),
                                          exclude=[1])
        @test idxs ⊊ points
        @test !(1 ∈ idxs)

        # exclude all
        idxs = NNDescent.sample_neighbors(length(points),
                                          length(points),
                                          exclude=points)
        @test length(idxs) == 0

    end
end

@testset "make_knn_heaps tests" begin
    @testset "Float64 tests" begin
        data = [rand(3) for _ in 1:10]
        n_neighbors = 3

        knn_heaps = NNDescent.make_knn_heaps(data, n_neighbors)

        @test length(knn_heaps) == length(data)
        for p in 1:length(knn_heaps)
            @test length(knn_heaps[p]) == n_neighbors
            for t = 1:length(knn_heaps[p])
                @test knn_heaps[p][t].idx ≠ p
                @test knn_heaps[p][t].idx ≤ length(data)
                @test knn_heaps[p][t].dist === missing
            end
        end
    end
    @testset "Int tests" begin
        data = [rand([0, 1], 3) for _ in 1:10]
        n_neighbors = 2
        knn_heaps = NNDescent.make_knn_heaps(data, n_neighbors, Int)
        
        @test length(knn_heaps) == length(data)
        for p in 1:length(knn_heaps)
            @test length(knn_heaps[p]) == n_neighbors
            for t = 1:length(knn_heaps[p])
                @test knn_heaps[p][t].idx ≠ p
                @test knn_heaps[p][t].idx ≤ length(data)
                @test knn_heaps[p][t].dist === missing
            end
        end
        
    end
end

@testset "neighbors tests" begin
    # create heaps
    knn_heaps = [mutable_binary_maxheap(NNTuple{Int, Float64}) for _ in 1:5]
    push!(knn_heaps[1], NNTuple(2, Inf))
    push!(knn_heaps[1], NNTuple(5, Inf))
    push!(knn_heaps[2], NNTuple(4, Inf))
    push!(knn_heaps[3], NNTuple(2, Inf))
    push!(knn_heaps[3], NNTuple(4, Inf))
    push!(knn_heaps[4], NNTuple(1, Inf))
    push!(knn_heaps[5], NNTuple(3, Inf))
    push!(knn_heaps[5], NNTuple(4, Inf))
    old_fw, fw, old_bw, bw = _neighbors(knn_heaps)

    @testset "new fw neighbors tests" begin
        @test fw[1] == [2, 5]
        @test fw[2] == [4]
        @test fw[3] == [2, 4]
        @test fw[4] == [1]
        @test fw[5] == [3, 4]
    end
    @testset "new bw neighbors tests" begin
        @test bw[1] == [4]
        @test bw[2] == [1, 3]
        @test bw[3] == [5]
        @test bw[4] == [2, 3, 5]
        @test bw[5] == [1]
    end
    old_fw, fw, old_bw, bw = _neighbors(knn_heaps)
    @testset "old fw neighbors tests" begin
        @test old_fw[1] == [2, 5]
        @test old_fw[2] == [4]
        @test old_fw[3] == [2, 4]
        @test old_fw[4] == [1]
        @test old_fw[5] == [3, 4]
    end
    @testset "old bw neighbors tests" begin
        @test old_bw[1] == [4]
        @test old_bw[2] == [1, 3]
        @test old_bw[3] == [5]
        @test old_bw[4] == [2, 3, 5]
        @test old_bw[5] == [1]
    end
end
