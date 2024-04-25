#!/bin/bash
#PBS -N pre-rep
#PBS -l select=1:ncpus=1:ngpus=1
#PBS -l walltime=100:00:00
#PBS -q CCAD_QGPU
#PBS -o output.prep
#PBS -e error.prep
#-----------------------------------#
WORKDIR=$PBS_O_WORKDIR
echo $WORKDIR
cd $WORKDIR
module load md/amber22

export Step1Dir=../../01_pre_rep
export Exec=pmemd.cuda
export Parm=step3_input.parm7

$Exec -O -i $Step1Dir/equil10.in -p $Step1Dir/$Parm -c $Step1Dir/equil9.rst -o equil10.out -r equil10.rst -x equil10.mdcrd -ref $Step1Dir/equil9.rst

for ((i=1; i<=10; i++)) ##Loop over equil steps
do
    if (i=1)
    then
        $Exec -O -i $Step1Dir/prod_constra.in -p $Step1Dir/$Parm -c equil10.rst -o prod($i)0ns.out -r prod($i)0ns.rst -x prod($i)0ns.mdcrd -ref equil10.rst
    fi
    $Exec -O -i $Step1Dir/prod_constra.in -p $Step1Dir/$Parm -c prod($i-1)0ns.rst -o prod($i)0ns.out -r prod($i)0ns.rst -x prod($i)0ns.mdcrd -ref prod($i-1)0ns.rst 
done

## Ultima etapa de equilibrio + produção de 100ns

echo "------------------------------------------------"
echo "        Replica finalizada com sucesso!         "
echo "------------------------------------------------"
