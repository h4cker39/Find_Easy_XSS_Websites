#/bin/sh

#Better way of finding XSS vulnerabilites
#Using Gau (Wayback machine endpoints obsolete, crawling and live host)
#Script by Luis C F Giordano
#FR0$T
#
#


subfinder -d $1 | tee subfinder.txt

httpx -l subfinder.txt -o httpx.txt

echo $1 | gau --threads 5 >> Endpoints.txt

cat httpx.txt | katana -jc >> Endpoints.txt

cat Enpoints.txt | uro >> Endpoints_F.txt

cat Endpoints_F.txt | gf xss >> XSS.txt

cat XSS.txt | Gxss -p khXSS -o XSS_Ref.txt

dalfox file XSS_Ref.txt -o Vulnerable_XSS.txt
