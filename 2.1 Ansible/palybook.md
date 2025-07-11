# palybook

### 1. 保存 Playbook 文件
将你提供的内容保存为一个以 `.yml` 或 `.yaml` 结尾的文件，例如 `create_user.yml`。
```bash
nano create_user.yml
```
### 2. 检查主机清单
Ansible 需要知道要在哪些主机上执行任务，这通过主机清单文件来指定。默认的主机清单文件位于 `/etc/ansible/hosts`，你也可以使用自定义的主机清单文件。

- **默认主机清单**：如果你使用默认的主机清单文件，确保文件中包含了要创建用户的目标主机信息。例如：
```ini
[your_host_group]
192.168.1.100
192.168.1.101
```
- **自定义主机清单**：若要使用自定义的主机清单文件，假设文件名为 `my_inventory`，内容如下：
```ini
[your_host_group]
192.168.1.100
192.168.1.101
```

### 3. 确保 SSH 连接正常
Ansible 通过 SSH 与目标主机进行通信，所以要保证控制节点（运行 Ansible 的机器）能够通过 SSH 连接到目标主机。你可以配置 SSH 密钥认证，避免每次都输入密码。

### 4. 运行 Playbook
在控制节点上，使用 `ansible-playbook` 命令来运行 Playbook。

- **使用默认主机清单**：
```bash
ansible-playbook create_user.yml
```
- **使用自定义主机清单**：使用 `-i` 选项指定自定义主机清单文件的路径。
```bash
ansible-playbook -i my_inventory create_user.yml
```

### 5. 处理权限问题
在创建用户时，通常需要使用管理员权限。如果你的 Playbook 中没有使用 `become` 关键字来提升权限，可能会遇到权限不足的问题。

你可以在 Playbook 中添加 `become: true` 来使用 `sudo` 权限执行任务，修改后的 Playbook 如下：

```yaml
- name: Create a new user
  hosts: all
  become: true  # 使用 sudo 权限执行任务
  tasks:
    - name: Add user john
      user:
        name: john
        state: present
        password: "{{ 'password123' | password_hash('sha512') }}"
```
然后再次运行 Playbook。

### 6. 查看执行结果
运行 `ansible-playbook` 命令后，Ansible 会输出每个任务的执行结果。如果任务成功执行，会显示 `changed` 或 `ok`；如果出现错误，会显示详细的错误信息，你可以根据这些信息进行调试。
