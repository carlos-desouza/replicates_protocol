Claro! Aqui está a tradução para o inglês:

# Protocol Divided into Three Parts

## Prepare Base System

---------------------------------------------------------------------------------------------------------------------------------------

### AMBER PROTOCOL

1) Calculate the correct protonation states for the system.
   Use the pdb2pqr server (https://server.poissonboltzmann.org/pdb2pqr) -> result *.pqr
   Use the H++ server (http://newbiophysics.cs.vt.edu/H++/)

2) Prepare the ligand.

Use the docking or redocking structure of the ligand to perform a 'frozen opt' in Gaussian.

--------------------------------------------------------------------------------------------
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

Atoms with the suffix '-1' will have fixed Cartesian coordinates, while those with the suffix '0' will be optimized. Generally, the atoms that should be optimized are the hydrogens. This step is not always necessary.

After that, convert the generated .log or .out file to pdb using obabel. Then use antechamber to generate the input for the gesp charge:

```bash
obabel -i log ligand_opt.log -o pdb -O ligand_opt.pdb
antechamber -i ligand_opt.pdb -fi pdb -o ligand_resp.com -fo gcrt -gv 1 -ge ligand_resp.gesp
```

**Note:** Remember to remove the "opt" from the header of the 'ligand_resp.com' file.

Resulting in:
- **ligand.pdb** (containing the coordinates of the active site)
- **ligand_resp.gesp** (containing the RESP charges calculated by Gaussian)
- **ligand_resp.log** (containing the RESP charges calculated by Gaussian)

These files will be used in the command sequence to obtain the ligand.frcmod file:
```bash
antechamber -i ligand.pdb -fi pdb -o ligand.com -fo gcrt -gv 1 -ge ligand_resp.gesp
antechamber -i ligand_resp.gesp -fi gesp -c wc -cf ligand_c.crg -o input.ac -fo ac
antechamber -fi pdb -fo mol2 -i ligand.pdb -o ligand_resp.mol2 -c rc -cf ligand_c.crg -j 4 -at gaff
parmchk2 -i ligand_resp.mol2 -f mol2 -o ligand.frcmod
```

Now, with the files:
- **ligand.frcmod** (contains the parameters for bond, angle, dihedral, etc.)
- **ligand_resp.mol2** (this file contains the charges and coordinates of the active site)
- **receptor.pdb** (protein already processed with pKa)

3) Prepare the complex using tleap:

```bash
leap -f leaprc.protein.ff14SB       # load the force field for proteins
source leaprc.gaff                  # load the force field for ligands if any
source leaprc.water.tip3p           # load the force field for water or solvent used
loadamberparams ligand.frcmod       # load the ligand parameters
LIG=loadmol2 ligand_resp.mol2       # define LIG as the file with the charges and coordinates of the active site
receptor = loadpdb receptor.pdb     # define receptor as the pdb file processed with pKa
# This step is only necessary if there are disulfide bonds
bond receptor.289.SG receptor.273.SG       
bond receptor.203.SG receptor.239.SG
#
complex = combine {receptor LIG}    # define complex as the combination of receptor and LIG
set default PBRadii mbondi2         
saveamberparm LIG ligand.top ligand.crd             # save the topology and coordinates of the ligand
saveamberparm receptor receptor.top receptor.crd    # save the topology and coordinates of the receptor
saveamberparm complex complex.top complex.crd       # save the topology and coordinates of the complex
savepdb complex complex.pdb                         # save the pdb of the complex
check LIG                                           # check if the ligand is okay
check complex                                       # check if the complex is okay
charge complex                                      # show the final charge of the complex

addIons2 complex Na+ 0  # neutralize with Na+ if the charge is negative (-)
addIons2 complex Cl- 0   # neutralize with Cl- if the charge is positive (+)

solvateoct complex TIP3PBOX 12.0      # check the type of box (oct, box, etc.) and its size before performing this step.
saveamberparm complex complex_box.top complex_box.crd       # save the topology and coordinates of the solvated complex
savepdb complex complex_box.pdb                             # save the pdb of the solvated complex
quit                                                        # end the program execution
#### If you are using a peptide instead of a protein use...
peptide = sequence { ACE ALA ALA ALA GLY ALA NME }
#
```

The process will end with the following files that will be used to initiate production:

