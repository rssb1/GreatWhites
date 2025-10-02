#!/bin/bash

# Declare an associative array to store the data read from the CSV file
declare -A shark_attacks
CSV_FILE="shark_data.csv"

# Function to load data from the CSV file into the associative array
# This function is flexible and handles CSV files with more than two columns.
load_data() {
    echo "Loading shark attack data from $CSV_FILE..."
    
    # Check if the CSV file exists
    if [ ! -f "$CSV_FILE" ]; then
        echo "Error: Data file '$CSV_FILE' not found. Please ensure it is in the same directory." >&2
        exit 1
    fi
    
    # Read the CSV file line by line
    # KEY CHANGE: IFS=',' sets the Internal Field Separator to a comma.
    # The process substitution (< <(...)) ensures array updates persist.
    # tail -n +2 skips the header line.
    # 'read -r state count ignore' captures the first two columns, and 'ignore' takes the rest.
    while IFS=',' read -r state count ignore; do
        
        # Trim leading/trailing whitespace from the state name and count
        # This is important as some shells/OS combinations might introduce hidden spaces.
        state=$(echo "$state" | awk '{$1=$1};1')
        count=$(echo "$count" | awk '{$1=$1};1')
        
        # Only process lines where the state name is not empty
        if [[ -n "$state" ]]; then
            # Store the data: State Name (key) = Attack Count (value)
            shark_attacks["$state"]=$count
        fi
    done < <(tail -n +2 "$CSV_FILE")
    
    echo "Data load complete. Loaded ${#shark_attacks[@]} states."
}

# Function to handle user input and processing with a persistent validation loop
process_shark_query() {
    local state_input
    local formatted_input
    local count
    local see_locations

    # Start a loop that runs indefinitely until a valid state is found (using 'break')
    while true; do
        # 1. Get User Input
        read -p "Please enter a state name to check for shark attacks: " state_input

        # 2. Format Input
        # Capitalize the first letter of each word (e.g., "south carolina" -> "South Carolina").
        formatted_input=$(echo "$state_input" | sed 's/\b[a-z]/\U&/g')

        # 3. Validation Check: Does the formatted state exist as a key in our loaded array?
        if [[ -v shark_attacks["$formatted_input"] ]]; then
            count=${shark_attacks["$formatted_input"]}
            break # Valid state found: exit the 'while true' loop
        else
            # Invalid state: print the error and the loop continues (runs again).
            echo "Try to spell the state name correct."
        fi
    done

    # --- Process Valid State ---

    # Check if the number of attacks is greater than 0.
    if [[ "$count" -gt 0 ]]; then
        echo "--------------------------------------------------------"
        echo "ALERT: There are $count shark attacks in $formatted_input."
        
        # Ask the follow-up question.
        read -p "Would you like to see where? (Y/N): " see_locations
        
        # Handle the Y/N response using a case statement.
        case "$see_locations" in
            [Yy]* )
                echo "Displaying the locations for $formatted_input..."
                # You would add code here to display specific locations.
                ;;
            [Nn]* )
                echo "Okay, staying safe."
                ;;
            * )
                echo "Invalid input. Assuming No."
                ;;
        esac
    else
        # This handles states with a count of 0.
        echo "This area has no shark attacks."
    fi
}

# --- Main Execution ---
# 1. Load the data from the CSV file
load_data

# 2. Start the interactive query process
process_shark_query
