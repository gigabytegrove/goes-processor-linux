#!/bin/bash

set -euo pipefail

SRC_DIR="/opt/goes/EMWIN"
OUT_DIR="/var/www/goes/images"

DEBUG=0
DAYS_BACK=3
CATEGORY=""
CODES=""

usage() {
    cat <<EOF
Usage:
  $0 --radar [--code CODE1,CODE2,...] [--days N] [--debug]
  $0 --satellite [--code CODE1,CODE2,...] [--days N] [--debug]
  $0 --advisories [--code CODE1,CODE2,...] [--days N] [--debug]

Options:
  --code   Comma separated EMWIN codes to process (subset of category)
  --days   How many days back to process (default: 3)
  --debug  Enable debug output

Examples:
  $0 --radar --debug
  $0 --radar --code RADALLAK,RADRCKNT --days 3 --debug
  $0 --satellite --days 14
EOF
    exit 1
}

log_debug() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "[DEBUG] $*"
    fi
}

# Official EMWIN product codes by category
declare -A CATEGORY_CODES
CATEGORY_CODES[radar]="RADALLAK RADALLGU RADALLHI RADALLPR RADGRTLK RADNTHES RADPACNW RADPACSW RADRCKNT RADRCKST RADREFUS RADSMSVY RADSTHES RADSTHPL RADUMSVY"
CATEGORY_CODES[satellite]="G02HURUS G10CIRUS G10FDIUS G16CIRUS INDCIRUS GMS008JA IMGSJUPR IMGWWAUS"
CATEGORY_CODES[surface_analysis]="IMGFNT00 IMGFNT06 IMGFNT12 IMGFNT18"
CATEGORY_CODES[climate]="CSA001US"
CATEGORY_CODES[forecast_models]="AL02YY5D AL02YYRS AL03YY5D AL03YYRS EP06YY5D EP06YYWS MOD91EUS MOD93SUS MOD94SUS MOD96FBW MODDY1US MODDY2US MODQP1US MODQP2US"
CATEGORY_CODES[hazards]="USHZTHRT GPHJ88US"
CATEGORY_CODES[storm_prediction]="IMGWWAUS MODDY1US MODDY2US"
CATEGORY_CODES[qpf]="MOD93SUS MOD94SUS MODQP1US MODQP2US MOD91EUS"

# Parse args
while (( $# )); do
    case "$1" in
        --radar)
            CATEGORY="radar"
            shift
            ;;
        --satellite)
            CATEGORY="satellite"
            shift
            ;;
        --surface)
            CATEGORY="surface_analysis"
            shift
            ;;
        --climate)
            CATEGORY="climate"
            shift
            ;;
        --forecast)
            CATEGORY="forecast_models"
            shift
            ;;
        --storms)
            CATEGORY="storm_prediction"
            shift
            ;;
        --qpf)
            CATEGORY="qpf"
            shift
            ;;
        --code)
            if [[ -n "${2-}" ]]; then
                CODES="$2"
                shift 2
            else
                echo "Error: --code requires a comma separated list"
                usage
            fi
            ;;
        --days)
            if [[ -n "${2-}" && "$2" =~ ^[0-9]+$ ]]; then
                DAYS_BACK="$2"
                shift 2
            else
                echo "Error: --days requires a numeric argument"
                usage
            fi
            ;;
        --debug)
            DEBUG=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z "$CATEGORY" ]]; then
    echo "Error: You must specify one category: --radar, --satellite, or --advisories"
    usage
fi

ALL_CODES="${CATEGORY_CODES[$CATEGORY]}"
if [[ -z "$ALL_CODES" ]]; then
    echo "Error: Unknown category '$CATEGORY' or no codes defined."
    exit 1
fi

