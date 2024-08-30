# jdk_version=$(ls -al {{ jdk.oss.jvm_home}}|grep "^d"|grep "java"|awk '{print$NF}')
# export JAVA_HOME={{ jdk.oss.jvm_home }}/$jdk_version
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which java)))))
