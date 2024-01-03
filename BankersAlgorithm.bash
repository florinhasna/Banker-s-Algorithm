#!/bin/bash
# Banker's Algorithm implementation
# Gheorghe-Florin Hasna - M00910464

# PROCESSES AND VALUES OF RESOURCES
n=5 #number of processes
m=3 #three resource types

# THE AVAILABLE VALUE
available=(10 5 7) #available value

# MAX VALUES
declare -A max
max[0,0]=7 max[0,1]=5 max[0,2]=3
max[1,0]=3 max[1,1]=2 max[1,2]=2
max[2,0]=9 max[2,1]=0 max[2,2]=2
max[3,0]=2 max[3,1]=2 max[3,2]=2
max[4,0]=4 max[4,1]=3 max[4,2]=3

# ALLOCATION
declare -A allocated
allocated[0,0]=0 allocated[0,1]=1 allocated[0,2]=0
allocated[1,0]=2 allocated[1,1]=0 allocated[1,2]=0
allocated[2,0]=3 allocated[2,1]=0 allocated[2,2]=2
allocated[3,0]=2 allocated[3,1]=1 allocated[3,2]=1
allocated[4,0]=0 allocated[4,1]=0 allocated[4,2]=2

declare -A need

# FINDING THE NEED
calculate_need() {
	for(( i=0;i<n;i++ ));
	do
		for(( j=0;j<m;j++ ));
		do
			need[$i,$j]=$(( max[$i,$j] - allocated[$i,$j] ))
		done
	done
}

# CHECKING IF IS POSSIBLE TO ALLOCATE OR NOT
check_state() {
	local p=$1 # p=process
	local r=("${@:2}") # r=request

	# request less than or equal to need
	for (( i=0;i<m;i++ ));
	do
		if (( r[$i] > need[$p,$i] ));
		then
			return 1 #Request exceeds need
		fi
	done

	#request is less than or equal to resources available
	for(( i=0;i<m;i++ ));
	do
		if (( r[$i] > available[$i] ));
		then
			return 2 #Request exceeds available
		fi
	done

	# CHECK IF THE NEW REQUEST IS IN SAFE STATE
	for (( i=0;i<m;i++ ));
	do
		temp_available[$i]=$(( available[$i]-r[$i] ))
		temp_allocated[$i]=$(( allocated[$p,$i]+r[$i] ))
		temp_need[$i]=$(( need[$p,$i]-r[$i] ))
	done

	# IF IS UNSAFE, RETURN ERROR MESSAGE 3
	if  (( check_safety == 1));
	then
		return 3 # Unsafe state
	fi

	# IF IS POSSIBLE, SYSTEM IS IN SAFE STATE, ALLOCATE
	for(( i=0;i<m;i++ ));
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

	for(( i=0;i<n;i++ ));
	do
		finish[$i]=0
	done

	for(( i=0;i<n;i++ ));
	do
		if (( finish[$i] == 0 ));
		then
			local can_allocate=1
			for(( j=0;j<m;j++ ));
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
				for(( j=0;j<m;j++ ));
				do
					work[$j]=$(( work[$j] + allocated[$i,$j] ));
				done
				i=-1 #restart loop
			fi
		fi
	done

	for(( i=0;i<m;i++ ));
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

iterator=0

# GET 5 PROCESSES AND THEIR REQUEST, CHECK ONE AT A TIME
while (( $iterator<$n ));
do
	# GET THE PROCESS AND ITS REQUEST
	read -p "Enter the process number(up to 4): " process_request
	
	if (( !(($process_request >= 0 && $process_request <= n)) ))
	then
		echo "Invalid input"
		exit 1
	fi	

	read -p "Enter the allocation of the process, three numbers separated by a space:  " first second third 
	resource_request[0]=$first
	resource_request[1]=$second
	resource_request[2]=$third

	check_state $process_request ${resource_request[@]}
	result=$?

	# PRINT MESSAGE WHETHER IS GRANTED OR NOT
	case $result in
		0) echo "Request granted.";;
		1) echo "Request denied, is exceeding need";;
		2) echo "Request denied, exceed resources available";;
		3) echo "Request denied, state in unsafe after granting request";;
	esac

	if (( $result != 0 ))
	then
		exit 1
	fi

	iterator=$(( $iterator + 1 ))
done

# PRINT AVAILABLE AND THE NEED
echo "Available: ${available[@]}"
echo "Allocated: "
for (( i=0;i<n;i++ ));
do
	for (( j=0;j<n;j++ ));
	do
		echo "${allocated[$i,$j]}"
	done
done


echo "Need:"
for (( i=0;i<n;i++ ));
do
	for (( j=0;j<n;j++ ));
	do
		echo "${need[$i,$j]}"
	done
done
