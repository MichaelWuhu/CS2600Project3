#!/bin/csh

# Check if the correct number of arguments is provided
if ($#argv != 1) then
    echo "Error: Please specify the filename."
    echo "Usage: $0 <filename>"
    exit
endif

# Assign the input filename to a variable
set filename = $argv[1]

# Check if the file exists
if (! -f "$filename") then
    echo "File not found!"
    exit
endif

# Main menu
while (1)
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
    echo "Choose an option: "
    set choice = $<

    # Switch case to handle user input choice
    switch ($choice)
        # Case 1: List records alphabetically by first name
        case 1:
            sort -t ' ' -k1 "$filename"
            breaksw
        # Case 2: List records alphabetically by last name
        case 2:
            sort -t ' ' -k2 "$filename"
            breaksw
        # Case 3: List records in reverse alphabetical order by first name
        case 3:
            sort -r -t ' ' -k1 "$filename"
            breaksw
        # Case 4: List records in reverse alphabetical order by last name
        case 4:
            sort -r -t ' ' -k2 "$filename"
            breaksw
        # Case 5: Search for a record by last name
        case 5:
            # Get user input for last name to search for
            echo "Enter last name: "
            set last_name = $<
            # Search last name
            awk -F ':' -v lname="$last_name" '{ split($1, name_parts, " "); if (tolower(name_parts[2]) == tolower(lname)) { print $0; } }' "$filename"
            breaksw
        # Case 6: Search for records by birthday (month or year)
        case 6:
            # Get user input for month or year to search for
            echo "Enter month or year to search for (e.g., MM or YYYY): "
            set query = $<

            # Check if the query is a 2-digit month or a 4-digit year
            set query_length = `expr length $query`
            # echo "query length: $query_length"
            if ( $query_length == 2 || $query_length == 1) then
                awk -F ':' -v query="$query" '{ split($4, date_parts, "/"); month = date_parts[1]; if (month == query) { print $0; } }' "$filename"
            else if ( $query_length == 4 ) then
                set last2query = `echo $query | tail -c 3`
                # Handle searching full year and last 2 digits of year
                awk -F ':' -v query="${last2query}" '{ split($4, date_parts, "/"); year = date_parts[3]; if (year == query) { print $0; } }' "$filename"
                awk -F ':' -v query="${query}" '{ split($4, date_parts, "/"); year = date_parts[3]; if (year == query) { print $0; } }' "$filename"
            else
                echo "Invalid query format. Please enter a 2-digit month or 4-digit year."
            endif
            breaksw
        # Case 7: Exit
        case 7:
            echo "Exiting..."
            exit
            breaksw
        # Default case: Invalid option
        default:
            echo "Invalid option. Please try again."
            breaksw
    endsw
end
