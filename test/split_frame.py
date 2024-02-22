def split_frames(input_file, output_prefix="output_frame"):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    frame_count = 0
    current_frame = []

    for line in lines:
        line = line.strip()

        if not line:  # Skip empty lines
            continue

        if line == "0000":
            if current_frame:
                current_frame.insert(0, line)
                output_file = f"{output_prefix}_{frame_count}.txt"
                with open(output_file, 'w') as frame_file:
                    # Combine every 4 lines into one line
                    combined_lines = ["".join(current_frame[i:i+4]) for i in range(0, len(current_frame), 4)]
                    frame_file.write('\n'.join(combined_lines))
                frame_count += 1
                current_frame = []
        else:
            current_frame.append(line)

    # Save the last frame
    if current_frame:
        output_file = f"{output_prefix}_{frame_count}.txt"
        with open(output_file, 'w') as frame_file:
            # Combine every 4 lines into one line
            combined_lines = ["".join(current_frame[i:i+4]) for i in range(0, len(current_frame), 4)]
            frame_file.write('\n'.join(combined_lines))

if __name__ == "__main__":
    input_file_path = "akiyo300_1ref.txt"
    output_file_prefix = "frame/frame"
    split_frames(input_file_path, output_file_prefix)
