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

# CHECK SAFETY
is_safe() {
	local work=("${available[@]}")
	local finish=()

	for (( i=0;i<n;i++ ));
	do
		finish[i]=false;
	done
	
	local flag=0
	for (( i=0;i<n;i++ ));
	do
		for (( j=0;j<m;j++ ));
		do
			if [ "${finish[$i]}" == "false" ] && [ "${need[$i,$j]}" -le "${work[$j]}" ];
			then
				work[$j]=$(( work[j] + allocation[$i,$j] ))
			else
				flag=1
			fi	
		done

		if [ $flag -eq 1 ];
		then
			echo "The new state after allocation is unsafe, exiting..."
			exit 1
		fi

		finish[$i]=true
	done

	for (( i=0;i<n;i++ ));
	do
		if [ "${finish[$i]}" == "false" ];
		then
			echo "The new state after allocation is unsafe, exiting..."
			exit 1
		fi
	done
	
	echo "The system is in a safe state, the request is granted."
	return 0
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
			echo "The request is invalid. Requested resources are exceeding the need."
			return
		fi
	done

	#request is less than or equal to resources available
	for(( i=0;i<m;i++ ));
	do
		if (( r[$i] > available[$i] ));
		then
			echo "The request is invalid. Requested resources are exceeding the available resources."
			return
		fi
	done

	# CHECK IF THE NEW REQUEST IS IN SAFE STATE
	for (( i=0;i<m;i++ ));
	do
		available[$i]=$(( available[$i]-r[$i] ))
		allocated[$i]=$(( allocated[$p,$i]+r[$i] ))
		need[$i]=$(( need[$p,$i]-r[$i] ))
	done

	is_safe
}

# usage in practice
calculate_need

# GET THE PROCESS AND ITS REQUEST
read -p "Enter the process number(up to 4): " process_request

if (( !(( $process_request >= 0 && $process_request <= $n )) ))
then
	echo "Invalid input"
	exit 1
fi	

read -p "Enter the request of the process, three numbers separated by a space:  " first second third 
resource_request[0]=$first
resource_request[1]=$second
resource_request[2]=$third

check_state $process_request ${resource_request[@]}
