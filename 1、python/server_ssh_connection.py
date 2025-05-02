import paramiko

def ssh_execute_command(host, port, username, password, command):
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, port=port, username=username, password=password)
        stdin, stdout, stderr = ssh.exec_command(command)
        result = stdout.read().decode()
        error = stderr.read().decode()
        if error:
            print(f"执行命令时出现错误: {error}")
        else:
            print(f"命令执行结果: {result}")
        ssh.close()
    except Exception as e:
        print(f"SSH 连接或命令执行出错: {e}")


if __name__ == "__main__":
    server_host = "192.168.31.119"
    server_port = 22
    server_username = "root123"
    server_password = "root123"
    command_to_execute = "cd /opt/ && ls"
    ssh_execute_command(server_host, server_port, server_username, server_password, command_to_execute)