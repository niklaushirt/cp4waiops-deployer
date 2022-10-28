


echo "***************************************************************************************************************************************************"
echo "   🛠️   Resources"
echo "     "	




function namespace_resources(){
   echo "***************************************************************************************************************************************************"
   echo "   🛠️   Resources for Namespace $NAMESPACE"
   echo "     "	

   export res=($(kubectl get pods -n $NAMESPACE -o=jsonpath='{.items[*]..resources.requests.cpu}'))
   let tot=0
   for i in "${res[@]}"
   do
      if [[ $i =~ "m" ]]; then
         i=$(echo $i | sed 's/[^0-9]*//g')
         tot=$(( tot + i ))
      else
         tot=$(( tot + i*1000 ))
      fi
   done
   cpu_requests_tot=$(( tot/1000 ))
    if [[  $cpu_requests_tot == "0" ]]; then
        cpu_requests_tot="<1"
        echo "           CPU Requests Total           $cpu_requests_tot CPU   ($tot m CPU)"
    else
        echo "           CPU Requests Total           $cpu_requests_tot CPU    ($tot m CPU)"
    fi



   export res=($(kubectl get pods -n $NAMESPACE -o=jsonpath='{.items[*]..resources.limits.cpu}'))
   let tot=0
   for i in "${res[@]}"
   do
      if [[ $i =~ "m" ]]; then
         i=$(echo $i | sed 's/[^0-9]*//g')
         tot=$(( tot + i ))
      else
         tot=$(( tot + i*1000 ))
      fi
   done
   export cpu_limits_tot=$(( tot/1000 ))
    if [[  $cpu_limits_tot == "0" ]]; then
        cpu_limits_tot="<1"
        echo "           CPU Limits Total             $cpu_limits_tot CPU   ($tot m CPU)"
    else
        echo "           CPU Limits Total             $cpu_limits_tot CPU    ($tot m CPU)"
    fi

   echo "     "	


   export res=($(kubectl get pods -n $NAMESPACE -o=jsonpath='{.items[*]..resources.requests.memory}'))
   let tot=0
   for i in "${res[@]}"
   do
      if [[ $i =~ "Mi" ]]; then
         i=$(echo $i | sed 's/[^0-9]*//g')
         tot=$(( tot + i ))
      elif [[ $i =~ "Gi" ]]; then
         i=$(echo $i | sed 's/[^0-9]*//g')
         tot=$(( tot + i*1000 ))
      fi
   done
   export mem_requests_tot=$(( tot/1000 ))

    if [[  $mem_requests_tot == "0" ]]; then
        mem_requests_tot="<1"
        echo "           Memory Requests Total        $mem_requests_tot GB    ($tot MB)"
    else
        echo "           Memory Requests Total        $mem_requests_tot GB     ($tot m MB)"
    fi




   export res=($(kubectl get pods -n $NAMESPACE -o=jsonpath='{.items[*]..resources.limits.memory}'))
   let tot=0
   for i in "${res[@]}"
   do
      if [[ $i =~ "Mi" ]]; then
         i=$(echo $i | sed 's/[^0-9]*//g')
         tot=$(( tot + i ))
      elif [[ $i =~ "Gi" ]]; then
         i=$(echo $i | sed 's/[^0-9]*//g')
         tot=$(( tot + i*1000 ))
      fi
   done
   export mem_limits_tot=$(( tot/1000 ))

    if [[  $mem_limits_tot == "0" ]]; then
        mem_limits_tot="<1"
        echo "           Memory Limits Total          $mem_limits_tot GB    ($tot MB)"
    else
        echo "           Memory Limits Total          $mem_limits_tot GB     ($tot m MB)"
    fi

   echo "     "	
   echo "     "	
   echo "     "	
   echo "     "	



}


export NAMESPACE=cp4waiops-demo-ui
namespace_resources

export NAMESPACE=awx
namespace_resources

export NAMESPACE=turbonomic
namespace_resources

export NAMESPACE=openldap
namespace_resources

export NAMESPACE=robot-shop
namespace_resources

export NAMESPACE=cp4waiops
namespace_resources

export NAMESPACE=ibm-common-services
namespace_resources

export NAMESPACE=cp4waiops-evtmgr
namespace_resources
