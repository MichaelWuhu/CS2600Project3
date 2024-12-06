#!/bin/bash

# Main menu
if [ $# -ne 1 ]; then
    echo "Error: Please specify the filename."
    echo "Usage: $0 <filename>"
    exit 
fi

filename=$1

# Check if the file exists
if [ ! -f "$filename" ]; then
    echo "File not found!"
    exit 1
fi


while true; do
    echo "Menu Options:"
    echo "1. List records alphabetically by first name"
    echo "2. List records alphabetically by last name"
    echo "3. List records in reverse alphabetical order by first name"
    echo "4. List records in reverse alphabetical order by last name"
    echo "5. Search for a record by last name"
    echo "6. Search for records by birthday (month or year)"
    echo "7. Exit"
    read -p "Choose an option: " choice

    case $choice in
    1)
        sort -t ' ' -k1 "$filename"
        ;;
    2)
        sort -t ' ' -k2 "$filename"
        ;;
    3)
        sort -r -t ' ' -k1 "$filename"
        ;;
    4)
        sort -r -t ' ' -k2 "$filename"
        ;;
    5)
        read -p "Enter last name: " last_name
        awk -F ':' -v lname="$last_name" '
            {
                split($1, name_parts, " ");
                if (tolower(name_parts[2]) == tolower(lname)) {
                    print $0;
                }
            }
            ' "$filename"
        ;;
    6)
        read -p "Enter month or year to search for (e.g., MM or YYYY): " query

        # Check if the query is a 2-digit month or a 4-digit year
        if [[ ${#query} -eq 1 || ${#query} -eq 2 ]]; then
            awk -F ':' -v query="$query" '
            {
                split($4, date_parts, "/");
                month = date_parts[1];
                if (month == query) {
                    print $0;
                }
            }
            ' "$filename"
        elif [[ ${#query} -eq 4 ]]; then
            # If the query is 4 digits, search by year (last two digits)
            awk -F ':' -v query="${query:2:2}" '
                {
                    split($4, date_parts, "/");
                    year = date_parts[3];
                    if (year == query) {
                        print $0;
                    }
                }
                ' "$filename"
            awk -F ':' -v query="${query}" '
                {
                    split($4, date_parts, "/");
                    year = date_parts[3];
                    if (year == query) {
                        print $0;
                    }
                }
                ' "$filename"
            
        else
            echo "Invalid query format. Please enter a 2-digit month or 4-digit year."
        fi
        ;;
    7)
        echo "Exiting..."
        break
        ;;
    *)
        echo "Invalid option. Please try again."
        ;;
    esac
done
