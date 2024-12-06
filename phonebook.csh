#!/bin/csh

# Main menu
while (1)
    echo "Menu Options:"
    echo "1. List records alphabetically by first name"
    echo "2. List records alphabetically by last name"
    echo "3. List records in reverse alphabetical order by first name"
    echo "4. List records in reverse alphabetical order by last name"
    echo "5. Search for a record by last name"
    echo "6. Search for records by birthday (month or year)"
    echo "7. Exit"
    set choice = $<
    echo "Choose an option: $choice"

    switch ($choice)
        case 1:
            sort -t ' ' -k1 "records.txt"
            breaksw
        case 2:
            sort -t ' ' -k2 "records.txt"
            breaksw
        case 3:
            sort -r -t ' ' -k1 "records.txt"
            breaksw
        case 4:
            sort -r -t ' ' -k2 "records.txt"
            breaksw
        case 5:
            echo "Enter last name: "
            set last_name = $<
            awk -F ':' -v lname="$last_name" '{ split($1, name_parts, " "); if (tolower(name_parts[2]) == tolower(lname)) { print $0; } }' "records.txt"
            breaksw
        case 6:
            echo "Enter month or year to search for (e.g., MM or YYYY): "
            set query = $<

            # Check if the query is a 2-digit month or a 4-digit year
            set query_length = `expr length $query`
            # echo "query length: $query_length"
            if ( $query_length == 2 || $query_length == 1) then
                awk -F ':' -v query="$query" '{ split($4, date_parts, "/"); month = date_parts[1]; if (month == query) { print $0; } }' "records.txt"
            else if ( $query_length == 4 ) then
                set query = `echo $query | tail -c 3`
                awk -F ':' -v query="${query}" '{ split($4, date_parts, "/"); year = date_parts[3]; if (year == query) { print $0; } }' "records.txt"
            else
                echo "Invalid query format. Please enter a 2-digit month or 4-digit year."
            endif
            breaksw
        case 7:
            echo "Exiting..."
            exit
        default:
            echo "Invalid option. Please try again."
            breaksw
    endsw
end