- **ligand.top**   (topology of the ligand/inhibitor)
- **ligand.crd**   (coordinates of the ligand/inhibitor)
- **receptor.top** (topology of the receptor/protein)
- **receptor.crd** (coordinates of the receptor/protein)
- **complex.top**   (topology of the complex (receptor + ligand) in vacuum)
- **complex.crd**   (coordinates of the complex (receptor + ligand) in vacuum)
- **complex.pdb**   (pdb file of the complex (receptor + ligand) in vacuum for visualization in programs)
- **complex_box.top** (topology of the solvated complex (receptor + ligand) with water)
- **complex_box.crd** (coordinates of the solvated complex (receptor + ligand) with water)
- **complex_box.pdb** (pdb file of the solvated complex (receptor + ligand) with water for visualization in programs)

End of the AMBER protocol.
---------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------

### CHARMM-GUI Protocol

1) Calculate the correct protonation states for the system.
   Use the pdb2pqr server (https://server.poissonboltzmann.org/pdb2pqr) -> result *.pqr
   Use the H++ server (http://newbiophysics.cs.vt.edu/H++/)

2) Prepare the ligand.
   Same frozen opt process as the AMBER protocol, but the charges and parameters will be calculated by the server 
   (https://cgenff.silcsbio.com/)

The peculiarity in this case is to convert the output of the frozen opt to mol2 instead of pdb:
```bash
obabel -i log ligand_opt.log -o mol2 -O ligand_opt.mol2
```

The result should be divided into two files:
- **ligand.rtf**
  - starts with:
  ```
  * Topologies generated by
  ```
  - ends with:
  ```
  END
  ```

- **ligand.prm**
  - starts with:
  ```
  * Parameters generated by analogy by
  ```
  - ends with:
  ```
  END
  ```

Do not forget to replace the residue name with a three-letter uppercase code in both files and also add a chain for the ligand, e.g., PET B 101.

3) The formation of the complex should be done by joining the receptor.pqr and ligand.pdb files, which can be done using:
```bash
cat receptor.pqr ligand.pdb >> complex.pqr
```
Make sure the file is correct!

Finally, the construction of the input files for dynamics production will be done through CHARMM-GUI (https://www.charmm-gui.org/) in the input generator > solution builder options, where the complex.pqr file will be inserted.

...
The following protocol consists of 7 minimization steps, which can be duplicated (recommended), 10 steps of heating and equilibration, and a production run of 100 ns of simulation, which can be modified depending on

 the needs.

The system will be fully minimized and equilibrated up to step 9, where it will be differentiated into replicas. Each replica will start with the tenth step of independent heating/equilibration, ensuring different initial velocities for each replica.

**NOTE:**
-------------------------------------------------------------------------------------------------------------------
##                  Heating and Equilibration in 10 Steps:
| STEP    | TEMPERATURE (in Kelvin) | TIME   | SYSTEM_TYPE             |
|---------|--------------------------|--------|-------------------------|
| equil 1 | 0                        | 100 K  | 20 ps                   | NVT = Constant volume
| equil 2 | 100                      | 100 K  | 1 ns                    | NPT = Constant pressure
| equil 3 | 100                      | 125 K  | 1 ns                    | NPT = Constant pressure
| equil 4 | 125                      | 150 K  | 1 ns                    | NPT = Constant pressure
| equil 5 | 150                      | 175 K  | 1 ns                    | NPT = Constant pressure
| equil 6 | 175                      | 200 K  | 1 ns                    | NPT = Constant pressure
| equil 7 | 200                      | 225 K  | 1 ns                    | NPT = Constant pressure
| equil 8 | 225                      | 250 K  | 1 ns                    | NPT = Constant pressure
| equil 9 | 250                      | 275 K  | 1 ns                    | NPT = Constant pressure
| equil 10| 275                      | 300 K  | 5 ns                    | NPT = Constant pressure

## Production:
### In this step, DM will occur every 10 ns until 100 ns or more (the duration of DM can vary).
### For this, the prod.in file must have specific conditions for it to run for 10 ns:
### nstlim=5000000, dt=0.002,
### Multiply the values of nstlim * dt to know the time in ps, e.g.,
### 5000000 * 0.002 = 10000 ps = 10 ns

The files to launch the replicas are in the scripts folder, but remember to check the names of the files before starting.
-------------------------------------------------------------------------------------------------------------------

## Credits
Written by: Carlos Gabriel da Silva de Souza
Adapted from the AMBER protocol by Clauber Costa
Email for contact: carlosss_gabriel@hotmail.com
