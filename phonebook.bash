#!/bin/bash

# Function to validate a single record
validate_record() {
    local record="$1"

    IFS=':' read -r -a fields <<< "$record"

    if [[ ${#fields[@]} -ne 6 ]]; then
        echo "Invalid record: Incorrect number of fields"
        return 1
    fi

    local name="${fields[0]}"
    local home_phone="${fields[1]}"
    local mobile_phone="${fields[2]}"
    local address="${fields[3]}"
    local birth_date="${fields[4]}"
    local salary="${fields[5]}"

    if ! [[ $name =~ ^[A-Za-z]+\s[A-Za-z]+$ ]]; then return 1; fi
    if ! [[ $home_phone =~ ^[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]; then return 1; fi
    if ! [[ $mobile_phone =~ ^[0-9]{10}$ ]]; then return 1; fi
    if [[ -z $address ]]; then return 1; fi
    if ! [[ $birth_date =~ ^(0[1-9]|1[0-2])/(0[1-9]|[12][0-9]|3[01])/[0-9]{4}$ ]]; then return 1; fi
    if ! [[ $salary =~ ^[0-9]+(\.[0-9]{1,2})?$ ]]; then return 1; fi

    return 0
}

# Function to validate the entire file
validate_file() {
    local file="$1"
    local valid=true

    while IFS= read -r line; do
        if ! validate_record "$line"; then
            echo "Invalid record: $line"
            valid=false
        fi
    done < "$file"

    $valid
}

# Function to list records alphabetically by first or last name
list_records() {
    local file="$1"
    local field="$2" # 0 for first name, 1 for last name

    sort -t ' ' -k$((field + 1)) "$file"
}

# Function to list records in reverse alphabetical order
list_records_reverse() {
    local file="$1"
    local field="$2" # 0 for first name, 1 for last name

    sort -r -t ' ' -k$((field + 1)) "$file"
}

# Function to search for a record by last name
search_by_last_name() {
    local file="$1"
    local last_name="$2"

    awk -F ':' -v lname="$last_name" '
    {
        split($1, name_parts, " ");
        if (tolower(name_parts[2]) == tolower(lname)) {
            print $0;
        }
    }
    ' "$file"
}

# Function to search for records by birth month or year
search_by_birthday() {
    local file="$1"
    local query="$2"

    awk -F ':' -v query="$query" '
    BEGIN { IGNORECASE = 1 }
    $5 ~ query { print $0 }
    ' "$file"
}

# Main menu
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
            list_records "records.txt" 0
            ;;
        2)
            list_records "records.txt" 1
            ;;
        3)
            list_records_reverse "records.txt" 0
            ;;
        4)
            list_records_reverse "records.txt" 1
            ;;
        5)
            read -p "Enter last name: " last_name
            search_by_last_name "records.txt" "$last_name"
            ;;
        6)
            read -p "Enter month or year to search for (e.g., MM or YYYY): " query
            search_by_birthday "records.txt" "$query"
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
