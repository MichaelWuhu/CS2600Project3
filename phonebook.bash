#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
    echo "Error: Please specify the filename."
    echo "Usage: $0 <filename>"
    exit 
fi

# Assign the input filename to a variable
filename=$1

# Check if the file exists
if [ ! -f "$filename" ]; then
    echo "File not found!"
    exit
fi

# Main menu
while true; do
    # Print menu
    echo "Menu Options:"
    echo "1. List records alphabetically by first name"
    echo "2. List records alphabetically by last name"
    echo "3. List records in reverse alphabetical order by first name"
    echo "4. List records in reverse alphabetical order by last name"
    echo "5. Search for a record by last name"
    echo "6. Search for records by birthday (month or year)"
    echo "7. Exit"
    # Get user input choice
    read -p "Choose an option: " choice

    # Switch case to handle user input choice
    case $choice in
    # Case 1: List records alphabetically by first name
    1)
        sort -t ' ' -k1 "$filename"
        ;;
    # Case 2: List records alphabetically by last name
    2)
        sort -t ' ' -k2 "$filename"
        ;;
    # Case 3: List records in reverse alphabetical order by first name
    3)
        sort -r -t ' ' -k1 "$filename"
        ;;
    # Case 4: List records in reverse alphabetical order by last name
    4)
        sort -r -t ' ' -k2 "$filename"
        ;;
    # Case 5: Search for a record by last name
    5)
        # Get user input for last name to search for
        read -p "Enter last name: " last_name
        # Search last name
        awk -F ':' -v lname="$last_name" '
            {
                split($1, name_parts, " ");
                if (tolower(name_parts[2]) == tolower(lname)) {
                    print $0;
                }
            }
            ' "$filename"
        ;;
    # Case 6: Search for records by birthday (month or year)
    6)
        # Get user input for month or year to search for
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
            # Handle searching full year and last 2 digits of year
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
    # Case 7: Exit
    7)
        echo "Exiting..."
        exit
        ;;
    # Default case: Invalid option
    *)
        echo "Invalid option. Please try again."
        ;;
    esac
done
