#!/bin/bash
# Banker's Algorithm implementation
# Gheorghe-Florin Hasna - M00910464

no_processes=5 #number of processes
no_resources=3 #three resource types
available=(10 5 7) #available value

declare -A max
max[0,0]=7 max[0,1]=5 max[0,2]=3
max[1,0]=3 max[1,1]=2 max[1,2]=2
max[2,0]=9 max[2,1]=0 max[2,2]=2
max[3,0]=2 max[3,1]=2 max[3,2]=2
max[4,0]=4 max[4,1]=3 max[4,2]=3

declare -A allocated
allocated[0,0]=0 allocated[0,1]=1 allocated[0,2]=0
allocated[1,0]=2 allocated[1,1]=0 allocated[1,2]=0
allocated[2,0]=3 allocated[2,1]=0 allocated[2,2]=2
allocated[3,0]=2 allocated[3,1]=1 allocated[3,2]=1
allocated[4,0]=0 allocated[4,1]=0 allocated[4,2]=2

declare -A need

#calculate the need matrix 
calculate_need() {
	for(( i=0;i<no_processes;i++ ));
	do
		for(( j=0;j<no_resources;j++ ));
		do
			need[$i,$j]=$(( max[$i,$j] - allocated[$i,$j] ))
		done
	done
}

# checking the state, if is safe or not
check_state() {
	local p=$1 # p=process
	local r=("${@:2}") # r=request

	# request less than or equal to need
	for (( i=0;i<no_resources;i++ ));
	do
		if (( r[$i] > need[$p,$i] ));
		then
			return 1 #Request exceeds need
		fi
	done

	#request is less than or equal to resources available
	for(( i=0;i<no_resources;i++ ));
	do
		if (( r[$i] > available[$i] ));
		then
			return 2 #Request exceeds available
		fi
	done

	# resource allocation simulation
	for (( i=0;i<no_resources;i++ ));
	do
		temp_available[$i]=$(( available[$i]-r[$i] ))
		temp_allocated[$i]=$(( allocated[$p,$i]+r[$i] ))
		temp_need[$i]=$(( need[$p,$i]-r[$i] ))
	done

	if  (( check_safety == 1));
	then
		return 3 # Unsafe state
	fi

	# passed check, state is safe
	for(( i=0;i<no_resources;i++ ));
	do
		available[$i]=${temp_available[$i]}
		allocated[$p,$i]=${temp_allocated[$i]}
		need[$p,$i]=${temp_need[$i]}
	done

	return 0 #request granted
}

check_safety(){
	local work=("${available[@]}")
	local finish=()

	for(( i=0;i<no_processes;i++ ));
	do
		finish[$i]=0
	done

	for(( i=0;i<no_processes;i++ ));
	do
		if (( finish[$i] == 0 ));
		then
			local can_allocate=1
			for(( j=0;j<no_resources;j++ ));
			do
				if (( need[$i,$j] > work[$j] ));
				then
					can_allocate=0
					break
				fi
			done

			if (( can_allocate ));
			then
				finish[$i]=1
				for(( j=0;j<no_resources;j++ ));
				do
					work[$j]=$(( work[$j] + allocated[$i,$j] ));
				done
				i=-1 #restart loop
			fi
		fi
	done

	for(( i=0;i<no_resources;i++ ));
	do
		if (( finish[$i] == 0 ));
		then
			return 1 #unsafe state
		fi
	done

	return 0 # safe state
}

# usage in practice
calculate_need

process_request=0
resource_request=(1 1 1)

check_state $process_request ${resource_request[@]}
result=$?

case $result in
	0) echo "Request granted.";;
	1) echo "Request denied, is exceeding need";;
	2) echo "Request denied, exceed resources available";;
	3) echo "Request denied, state in unsafe after granting request";;
esac

echo "Available: ${available[@]}"
echo "Allocated: "
for (( i=0;i<no_processes;i++ ));
do
	for (( j=0;j<no_processes;j++ ));
	do
		echo "${allocated[$i,$j]}"
	done
done


echo "Need:"
for (( i=0;i<no_processes;i++ ));
do
	for (( j=0;j<no_processes;j++ ));
	do
		echo "${need[$i,$j]}"
	done
done
