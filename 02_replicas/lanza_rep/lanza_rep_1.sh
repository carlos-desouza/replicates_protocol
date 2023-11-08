#!/bin/bash
##### Não esqueça de rodar o lanza_prep_rep.sh antes dessa rotina

export ckpnt=$PWD
export inicio=path/to/01_prep_rep
export destino=path/to/02_replicas

##mudar o número de réplicas caso queira
for ((i=1; i<=10; i++))
do
    mkdir $destino/rep$i
    cd $inicio ; cp equil10.rst step3_input.parm7 equil11.in $destino/rep$i/
    sed -i "s/TAL/$i/g" "$destino/rep$i/lanza_rep_2.sh"
    cd $destino/rep$i ; sbatch $destino/rep$i/lanza_rep_2.sh
    cd $ckpnt
done