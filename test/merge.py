def merge_files(input_files, output_file):
    # 读取所有输入文件的内容
    file_contents = []
    for file_name in input_files:
        with open(file_name, 'r') as file:
            content = file.read().splitlines()
            file_contents.append(content)

    # 确定最大行数
    max_lines = max(len(content) for content in file_contents)

    # 对齐每一行并写入输出文件
    with open(output_file, 'w') as output:
        for i in range(max_lines):
            merged_line = ''
            for content in file_contents:
                if i < len(content):
                    hex_str = content[i].strip()  # 移除可能的空格或换行符
                    # 从16进制字符串中去掉0x前缀
                    hex_str = hex_str.replace("0x", "")
                    merged_line += hex_str
            # 确保每一行都对齐16个16进制数
            merged_line = merged_line.ljust(16, '0')[:16]  # 对齐32个字符，然后取前32个字符
            output.write(merged_line + '\n')

# 输入文件列表
input_files = ['frame/frame_0.txt', 'frame/frame_1.txt', 'frame/frame_2.txt', 'frame/frame_3.txt']

# 输出文件名
output_file = 'merged_output.txt'

# 调用合并函数
merge_files(input_files, output_file)
