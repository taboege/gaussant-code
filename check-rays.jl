using AbstractAlgebra
using Combinatorics

function subsets()
	[ [1],
	  [2], [1,2],
	  [3], [1,3], [2,3], [1,2,3],
	  [4], [1,4], [2,4], [1,2,4], [3,4], [1,3,4], [2,3,4], [1,2,3,4],
	  [5], [1,5], [2,5], [1,2,5], [3,5], [1,3,5], [2,3,5], [1,2,3,5], [4,5], [1,4,5], [2,4,5], [1,2,4,5], [3,4,5], [1,3,4,5], [2,3,4,5], [1,2,3,4,5]
	]
end

function find_submatrix(A, r)
	Isets = collect(powerset(1:size(A,1), r, r))
	Jsets = collect(powerset(1:size(A,2), r, r))
	for I in Isets
		for J in Jsets
			s = det(A[I,J])
			if (s == 1 || s == -1)
				return true
			end
		end
	end
	return false
end

function entropy(ABCDE)
	h = []
	for I in subsets()
		rows = []
		for i in I
			push!(rows, ABCDE[i])
		end
		A = matrix(QQ, vcat(vcat(rows...)...))
		r = rank(A)
		push!(h, r)
		# Verify that there is an r x r submatrix with
		# determinant +/- 1, so that the rank is confirmed
		# over every field.
		if (!find_submatrix(A, r))
			error("could not find +/- 1 determinant submatrix")
		end
	end
	return h
end

