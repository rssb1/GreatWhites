#!/bin/bash

# --- CONFIGURATION ---
# IMPORTANT FIX: Ensure this points to your file with the detailed records.
CSV_FILE="shark_data.csv"
# ---------------------

# Function to format input to Title Case (e.g., florida -> Florida)
format_input() {
    # Handles multi-word states (e.g., "south carolina" -> "South Carolina")
    echo "$1" | sed 's/\b[a-z]/\U&/g'
}

# Load and query data
process_shark_query() {
    local state_input formatted_input num_attacks see_more

    # Check for file existence before starting the loop
    if [[ ! -f "$CSV_FILE" ]]; then
        echo "Error: $CSV_FILE not found in current directory. Please check the file name." >&2
        return 1
    fi

    echo "--- Shark Attack Reporter Loaded ---"
    
    while true; do
        read -p "Enter a State/Area (e.g., Florida, Hawaii) to check: " state_input
        formatted_input=$(format_input "$state_input")

        # FIX: The AWK command now aggressively trims whitespace from $6 (Area)
        # using the 'gsub' function before comparison. This ensures hidden spaces don't prevent a match.
        # It then counts the records matching the trimmed Area.
        num_attacks=$(awk -F',' -v area="$formatted_input" '
            BEGIN { count = 0 }
            NR>1 { 
                # Trim leading/trailing whitespace from Column 6 (Area)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", $6);
                if ($6 == area) {
                    count++;
                }
            }
            END { print count }
        ' "$CSV_FILE")

        if [[ "$num_attacks" -gt 0 ]]; then
            echo "--------------------------------------------------------"
            echo "REPORT FOR: $formatted_input"
            echo "Number of attacks: $num_attacks"
            echo "--------------------------------------------------------"
            
            read -p "Would you like to see details? (Y/N): " see_more
            
            case "$see_more" in
                [Yy]* )
                    echo "Date | Year | Location | Activity | Injury | Fatal"
                    echo "------------------------------------------------------------------------------------------------"
                    
                    # Print the detailed records for the matched Area
                    awk -F',' -v area="$formatted_input" '
                        NR>1 {
                            # Re-trim $6 for printing logic
                            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $6);
                            
                            if ($6 == area) {
                                # Printing selected columns:
                                # $2=Date, $3=Year, $7=Location, $8=Activity, $10=Sex, $11=age, $12=Injury, $13=Fatal (Y/N)
                                printf "%s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s\n",
                                $2,$4,$6,$7,$8,$10,$11,$12,$13,$14,$15
                            }
                        }' "$CSV_FILE"
                    ;;
                * )
                    echo "Okay, report complete."
                    ;;
            esac
            break # Exit the loop after successful query
        else
            # If the count is 0, the loop continues and prompts again
            echo "No records found for '$state_input' in the Area column. Try to spell the state name correct."
        fi
    done
}

# --- Main Execution ---
process_shark_query
