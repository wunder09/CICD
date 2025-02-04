# 解压文件并删除压缩包

import os
import zipfile

def scan_and_unzip(path):
    files = os.listdir(path)
    for file in files:
        if file.endswith('.zip'):
            # 使用 os.path.join() 函数将文件夹路径和文件名组合成一个完整的文件路径
            zip_file_path = os.path.join(path, file)
            # 以只读模式打开 ZIP 文件
            with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
                # 将 ZIP 文件中的所有内容解压到指定的路径
                zip_ref.extractall(path)
            # 删除原始的 ZIP 文件，以释放磁盘空间
            os.remove(zip_file_path)


# 指定要检查的文件夹路径
folder_path = './SS'

# 调用函数进行扫描和解压
scan_and_unzip(folder_path)
