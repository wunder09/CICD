def analyze_logs(log_file):
    """
    分析日志文件，查找并打印其中的错误信息。

    参数:
    log_file (str): 日志文件的路径。

    返回:
    None
    """
    # 存储日志文件中错误信息的列表
    error_messages = []
    try:
        # 打开日志文件并读取其内容
        with open(log_file, 'r') as f:
            # 逐行读取日志文件
            for line in f:
                # 检查当前行是否包含"ERROR"关键字
                if "ERROR" in line:
                    # 如果包含，将该行添加到错误信息列表中
                    error_messages.append(line)
    except Exception as e:
        # 如果在读取日志文件时发生错误，打印错误信息
        print(f"Error occurred while reading the log file: {e}")
    # 如果错误信息列表不为空
    if error_messages:
        # 打印找到的错误信息
        print("The following errors were found:")
        for error in error_messages:
            print(error)
    else:
        # 如果没有找到错误信息，打印相应的提示
        print("No errors found in the log file.")


if __name__ == "__main__":
    # 日志文件的路径
    log_file = "/path/to/logfile.log"
    # 调用analyze_logs函数分析日志文件
    analyze_logs(log_file)
