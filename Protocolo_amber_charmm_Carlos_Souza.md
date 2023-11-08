Protocolo dividido em três partes

## preparar sistema base
.
---------------------------------------------------------------------------------------------------------------------------------------
PROTOCOLO AMBER

1) Calcular estados de protonação corretos para o sistema
    Utilize o servidor pdb2pqr (https://server.poissonboltzmann.org/pdb2pqr) -> resultado *.pqr
    utilize o servidor H++ (http://newbiophysics.cs.vt.edu/H++/)
2) Preparar ligante

Utiliza-se a estrutura do ligante do docking ou redocking para realizar uma 'frozen opt' no gaussian
---------------------------
OBS. Ignore todos os:
```alguma_coisa
```
Eles servirão apenas para destacar o texto
---------------------------

```py
%Chk=lig.chk
%nproc=4
%mem=200mw
#p B3LYP/6-31+g(d) opt pop=none

 opt frozen 

0 1
N -1        -0.44688       -1.07288       -0.28419
N -1         3.65770        0.83124        1.09916
C -1        -0.57470        0.24619       -0.35160
C -1         1.01086       -2.83633        0.67074
C -1        -1.37165       -1.97591       -0.97990
C -1        -2.43595       -2.50282       -0.04811
C -1        -4.80927       -3.22143       -0.01700
C 0         6.86991       -2.39534       -0.86918
O 0         6.38494       -3.36607       -0.29918
N 0         8.08737       -2.46367       -1.50719
H 0         8.62409       -1.62532       -1.68226
H 0         8.61583       -3.31412       -1.35618
F 0         1.10542        6.44055        0.88299
```

Onde os atomos com o sufixo '-1' estarão com as coordenadas cartesianas fixas e os com sufixo '0' serão otimizados
Os atomos que deverão ser otimizados no geral são os hidrogênios.
Essa etapa nem sempre é necessária


Após isso, deve-se converter o arquivo .log ou .out gerado para pdb utilizando o obabel
Então utilize o antechamber para gerar o input da carga gesp:

```bash
obabel -i log ligand_opt.log -o pdb -O ligand_opt.pdb
antechamber -i ligand_opt.pdb -fi pdb -o ligand_resp.com -fo gcrt -gv 1 -ge ligand_resp.gesp
```

Obs. Lembre-se de retirar o "opt" contido no cabeçalho do arquivo 'ligand_resp.com'

Resultando em:
# ligand.pdb (que contenha as coordenadas do sitio ativo)
# ligand_resp.gesp ( que contenha as Cargas Resp cal. pelo Gaussian)
# ligand_resp.log  ( que contenha as Cargas Resp cal. pelo Gaussian)

Esses arquivos serão utilizados na sequência de comando para obter o arquivo ligand.frcmod:
```bash
antechamber -i ligand.pdb -fi pdb -o ligand.com -fo gcrt -gv 1 -ge ligand_resp.gesp
antechamber -i ligand_resp.gesp -fi gesp -c wc -cf ligand_c.crg -o input.ac -fo ac
antechamber -fi pdb -fo mol2 -i ligand.pdb -o ligand_resp.mol2 -c rc -cf ligand_c.crg -j 4 -at gaff
parmchk2 -i ligand_resp.mol2 -f mol2 -o ligand.frcmod
```
Agora, com os arquivos:
# ligand.frcmod (contém os parametros de ligação, ângulo, diedro etc)
# ligand_resp.mol2 (esse arq. contem as cargas e coordenadas do sitio ativo)
# receptor.pdb (proteina já tratada com o pKa) 

3) Prepare o complexo utilizado o tleap

```bash
leap -f leaprc.protein.ff14SB       #carregar o campo de força para proteínas
source leaprc.gaff                  #carregar campo de força para ligante se houver
source leaprc.water.tip3p           #carregar campo de força para a água ou solvente utilizado
loadamberparams ligand.frcmod       #carrega os parâmetros do ligante
LIG=loadmol2 ligand_resp.mol2       #Define LIG como o arquivo com as cargas e coordenadas do sítio ativo
receptor = loadpdb receptor.pdb     #Define receptor como o arquivo pdb tratato com o pKa
#Essa etapa só será necessária se houver ligações disulfeto
bond receptor.289.SG receptor.273.SG       
bond receptor.203.SG receptor.239.SG
#
complex = combine {receptor LIG}    #define complex como a combinação de receptor e LIG
set default PBRadii mbondi2         
saveamberparm LIG ligand.top ligand.crd             #salva a topologia e coordenada do ligante
saveamberparm receptor receptor.top receptor.crd    #salva a topologia e coordenada do receptor
saveamberparm complex complex.top complex.crd       #salva a topologia e coordenada do complexo
savepdb complex complex.pdb                         #salva o pdb do complexo
check LIG                                           #verifica se o ligante está ok
check complex                                       #verifica se o complexo está ok
charge complex                                      #mostra a final do complexo

addIons2 complex Na+ 0  #neutralize com Na+ caso a carga seja negativa (-)
addIons2 complex Cl- 0   #neutralize com Cl- caso a carga seja positiva (+)

solvateoct complex TIP3PBOX 12.0      #verifique o tipo de caixa (oct, box etc) e o tamanho dela antes de realizar essa etapa.
saveamberparm complex complex_box.top complex_box.crd       #salva a topologia e coordenada do complexo solvatado
savepdb complex complex_box.pdb                             #salva o pdb do complexo solvatado
quit                                                        #termina a execução do programa
#### Se fores usar um peptídeo no lugar de uma proteína utilize...
peptide = sequence { ACE ALA ALA ALA GLY ALA NME }
#
```
O processo terminará com os seguintes arquivos que serão utilizados para iniciar a produção:

