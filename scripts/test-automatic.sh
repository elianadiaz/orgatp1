#!/bin/bash

echo "##############################################################################"
echo "########################## Tests automaticos  ################################"
echo "##############################################################################"


echo "###----------###    COMIENZA test ejercicio 1 del informe.    ###----------###"
echo "###----------###        STDIN ::: FILE OUTPUT                 ###----------###"

./tp1 -i - -o ./outputs/outputInformeEjemplo1.txt < ./inputs/inputInformeEjemplo1.txt

if diff -b ./outputs-aut/outputInformeEjemplo1-aut.txt ./outputs/outputInformeEjemplo1.txt;
 then echo "OK";
 else
 	echo ERROR;
fi

echo "###----------###    FIN test ejercicio 1 del informe.         ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###    COMIENZA test ejercicio 2 del informe.    ###----------###"
echo "###----------###        FILE INPUT ::: STDOUT                 ###----------###"

./tp1 -i ./inputs/inputInformeEjemplo2.txt -o - > ./outputs/outputInformeEjemplo2.txt

if diff -b ./outputs-aut/outputInformeEjemplo2-aut.txt ./outputs/outputInformeEjemplo2.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###    FIN test ejercicio 2 del informe.         ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###    COMIENZA test con -i - -o -               ###----------###"
echo "###----------###        STDIN ::: STDOUT                      ###----------###"

./tp1 -i - -o - <./inputs/inputInformeEjemplo2.txt > ./outputs/outputInformeEjemplo2.txt

if diff -b ./outputs-aut/outputInformeEjemplo2-aut.txt ./outputs/outputInformeEjemplo2.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###    FIN test con -i - -o -                    ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###    COMIENZA test palabras con acentos        ###----------###"

./tp1 -i ./inputs/input0.txt -o ./outputs/output0.txt

if diff -b ./outputs-aut/output0-aut.txt ./outputs/output0.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###    FIN test palabras con acentos             ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###    COMIENZA test con caritas                 ###----------###"

./tp1 -i ./inputs/input1.txt -o ./outputs/output1.txt

if diff -b ./outputs-aut/output1-aut.txt ./outputs/output1.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###    FIN test con caritas                      ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###    COMIENZA test con entrada estandar        ###----------###"

./tp1 --output ./outputs/outputStdin.txt < ./inputs/inputStdin.txt

if diff -b ./outputs-aut/outputStdin-aut.txt ./outputs/outputStdin.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###    FIN test con entrada estandar             ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###    COMIENZA test con salida estandar         ###----------###"

./tp1 --input ./inputs/inputStdout.txt > ./outputs/outputStdout.txt

if diff -b ./outputs-aut/outputStdout-aut.txt ./outputs/outputStdout.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###    FIN test con salida estandar              ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###  COMIENZA test con entrada y salida estanda  ###----------###"

./tp1 < ./inputs/inputStdinStdout.txt > ./outputs/outputStdinStdout.txt

if diff -b ./outputs-aut/outputStdinStdout-aut.txt ./outputs/outputStdinStdout.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###  FIN test con entrada y salida estanda       ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###  COMIENZA test menu version (-V)             ###----------###"

./tp1 -V > ./outputs/outputMenuV.txt

if diff -b ./outputs-aut/outputMenuVersion-aut.txt ./outputs/outputMenuV.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###  FIN test menu version (-V)                  ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###  COMIENZA test menu version (--version)      ###----------###"

./tp1 --version > ./outputs/outputMenuVersion.txt

if diff -b ./outputs-aut/outputMenuVersion-aut.txt ./outputs/outputMenuVersion.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###  FIN test menu version (--version)           ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###  COMIENZA test menu help (-h)                ###----------###"

./tp1 -h > ./outputs/outputMenuH.txt

if diff -b ./outputs-aut/outputMenuHelp-aut.txt ./outputs/outputMenuH.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###  FIN test test menu help (-h)                ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "###----------###  COMIENZA test menu help (--help)            ###----------###"

./tp1 --help > ./outputs/outputMenuHelp.txt

if diff -b ./outputs-aut/outputMenuHelp-aut.txt ./outputs/outputMenuHelp.txt; then echo "OK"; else
		echo ERROR;
fi

echo "###----------###  FIN test menu help (--help)                 ###----------###"

echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"
echo "###------------------------------------------------------------------------###"

echo "##############################################################################"
echo "########################## Tests automaticos  ################################"
echo "##############################################################################"
#################################################################################################
#echo "#----------# COMIENZA test con /-o -i - #----------#"

#./tp0 -o -i - <./inputs/inputInformeEjemplo2.txt > ./outputs/outputInformeEjemplo2.txt

#if diff -b ./outputs-aut/outputInformeEjemplo2-aut.txt ./outputs/outputInformeEjemplo2.txt; then echo "OK"; else
#		echo ERROR;
#fi

#echo "#----------# FIN test con /-o -i - #----------#"

#echo "#-----------------------------------------------------#"
