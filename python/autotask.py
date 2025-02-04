# 监控某个目录下的文件变化（新增、修改、删除），并将变化记录到一个日志文件中。
# pip install watchdog


import time
import logging
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# 设置日志记录
logging.basicConfig(filename='file_changes.log', level=logging.INFO,
                    format='%(asctime)s - %(message)s', datefmt='%Y-%m-%d %H:%M:%S')

class FileChangeHandler(FileSystemEventHandler):
    def on_created(self, event):
        # 排除目录
        if not event.is_directory:
            logging.info(f"文件创建: {event.src_path}")

    def on_modified(self, event):
        if not event.is_directory:
            logging.info(f"文件修改: {event.src_path}")

    def on_deleted(self, event):
        if not event.is_directory:
            logging.info(f"文件删除: {event.src_path}")

if __name__ == "__main__":
    path = '.'  # 监控目录
    event_handler = FileChangeHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
