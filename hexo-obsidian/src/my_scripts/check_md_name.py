"""
非侵入式检查指定文件夹下 Markdown 文件中的 Front-matter title 是否与文件名一致。

作者：wuanqin
邮箱：wuanqin@mail.ustc.edu.cn
博客：https://uusnqin.top/
日期：2023.08.15
许可证：MIT
"""

import os
import re
import sys
from pathlib import Path

all_file_num = 0
no_pass = []
def walk_posts_dir(folder):
    """
    遍历指定目录
    :param folder:
    :return:
    """
    global all_file_num, no_pass
    for root, dirs, files in os.walk(folder, followlinks=True):
        for file in files:
            # 过滤 Markdown 文件
            if not file.endswith(".md"):
                continue
            file_name = Path(file).stem
            # 打开具体文件提取Frontmatter
            file_path = os.path.join(root, file)
            with open(file_path,"r",encoding="utf-8") as f:
                content = f.read()
            front_matter, _ = parse_yaml_front_matter(content)
            file_name_front_matter = front_matter['title']
            # 判断文件名与Front-matter中的title字段是否相等
            if file_name == file_name_front_matter:
                print(f"[File Name Check] PASS: {file}")
            else:
                no_pass.append(file_path)
                print(f"[File Name Check] NO PASS: {file}")
            all_file_num = all_file_num + 1
    # 直到检查完输出结果
    else:
        print(f"[File Name Check] Done. {all_file_num} files Total.")
        if len(no_pass)>0:
            for e in no_pass:
                print(f"[File Name Check] Conflict - {e}")
            # 返回错误码以终止后续进程
            print(f"[File Name Check] Exit 1.")
            exit(1)

def parse_yaml_front_matter(content):
    """
    Parses YAML front matter from a Markdown file (More general).
    Now it can recognize Block Mode and Flow Mode of the YAML specification (See https://cosma.arthurperret.fr/user-manual.html#metadata).
    Also, it can process Line Folding (See https://yaml.org/spec/1.2.2/).
    """
    match = re.match(r"^---\n(.*?)\n---(.*)", content, re.DOTALL)
    data = {}
    if match:
        # Divide a markdown file to two parts: the front-matter and the remaining content.
        front_matter = match.group(1)
        content = match.group(2)
        block_mode_attribute = None
        line_fold_attribute = None
        # Parse yaml by lines.
        for line in front_matter.split("\n"):
            # If the line is the first line of an attribute.
            if re.match(r"^([a-zA-Z-_]+):(.*)$", line):
                match_obj = re.match(r"^([a-zA-Z-_]+):(.*)$", line, re.DOTALL)
                key = match_obj.group(1)
                value = match_obj.group(2)
                value = value.strip(" \'\"")
                value = convert2num_if_possible(value)
                # A line like 'attribute: ', which means that it uses Block Mode.
                if not value:
                    # A mark to indicate that we should treat the next line as one of the parameter of the attribute.
                    block_mode_attribute = key
                    data[key] = []
                    continue
                # A line like 'attribute: >-', which means that it uses Line Folding.
                elif value == '>-':
                    # A mark to indicate that we should treat the next line as one of the parameter of the attribute.
                    line_fold_attribute = key
                    data[key] = ''
                    continue
                # Otherwise, treat the line as a common key-value pair.
            # Parse a line that is in Block Mode.
            elif block_mode_attribute and re.match(r"^\s*-\s(.*)$", line):
                match_obj = re.match(r"^\s*-\s(.*)$", line)
                data[block_mode_attribute].append(match_obj.group(1).strip())
                continue
            # Parse a line that is in Line Folding.
            elif line_fold_attribute:
                data[line_fold_attribute] = data[line_fold_attribute] + line.strip(" \'\"")
                continue
            else:
                print(f"[WARNING] Unknown YAML line: {line}")
                continue

            block_mode_attribute = None
            line_fold_attribute = None

            # Parse a line that is in Flow Mode.
            if isinstance(value, str) and re.match(r"\[(.*)\]", value, re.DOTALL):
                match_obj = re.match(r"\[(.*)\]", value, re.DOTALL)
                value = match_obj.group(1)
                # Remove the brackets from the string
                value = value.strip("[]")
                # Split the string on commas and store the resulting list of tags
                value = value.split(",")
                # Strip any leading or trailing whitespace from each tag
                value = [convert2num_if_possible(v.strip()) for v in value]
            data[key] = value
    return data, content

def convert2num_if_possible(value):
    """ Parse values as integers or floats if possible, otherwise keep as string"""
    try:
        value = int(value)
    except ValueError:
        try:
            # Check the number to avoid the peculiar bugs occur, such as '13e4' converts to 130000.0
            if str(float(value)) != value:
                raise ValueError
            else:
                value = float(value)
        except ValueError:
            pass
    return value

def convert_dict2_yaml_front_matter(d: dict) -> str:
    """Convert a dictionary of Python to the front matter (YAML)"""
    front_matter = "---\n"
    for k, v in d.items():
        front_matter = front_matter + f"{k}: {str(v)}\n"
    return front_matter + "---\n"

if __name__ == "__main__":
    walk_posts_dir(sys.argv[1])

