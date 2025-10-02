#!/bin/bash

# Declare an associative array to store the data read from the CSV file
declare -A shark_attacks
CSV_FILE="shark_data_extended.csv"

# Function to load data from the CSV file into the associative array
load_data() {
    echo "Loading selective shark attack data from $CSV_FILE (Columns 1, 2, 3, 5, 6, 7, 9, 10, 11, 12, 14)..."
    
    # Check if the CSV file exists
    if [ ! -f "$CSV_FILE" ]; then
        echo "Error: Data file '$CSV_FILE' not found. Please ensure it is in the same directory." >&2
        exit 1
    fi
    
    # The process below first uses 'awk' to extract and reformat ONLY the required columns (1, 2, 3, 5, 6, 7, 9, 10, 11, 12, 14), 
    # separated by commas. The output is then piped to the 'while read' loop.
    
    # Define the list of variables to match the 11 selected columns from AWK
    # We only need 'state' and 'attacks' for the core logic; the rest are read for demonstration.
    local awk_output
    
    awk_output=$(tail -n +2 "$CSV_FILE" | awk -F',' '
        { 
            # Reconstruct the line using only the required column indices
            print $1 "," $2 "," $3 "," $5 "," $6 "," $7 "," $9 "," $10 "," $11 "," $12 "," $14 
        }'
    )

    # Use a here-string to feed the awk output into the read loop
    while IFS=',' read -r state attacks c3 c5 c6 c7 c9 c10 c11 c12 c14; do
        
        # Trim leading/trailing whitespace
        state=$(echo "$state" | awk '{$1=$1};1')
        attacks=$(echo "$attacks" | awk '{$1=$1};1')
        
        # Only process lines where the state name is not empty
        if [[ -n "$state" ]]; then
            # We store the State (key) and the Attack Count (value) for the logic check.
            shark_attacks["$state"]=$attacks
            
            # Optional: Displaying the data read, showing that selective columns were chosen
            # echo "Loaded: $state | Attacks: $attacks | Species: $c10 | Victim: $c12"
        fi
    done <<< "$awk_output"
    
    echo "Data load complete. Loaded ${#shark_attacks[@]} states based on selected columns."
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
                # In a real application, you might use the other 9 columns (c3, c5, etc.) here.
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
