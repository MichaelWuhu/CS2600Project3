#!/bin/csh

# Function to validate a single record
function validate_record {
    set record = "$1"
    set fields = (`echo $record | awk -F':' '{for (i=1; i<=NF; i++) print $i}'`)

    if ($#fields != 6) then
        echo "Invalid record: Incorrect number of fields"
        return 1
    endif

    set name = "$fields[1]"
    set home_phone = "$fields[2]"
    set mobile_phone = "$fields[3]"
    set address = "$fields[4]"
    set birth_date = "$fields[5]"
    set salary = "$fields[6]"

    if ("$name" !~ *[A-Za-z]*\ *[A-Za-z]*) return 1
    if ("$home_phone" !~ [0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]) return 1
    if ("$mobile_phone" !~ [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) return 1
    if ("$address" == "") return 1
    if ("$birth_date" !~ [0-1][0-9]/[0-3][0-9]/[0-9][0-9][0-9][0-9]) return 1
    if ("$salary" !~ [0-9]*"."[0-9][0-9] && "$salary" !~ [0-9]*) return 1

    return 0
}

# Function to validate the entire file
function validate_file {
    set file = "$1"
    set valid = 1

    foreach line (`cat $file`)
        validate_record "$line"
        if ($status != 0) then
            echo "Invalid record: $line"
            set valid = 0
        endif
    end

    return $valid
}

# Function to list records alphabetically
function list_records {
    set file = "$1"
    set field = "$2"

    if ($field == 0) then
        sort -t' ' -k1 "$file"
    else
        sort -t' ' -k2 "$file"
    endif
}

# Function to list records in reverse alphabetical order
function list_records_reverse {
    set file = "$1"
    set field = "$2"

    if ($field == 0) then
        sort -r -t' ' -k1 "$file"
    else
        sort -r -t' ' -k2 "$file"
    endif
}

# Function to search for a record by last name
function search_by_last_name {
    set file = "$1"
    set last_name = "$2"

    awk -F':' -v lname="$last_name" '
    {
        split($1, name_parts, " ");
        if (tolower(name_parts[2]) == tolower(lname)) {
            print $0;
        }
    }
    ' "$file"
}

# Function to search for records by birth month or year
function search_by_birthday {
    set file = "$1"
    set query = "$2"

    awk -F':' -v query="$query" '
    BEGIN { IGNORECASE = 1 }
    $5 ~ query { print $0 }
    ' "$file"
}

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
    echo -n "Choose an option: "
    set choice = $<

    switch ($choice)
        case 1:
            list_records "records.txt" 0
            breaksw
        case 2:
            list_records "records.txt" 1
            breaksw
        case 3:
            list_records_reverse "records.txt" 0
            breaksw
        case 4:
            list_records_reverse "records.txt" 1
            breaksw
        case 5:
            echo -n "Enter last name: "
            set last_name = $<
            search_by_last_name "records.txt" "$last_name"
            breaksw
        case 6:
            echo -n "Enter month or year to search for (e.g., MM or YYYY): "
            set query = $<
            search_by_birthday "records.txt" "$query"
            breaksw
        case 7:
            echo "Exiting..."
            exit 0
            breaksw
        default:
            echo "Invalid option. Please try again."
            breaksw
    endsw
end
