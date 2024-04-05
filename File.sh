#/bin/sh
 
#Better way of finding XSS vulnerabilites
#Using Gau (Wayback machine endpoints obsolete, crawling and live host)
#Script by Luis C F Giordano
#FR0$T
#
#
while getopts d: flag
do
    case "${flag}" in
        d) domain=${OPTARG};;
    esac
done
echo "target is: $domain";
subfinder -d $domain | tee subfinder.txt
httpx -l subfinder.txt -o httpx.txt
echo $domain | gau --threads 5 >> Endpoints.txt
cat httpx.txt | katana -jc >> Endpoints.txt
cat Endpoints.txt | uro >> Endpoints_F.txt
cat Endpoints_F.txt | gf xss >> XSS.txt
cat XSS.txt | Gxss -p khXSS -o XSS_Ref.txt
torsocks dalfox file XSS_Ref.txt -o Vulnerable_XSS.txt
 
#clean up
 
#
rm Endpoints.txt
rm subfinder.txt
rm Vulnerable_XSS.txt
rm XSS.txt 
 
rm Endpoints_F.txt
rm Endpoints.txt
