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
		NAME=$(echo "$CONFIG_MAP" | yq e .metadata.name* -)
		DATA=$(echo "$CONFIG_MAP" | yq e .data* -)
		echo "$CONFIG_MAP" | yq e .data* -
		cat >> values.yaml <<-EOF
- name: $NAME
  data:
EOF
		INDENTED_DATA=$(echo "$DATA" | sed 's/^/    /')
		echo "$INDENTED_DATA" >> values.yaml
	fi	
	echo $file
done
#yq e .data* master_configmap.yaml
#yq e .metadata.name* master_configmap.yaml