data = [
	# NOTE: The numbers are off-by-one with respect to the text document
	# describing the overall check procedure. This is because their rays5
	# file starts with the zero vector but the checkrays5.m file leaves
	# that out. Otherwise the order is the same!
	#
	# NOTE: Julia has edge cases with vcat on array of array of ...
	# when the lowest layer has only a single element, therefore
	# adding redundant last entries 0 to the first three arrays of
	# subspaces, which would normally be single-element. This does
	# not change the ranks.
	# 3
	[ [ [0 0] ], [ [0 0] ], [ [0 0] ], [ [1 0] ], [ [1 0] ] ],
	# 4
	[ [ [0 0] ], [ [0 0] ], [ [1 0] ], [ [1 0] ], [ [1 0] ] ],
	# 5
	[ [ [0 0] ], [ [1 0] ], [ [1 0] ], [ [1 0] ], [ [1 0] ] ],
	# 7
	[ [ [0 0] ], [ [0 0] ], [ [1 0] ], [ [0 1] ], [ [1 1] ] ],
	# 8
	[ [ [0 0] ], [ [1 0] ], [ [0 1] ], [ [1 1] ], [ [1 1] ] ],
	# 10
	[ [ [0 0] ], [ [1 0], [0 1] ], [ [1 0] ], [ [0 1] ], [ [1 1] ] ],
	# 11
	[ [ [1 0] ], [ [0 1] ], [ [1 1] ], [ [1 1] ], [ [0 1] ] ],
	# 18
	[ [ [0 0 0] ], [ [1 0 0] ], [ [0 1 0] ], [ [0 0 1] ], [ [1 1 1] ] ],
	# 20
	[ [ [1 0 0] ], [ [1 0 0] ], [ [0 1 0] ], [ [0 0 1] ], [ [1 1 1] ] ],
	# 23
	[ [ [1 0 0] ], [ [0 1 0] ], [ [0 0 1] ], [ [0 1 1] ], [ [1 1 0], [0 1 1] ] ],
	# 25
	[ [ [1 0 0] ], [ [0 1 0] ], [ [0 0 1] ], [ [1 1 1] ], [ [0 1 1] ] ],
	# 28
	[ [ [1 0 0] ], [ [0 1 0] ], [ [0 0 1] ], [ [1 1 1] ], [ [1 1 0], [0 0 1] ] ],
	# 32
	[ [ [1 0 0] ], [ [0 1 0] ], [ [0 0 1] ], [ [1 1 0], [1 0 1] ], [ [0 1 0], [0 0 1] ] ],
	# 41
	[ [ [1 0 0 0], [0 1 0 0] ], [ [0 0 1 0] ], [ [0 0 0 1] ], [ [1 0 1 1] ], [ [0 1 1 1] ] ],
	# 43
	[ [ [1 0 0 0], [0 1 0 0] ], [ [1 0 0 0], [0 0 1 0] ], [ [0 0 0 1] ], [ [0 1 1 1] ], [ [1 1 1 1] ] ],
	# 45
	[ [ [1 0 0 0], [0 1 0 0] ], [ [0 0 1 0], [0 0 0 1] ], [ [1 0 0 0] ], [ [0 1 1 0] ], [ [1 1 0 1] ] ],
	# 47
	[ [ [1 0 0 0], [0 1 0 0] ], [ [0 0 1 0], [0 0 0 1] ], [ [1 0 1 0] ], [ [0 1 0 1] ], [ [0 1 1 1] ] ],
	# 52
	[ [ [1 0 0 0], [0 1 0 0] ], [ [0 0 1 0], [0 0 0 1] ], [ [1 0 0 0], [0 0 1 0] ], [ [0 1 0 1] ], [ [1 0 1 1] ] ],
	# 85
	[ [ [1 0 0 0 0] ], [ [0 1 0 0 0], [0 0 1 0 0] ], [ [0 1 0 0 0], [0 0 0 1 0] ], [ [1 0 1 1 0], [0 0 0 0 1] ], [ [1 1 0 0 0], [0 1 1 0 1] ] ],
	# 86
	[ [ [1 0 0 0 0] ], [ [0 1 0 0 0], [0 0 1 0 0] ], [ [0 1 0 0 0], [0 0 0 1 0] ], [ [1 0 1 1 0], [0 0 0 0 1] ], [ [1 1 0 0 0], [0 0 0 1 0], [0 0 1 0 1] ] ],
	# 93
	[ [ [1 0 0 0 0] ], [ [0 1 0 0 0], [0 0 1 0 0] ], [ [0 0 0 1 0], [0 0 0 0 1] ], [ [0 1 0 1 0], [0 0 1 0 1] ], [ [1 1 0 0 0], [0 0 0 0 1], [0 1 1 1 1] ] ],
	# 97
	[ [ [1 0 0 0 0] ], [ [0 1 0 0 0], [0 0 1 0 0] ], [ [0 0 0 1 0], [0 0 0 0 1] ], [ [1 1 0 0 0], [1 0 0 1 0], [0 0 1 0 1] ], [ [0 1 0 0 0], [0 0 0 1 0], [1 0 1 0 1] ] ],
	# 111
	[ [ [1 0 0 0 0 0], [0 1 0 0 0 0] ], [ [0 0 1 0 0 0], [0 0 0 1 0 0] ], [ [0 0 0 0 1 0], [0 0 0 0 0 1] ], [ [0 0 0 1 0 1], [0 1 1 0 1 1] ], [ [1 0 0 0 1 0], [0 0 1 0 0 1] ] ],
	# 121
	[ [ [1 0 0 0 0 0], [0 1 0 0 0 0], [0 0 1 0 0 0] ], [ [1 0 0 0 0 0], [0 0 0 1 0 0] ], [ [0 0 0 0 1 0], [0 0 0 0 0 1] ], [ [0 1 0 1 0 0], [0 0 1 0 1 0] ], [ [0 0 1 1 0 0], [1 1 0 0 0 1] ] ],
	# 128
	[ [ [1 0 0 0 0 0], [0 1 0 0 0 0], [0 0 1 0 0 0] ], [ [0 0 0 1 0 0], [0 0 0 0 1 0], [0 0 0 0 0 1] ], [ [1 0 0 1 0 0], [0 1 0 0 1 0] ], [ [1 0 0 1 0 0], [0 0 1 0 0 1] ], [ [1 0 0 0 1 1] ] ],
	# 138
	[ [ [1 0 0 0 0 0 0], [0 1 0 0 0 0 0] ], [ [0 0 1 0 0 0 0], [0 0 0 1 0 0 0] ], [ [1 0 1 0 0 0 0], [0 0 0 0 1 0 0] ], [ [0 1 0 1 1 0 0], [0 0 0 0 0 1 0], [0 0 0 0 0 0 1] ], [ [0 0 1 0 1 0 0], [0 1 0 0 1 1 0], [0 0 1 0 0 0 1] ] ],
	# 145
	[ [ [1 0 0 0 0 0 0], [0 1 0 0 0 0 0] ], [ [0 0 1 0 0 0 0], [0 0 0 1 0 0 0] ], [ [0 0 0 0 1 0 0], [0 0 0 0 0 1 0], [0 0 0 0 0 0 1] ], [ [0 0 0 0 1 0 0], [1 0 1 0 0 1 0], [0 1 0 1 0 0 1] ], [ [0 0 1 0 1 0 0], [0 0 0 1 0 0 1], [1 0 0 1 0 1 0] ] ],
	# 146
	[ [ [1 0 0 0 0 0 0], [0 1 0 0 0 0 0] ], [ [1 0 0 1 0 1 0], [0 1 0 0 1 0 1] ], [ [0 0 1 0 0 0 0], [0 0 0 0 0 1 0], [0 0 0 0 0 0 1] ], [ [0 0 1 0 0 0 0], [0 0 0 1 0 0 0], [0 0 0 0 1 0 0] ], [ [0 0 0 1 0 0 0], [0 0 0 0 1 0 0], [1 0 1 0 0 0 0], [0 1 1 0 0 0 1] ] ]
]

map(d -> print(entropy(d), "\n"), data)
