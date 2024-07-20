#!/bin/bash

# Parse command-line arguments
while getopts "d:c:" flag; do
    case "${flag}" in
        d) domain=${OPTARG};;
        c) cookie=${OPTARG};;
    esac
done

# Perform subdomain enumeration
echo "Enumerating subdomains for $domain..."
subfinder -d $domain | tee subdomains.txt

# Perform HTTP probing
echo "Probing HTTP endpoints..."
httpx -l subdomains.txt -o httpx.txt

# Identify endpoints with potential XSS
echo "Identifying endpoints with potential XSS..."
cat httpx.txt | gau --threads 5 >> endpoints.txt
cat endpoints.txt | gf xss >> potential_xss.txt

# Perform authenticated XSS testing with dalfox
echo "Performing authenticated XSS testing with dalfox..."

# Prepare a file containing the XSS endpoints
cat potential_xss.txt | cut -d ':' -f 2-3 | sed 's/^\/\///' | sed 's/:/\//' | sort -u > xss_endpoints.txt

# Iterate through each endpoint and test with dalfox
while IFS= read -r endpoint; do
    echo "Testing endpoint: $endpoint"
    torsocks dalfox url "https://$endpoint" \
                      --cookie "$cookie" \
                      --skip-bav \
                      --follow-redirect \
                      -o "dalfox_output_$endpoint.txt"
done < xss_endpoints.txt

# Cleanup temporary files
echo "Cleaning up..."
rm subdomains.txt
rm httpx.txt
rm endpoints.txt
rm potential_xss.txt
rm xss_endpoints.txt

echo "Script execution completed."
