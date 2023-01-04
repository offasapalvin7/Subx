#!/bin/bash

# Set default values for command-line options
api_endpoint="https://api.subdomain.service/v1/check"
output_format="text"

# Parse command-line options
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -a|--api-endpoint)
        api_endpoint="$2"
        shift
        shift
        ;;
        -o|--output-format)
        output_format="$2"
        shift
        shift
        ;;
        -h|--help)
        echo "Usage: takeover.sh [OPTIONS] SUBDOMAIN"
        echo "Options:"
        echo "  -a, --api-endpoint    Specify the API endpoint to use"
        echo "  -o, --output-format   Specify the output format (text, json)"
        echo "  -h, --help            Display this help message"
        exit 0
        ;;
        *)
        subdomain="$1"
        shift
        ;;
    esac
done

# Check if a subdomain was provided
if [ -z "$subdomain" ]
then
    echo "Error: No subdomain provided."
    echo "Usage: takeover.sh [OPTIONS] SUBDOMAIN"
    exit 1
fi

# Check if the subdomain is available for takeover
response=$(curl -s -o /dev/null -w "%{http_code}" "$api_endpoint?name=$subdomain")

if [ "$response" = "200" ]
then
    # Check for matching fingerprints
    fingerprints=$(curl -s "$api_endpoint?name=$subdomain")
    if [ "$fingerprints" = "\"No known fingerprints for this subdomain.\"" ]
    then
        if [ "$output_format" = "json" ]
        then
            # Output results in JSON format
            printf "{\"subdomain\":\"$subdomain\",\"status\":\"not_vulnerable\"}\n"
        else
            # Output results in text format
            echo "Subdomain is not available for takeover."
        fi
    else
        if [ "$output_format" = "json" ]
        then
            # Output results in JSON format
            printf "{\"subdomain\":\"$subdomain\",\"status\":\"vulnerable\",\"fingerprints\":$fingerprints}\n"
        else
            # Output results in text format
            echo "Subdomain is potentially vulnerable to takeover."
            echo "Matching fingerprints: $fingerprints"
        fi
    fi
else
    if [ "$output_format" = "json"
