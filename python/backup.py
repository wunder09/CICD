# 备份文件夹

import shutil
import os
import datetime


def backup_files(source_dir, destination_dir):
    # 获取当前日期和时间，用于创建唯一的备份文件夹名称
    now = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    backup_folder = os.path.join(destination_dir, f"backup_{now}")
    try:
        # 复制源目录到备份目录
        shutil.copytree(source_dir, backup_folder)
        print(f"Backup completed successfully to {backup_folder}")
    except Exception as e:
        print(f"Error occurred during backup: {e}")


if __name__ == "__main__":
    # 要备份的源目录
    source_dir = "/path/to/source"
    # 备份的目标目录
    destination_dir = "/path/to/destination"
    backup_files(source_dir, destination_dir)