# ligand.top   (topologia do ligante/inibidor)
# ligand.crd   (Coordenadas do ligante/inibidor)
# receptor.top (topologia do receptor/proteina)
# receptor.crd (Coordenadas do receptor/proteina)
# complex.top   (topologia do complexo (receptor + ligante) no vacuo)
# complex.crd   (Coordenadas do complexo (receptor + ligante) no vacuo)
# complex.pdb   (arquivo do complexo (receptor + ligante) no vacuo para visualizar nos programas)
# complex_box.top (topologia do complexo (receptor + ligante) solvatado com água)
# complex_box.crd (Coordenadas do complexo (receptor + ligante) solvatado com água)
# complex_box.pdb (arquivo do complexo (receptor + ligante) solvatado com água para visualizar nos programas)

fim do protocolo amber
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
Protocolo charmm-gui
1) Calcular estados de protonação corretos para o sistema
    Utilize o servidor pdb2pqr (https://server.poissonboltzmann.org/pdb2pqr) -> resultado *.pqr
    utilize o servidor H++ (http://newbiophysics.cs.vt.edu/H++/)
2) Preparar ligante
    Mesmo processo de opt frozen do protocolo amber, porém as cargas e parâmetros serão calculados pelo servidor 
    (https://cgenff.silcsbio.com/)

A peculiaridade nesse caso é converter a saída da opt frozen para mol2 no lugar de pdb
```bash
obabel -i log ligand_opt.log -o mol2 -O ligand_opt.mol2

```
O resultado deverá ser dividido em dois arquivos:
# ligand.rtf
iniciará com:
* Topologies generated by

e terminará com:
END

# ligand.prm
iniciará com:
* Parameters generated by analogy by

e terminará com:
END

Não esqueça de substituir o nome do resíduo para um de três caracteres maiúsculos em ambos os arquivos
E também de adicionar cadeia para o ligante
Ex: PET B 101

3) A formação do complexo deve ser feita com a junção dos arquivos receptor.pqr e ligand.pdb
    pode ser feita utilizando 
    cat receptor.pqr ligand.pdb >> complex.pqr
    Verifique se o arquivo está correto!!!!!!!


Por fim, a construção dos arquivos de entrada para a produção da dinâmica será feita pelo charmm-gui (https://www.charmm-gui.org/)
Nas opções input generator > solution builder

Onde será inserido o arquivo complex.pqr

... 
O seguinte protocolo conta com 7 etapas de minimização, podendo ser em duplicata (recomendo)
10 etapas de aquecimento e equilíbrio
Produção de 100ns de simulação, podendo ser modificado dependendo da necessidade

O sistema será minimizado totalmente e equilibrado até a etapa 9, onde será diferenciado em replicas
Ou seja... cada réplica iniciará com a décima etapa de aquecimento/equilibrio independente
Garantindo velocidades iniciais diferentes para cada réplica

OBS.
-------------------------------------------------------------------------------------------------------------------
##                  Aquecimento e Equilibrio em 10 etapas:
#	ETAPA		TEMPERATURA (em Kelvin)		TEMPO		TIPO_de_Sistema
#	equil 1		    0  	a	100 K		    20ps        NVT=Volume constante
#	equil 2		    100	a	100 K		    1ns		    NPT=Pressão constante
#	equil 3		    100	a	125 K		    1ns		    NPT=Pressão constante
#	equil 4		    125	a	150 K		    1ns		    NPT=Pressão constante
#	equil 5		    150	a	175 K		    1ns		    NPT=Pressão constante
#	equil 6		    175	a	200 K		    1ns		    NPT=Pressão constante
#	equil 7		    200	a	225 K		    1ns		    NPT=Pressão constante
#	equil 8		    225	a	250 K		    1ns		    NPT=Pressão constante
#	equil 9		    250	a	275 K		    1ns		    NPT=Pressão constante
#	equil 10	    275	a	300 K		    5ns		    NPT=Pressão constante

## produção:
### nessa etapa a DM ocorrerá de 10 em 10ns até 100ns ou mais (o tempo de DM vai de cada)
### para isso o prod.in tem que ter as condições especificas para que seja executado o tempo de 10ns
### nstlim=5000000, dt=0.002,
### multiplique os valores de nstlim * dt para saber o tempo em ps ex. 
### 5000000 * 0.002 = 10000 ps = 10ns

Os arquivos para lanzar as replicas estão na pasta scripts
Mas lembre-se de verificar o nome dos arquivos antes de iniciar
-------------------------------------------------------------------------------------------------------------------

## Créditos
Escrito por: Carlos Gabriel da Silva de Souza
Adaptado do protocolo amber de Clauber Costa
E-mail para contato: carlosss_gabriel@hotmail.com