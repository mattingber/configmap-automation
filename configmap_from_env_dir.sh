for file in $(ls ./env); do
	FILE_TYPE=$(echo $file | awk -F "." '{ print $NF}')
	if [ $FILE_TYPE == "env" ]
	then
		echo "Found env file $file, createing a k8s configmap resource..."
		CONFIG_MAP=$(kubectl create configmap my-config --from-env-file=./env/$file --dry-run=client -o yaml)
		cat >> master_configmap.yaml <<-EOF
		---
		$CONFIG_MAP
		EOF
		echo $CONFIGMAP | yq e .metadata.name* - -v
		echo $CONFIGMAP | yq e .data* - -v
	fi	
	echo $file
done
#yq e .data* master_configmap.yaml
#yq e .metadata.name* master_configmap.yaml