# Filter user codes if specified
if [[ -n "$CODES" ]]; then
    IFS=',' read -r -a user_codes <<< "$CODES"
    FILTERED_CODES=()
    for uc in "${user_codes[@]}"; do
        if [[ " $ALL_CODES " == *" $uc "* ]]; then
            FILTERED_CODES+=("$uc")
        else
            echo "Warning: Code '$uc' not in $CATEGORY category; skipping."
        fi
    done
    if [[ ${#FILTERED_CODES[@]} -eq 0 ]]; then
        echo "Error: No valid codes to process after filtering."
        exit 1
    fi
else
    IFS=' ' read -r -a FILTERED_CODES <<< "$ALL_CODES"
fi

log_debug "Processing category '$CATEGORY' for codes: ${FILTERED_CODES[*]}"
log_debug "Looking back $DAYS_BACK day(s)"

NOW_EPOCH=$(date +%s)
CUTOFF_EPOCH=$(( NOW_EPOCH - DAYS_BACK*86400 ))

process_code() {
    local code="$1"
    [[ "${DEBUG:-0}" -eq 1 ]] && echo "[DEBUG] Processing EMWIN code: $code"

    # Find matching files modified in last $DAYS_BACK days, print mtime and filename
    mapfile -t files_with_time < <(
        find "$SRC_DIR" -type f \( -iname "*${code}*.gif" -o -iname "*${code}*.jpg" -o -iname "*${code}*.png" \) \
        -printf "%T@ %p\n" \
        | awk -v cutoff=$CUTOFF_EPOCH '$1 >= cutoff'
    )

    if [[ ${#files_with_time[@]} -eq 0 ]]; then
        [[ "${DEBUG:-0}" -eq 1 ]] && echo "[DEBUG] No files found for $code in last $DAYS_BACK days"
        return
    fi

    # Sort files by mtime ascending (oldest first)
    IFS=$'\n' sorted_files=($(printf '%s\n' "${files_with_time[@]}" | sort -n))

    # Extract just the filenames, preserving order
    files=()
    for entry in "${sorted_files[@]}"; do
        # entry format: "<mtime> <filepath>"
        files+=("${entry#* }")
    done

    [[ "${DEBUG:-0}" -eq 1 ]] && echo "[DEBUG] Found ${#files[@]} files for $code"
    [[ "${DEBUG:-0}" -eq 1 ]] && echo "[DEBUG] First file: ${files[0]}"
    [[ "${DEBUG:-0}" -eq 1 ]] && echo "[DEBUG] Last file: ${files[-1]}"

    # Create ffmpeg concat list file
    local listfile
    listfile=$(mktemp)
    [[ "${DEBUG:-0}" -eq 1 ]] && echo "[DEBUG] Using ffmpeg list file: $listfile"

    valid_images=()
    for f in "${files[@]}"; do
        # Check if file still exists (avoid caching issues)
        if [[ ! -f "$f" ]]; then
            echo "Warning: File disappeared before processing: $f"
            continue
        fi

        if ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$f" >/dev/null 2>&1; then
            echo "file '$(realpath "$f")'" >> "$listfile"
            echo "duration 0.1" >> "$listfile"
            valid_images+=("$f")
        else
            echo "Warning: Skipping unreadable or corrupt image: $f"
        fi
    done

    # Add the last valid image again to complete loop
    if [[ ${#valid_images[@]} -eq 0 ]]; then
        echo "Error: No valid images found for $code"
        rm -f "$listfile"
        return
    fi

    echo "file '$(realpath "${valid_images[-1]}")'" >> "$listfile"

    [[ "${DEBUG:-0}" -eq 1 ]] && echo "[DEBUG] Contents of ffmpeg concat list file:"
    [[ "${DEBUG:-0}" -eq 1 ]] && cat "$listfile"

    local outfile="$OUT_DIR/${code}.webp"
    [[ "${DEBUG:-0}" -eq 1 ]] && echo "[DEBUG] Creating animated WebP with ffmpeg: $outfile"

    # Run ffmpeg and capture output
    local ffmpeg_output
    ffmpeg_output=$(ffmpeg -y -f concat -safe 0 -i "$listfile" -loop 0 "$outfile" 2>&1)
    local ffmpeg_exit=$?

    #echo "===== ffmpeg output start ====="
    #echo "$ffmpeg_output"
    #echo "===== ffmpeg output end ====="

    rm -f "$listfile"

    if [[ $ffmpeg_exit -ne 0 ]]; then
        echo "Error: ffmpeg failed with exit code $ffmpeg_exit"
        echo "Skipping $code"
        return
    fi

    if [[ ! -s "$outfile" ]]; then
        echo "Error: ffmpeg created file but it is empty or missing: $outfile"
        echo "Skipping $code"
        return
    fi

    # Check if output is actually valid and decodable
    if ! ffprobe -v error "$outfile" >/dev/null 2>&1; then
        echo "Warning: Created WebP appears corrupt or unreadable. Attempting re-encode with fallback settings..."

        # Try fallback encode: force pixel format to rgba
        ffmpeg -y -f concat -safe 0 -i "$listfile" -pix_fmt rgba -loop 0 "$outfile" 2>&1 | tee /tmp/fallback_ffmpeg_output.log
        if [[ $? -ne 0 || ! -s "$outfile" || ! $(file -b --mime-type "$outfile") =~ image/webp ]]; then
            echo "Error: Fallback re-encode also failed or file still unreadable. Skipping $code."
            rm -f "$outfile"
            return
        else
            echo "Fallback re-encode successful for $code."
        fi
    fi

    [[ "${DEBUG:-0}" -eq 1 ]] && echo "[DEBUG] Created $outfile successfully with ffmpeg"

    # === Thumbnail generation ===
    local thumbfile="${outfile%.webp}_thumb.jpg"
    local latest_file="${valid_images[-1]}"

    if [[ -f "$latest_file" ]]; then
        ffmpeg -y -i "$latest_file" -frames:v 1 "$thumbfile" &>/dev/null
        if [[ $? -eq 0 && -s "$thumbfile" ]]; then
            [[ "${DEBUG:-0}" -eq 1 ]] && echo "[DEBUG] Created thumbnail $thumbfile from $latest_file"
        else
            echo "Warning: Failed to create thumbnail for $code"
        fi
    else
        echo "Warning: Latest source file not found for thumbnail: $latest_file"
    fi
}

max_parallel=4
pids=()

for code in "${FILTERED_CODES[@]}"; do
    process_code "$code" &
    pids+=($!)

    # Limit to max_parallel jobs
    while [[ ${#pids[@]} -ge $max_parallel ]]; do
        for i in "${!pids[@]}"; do
            if ! kill -0 "${pids[i]}" 2>/dev/null; then
                unset 'pids[i]'
            fi
        done
        pids=("${pids[@]}")  # Re-index array
        sleep 0.5
    done
done

wait
