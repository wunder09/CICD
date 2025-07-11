import psutil
import time

def monitor_system():
    while True:
        cpu_percent = psutil.cpu_percent(interval=1)
        memory_percent = psutil.virtual_memory().percent
        print(f"CPU 使用率: {cpu_percent}%，内存使用率: {memory_percent}%")
        time.sleep(5)

if __name__ == "__main__":
    monitor_system()