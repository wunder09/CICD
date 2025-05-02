import shutil
import os
import time


def backup_files(source_dir, destination_dir):
    try:
        if not os.path.exists(destination_dir):
            os.makedirs(destination_dir)
        for root, dirs, files in os.walk(source_dir):
            for file in files:
                source_file = os.path.join(root, file)
                relative_path = os.path.relpath(source_file, source_dir)
                destination_file = os.path.join(destination_dir, relative_path)
                destination_sub_dir = os.path.dirname(destination_file)
                if not os.path.exists(destination_sub_dir):
                    os.makedirs(destination_sub_dir)
                shutil.copy2(source_file, destination_file)
        print("备份完成")
    except Exception as e:
        print(f"备份过程中出现错误: {e}")


if __name__ == "__main__":
    source_directory = "/path/to/source"
    destination_directory = "/path/to/destination"
    backup_files(source_directory, destination_directory)