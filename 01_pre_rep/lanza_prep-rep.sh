#!/bin/bash
#SBATCH -n 1
#SBATCH --time 5-00:00:00
#SBATCH -p gpu
#SBATCH -J pre-rep

Exibe os nós alocados para o Job
echo $SLURM_JOB_NODELIST
nodeset -e $SLURM_JOB_NODELIST
cd $SLURM_SUBMIT_DIR

module load md/amber20

export Exec=pmemd.cuda
export Parm='step3_input.parm7'
export Topo='step3_input.crd'
export minrc="../arq_entrada/01_min"
export equilrc='../arq_entrada/02_equil/313.15k'

## Min1
$Exec -O -i $minrc/min1.in -p $Parm -c $Topo -o min1.out -r min1.rst -ref $Topo
$Exec -O -i $minrc/min2.in -p $Parm -c min1.rst -o min2.out -r min2.rst -ref min1.rst
$Exec -O -i $minrc/min3.in -p $Parm -c min2.rst -o min3.out -r min3.rst -ref min2.rst
$Exec -O -i $minrc/min4.in -p $Parm -c min3.rst -o min4.out -r min4.rst -ref min3.rst
$Exec -O -i $minrc/min5.in -p $Parm -c min4.rst -o min5.out -r min5.rst -ref min4.rst
$Exec -O -i $minrc/min6.in -p $Parm -c min5.rst -o min6.out -r min6.rst -ref min5.rst
$Exec -O -i $minrc/min7.in -p $Parm -c min6.rst -o min7.out -r min7.rst -ref min6.rst
## Min2
$Exec -O -i $minrc/min1.in -p $Parm -c min7.rst -o min1.out -r min1.rst -ref min7.rst
$Exec -O -i $minrc/min2.in -p $Parm -c min1.rst -o min2.out -r min2.rst -ref min1.rst
$Exec -O -i $minrc/min3.in -p $Parm -c min2.rst -o min3.out -r min3.rst -ref min2.rst
$Exec -O -i $minrc/min4.in -p $Parm -c min3.rst -o min4.out -r min4.rst -ref min3.rst
$Exec -O -i $minrc/min5.in -p $Parm -c min4.rst -o min5.out -r min5.rst -ref min4.rst
$Exec -O -i $minrc/min6.in -p $Parm -c min5.rst -o min6.out -r min6.rst -ref min5.rst
$Exec -O -i $minrc/min7.in -p $Parm -c min6.rst -o min7.out -r min7.rst -ref min6.rst
## Aquecimento e equilibrio em 10 etapas
$Exec -O -i $equilrc/equil1.in -p $Parm -c min7.rst -o equil1.out -r equil1.rst -x equil1.mdcrd -ref min7.rst
$Exec -O -i $equilrc/equil2.in -p $Parm -c equil1.rst -o equil2.out -r equil2.rst -x equil2.mdcrd -ref equil1.rst
$Exec -O -i $equilrc/equil3.in -p $Parm -c equil2.rst -o equil3.out -r equil3.rst -x equil3.mdcrd -ref equil2.rst
$Exec -O -i $equilrc/equil4.in -p $Parm -c equil3.rst -o equil4.out -r equil4.rst -x equil4.mdcrd -ref equil3.rst
$Exec -O -i $equilrc/equil5.in -p $Parm -c equil4.rst -o equil5.out -r equil5.rst -x equil5.mdcrd -ref equil4.rst
$Exec -O -i $equilrc/equil6.in -p $Parm -c equil5.rst -o equil6.out -r equil6.rst -x equil6.mdcrd -ref equil5.rst
$Exec -O -i $equilrc/equil7.in -p $Parm -c equil6.rst -o equil7.out -r equil7.rst -x equil7.mdcrd -ref equil6.rst
$Exec -O -i $equilrc/equil8.in -p $Parm -c equil7.rst -o equil8.out -r equil8.rst -x equil8.mdcrd -ref equil7.rst 
$Exec -O -i $equilrc/equil9.in -p $Parm -c equil8.rst -o equil9.out -r equil9.rst -x equil9.mdcrd -ref equil8.rst
$Exec -O -i $equilrc/equil10.in -p $Parm -c equil9.rst -o equil10.out -r equil10.rst -x equil10.mdcrd -ref equil9.rst

cp $equilrc/equil11.in $equilrc/prod.in .

echo "Etapa 1 terminou em:" ; date

