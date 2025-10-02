#!/bin/bash

# Declare an associative array to store the shark attack records.
# The key will be the Area/State Name, and the value will be a JSON-formatted string
# containing all the details for all attacks in that area.
declare -A area_records
CSV_FILE="shark_data.csv"

# Function to load data from the CSV file
load_data() {
    echo "Loading detailed shark attack data from $CSV_FILE..."
    
    if [ ! -f "$CSV_FILE" ]; then
        echo "Error: Data file '$CSV_FILE' not found. Please ensure it is in the same directory." >&2
        exit 1
    fi

    # 1. Use awk to extract the 11 required columns and pipe the output.
    # We use a placeholder character (|) to separate the fields for easier reading later.
    awk_output=$(tail -n +2 "$CSV_FILE" | awk -F',' '
        { 
            # Columns (indices start at 1 in awk): 1, 2, 3, 5, 6, 7, 9, 10, 11, 12, 14
            # We use column 6 ($6) as the Area/State key.
            print $1 "|" $2 "|" $3 "|" $5 "|" $6 "|" $7 "|" $9 "|" $10 "|" $11 "|" $12 "|" $14 
        }'
    )

    # 2. Loop through the formatted awk output line by line.
    # IFS='|' is set to use the pipe character as the field separator.
    while IFS='|' read -r case_number date year country area location name sex age injury fatal; do
        
        # Trim leading/trailing whitespace from the Area name
        area=$(echo "$area" | awk '{$1=$1};1')
        
        if [[ -n "$area" ]]; then
            # Construct a single string containing all the extracted details for this attack
            record_details="Date: $date | Year: $year | Country: $country | Location: $location | Victim: $name | Sex: $sex | Age: $age | Injury: $injury | Fatal: $fatal"
            
            # Append the new record to the array key corresponding to the Area/State.
            # We use the newline character (\n) as a separator between multiple records in the same Area.
            if [[ -v area_records["$area"] ]]; then
                # Append to existing records
                area_records["$area"]+="\n$record_details"
            else
                # Start a new record list for this Area
                area_records["$area"]="$record_details"
            fi
        fi
    done <<< "$awk_output"
    
    echo "Data load complete. Loaded records for ${#area_records[@]} distinct areas."
}

# Function to format input to Title Case (e.g., "florida" -> "Florida")
format_input() {
    echo "$1" | sed 's/\b[a-z]/\U&/g'
}

# Function to handle user input and processing with a persistent validation loop
process_shark_query() {
    local state_input
    local formatted_input
    local records
    
    echo "--------------------------------------------------------"
    
    # Start the persistent input loop
    while true; do
        read -p "Enter a State/Area (e.g., Florida, Hawaii) to view detailed attack reports: " state_input

        # Format input for lookup
        formatted_input=$(format_input "$state_input")

        # Check if the formatted state exists as a key in our loaded array
        if [[ -v area_records["$formatted_input"] ]]; then
            records=${area_records["$formatted_input"]}
            break # Valid area found: exit the loop
        else
            echo "Try to spell the state name correct."
        fi
    done

    # --- Process Valid State ---
    
    # Count the number of records (attacks) for the area
    local num_attacks
    num_attacks=$(echo -e "$records" | grep -c "Date: ")
    
    echo "--------------------------------------------------------"
    echo "REPORT FOR: $formatted_input ($num_attacks Attacks)"
    echo "--------------------------------------------------------"

    if [[ "$num_attacks" -gt 0 ]]; then
        # Print all the stored records, separated by newlines
        echo -e "$records"
        
        # Ask the follow-up question
        local see_locations
        read -p "Would you like to see where? (Y/N): " see_locations
        
        case "$see_locations" in
            [Yy]* )
                echo "Displaying the general locations within $formatted_input..."
                # The 'Location' is already printed above in the detailed records.
                ;;
            [Nn]* )
                echo "Okay, report complete."
                ;;
            * )
                echo "Invalid input. Assuming No."
                ;;
        esac
    else
        echo "This area has records in the database but reports 0 attacks."
    fi
}

# --- Main Execution ---
load_data
process_shark_query
